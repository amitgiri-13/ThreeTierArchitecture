import os
import uuid
import mimetypes
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from django.utils import timezone
from django.db.models import Q, Sum
from django.db import transaction
from .models import UserFile, Folder
from .s3_utils import (
    upload_file_to_s3, generate_presigned_url, delete_file_from_s3,
    delete_multiple_files_from_s3, get_user_s3_prefix
)
from accounts.models import UserProfile
from django.conf import settings


# Utility: Get or create user profile
def get_or_create_profile(user):
    profile, _ = UserProfile.objects.get_or_create(user=user)
    return profile


# ---------------- Dashboard ----------------
@login_required
def dashboard_view(request):
    profile = get_or_create_profile(request.user)
    
    files = UserFile.objects.filter(user=request.user)
    total_files = files.count()
    total_size = files.aggregate(Sum('file_size'))['file_size__sum'] or 0
    
    recent_files = files.order_by('-created_at')[:8]
    
    # File type breakdown
    file_types = {}
    for f in files:
        ftype = f.get_file_type()
        file_types[ftype] = file_types.get(ftype, 0) + 1
    
    context = {
        'profile': profile,
        'total_files': total_files,
        'total_size': UserFile.format_size_static(total_size),
        'recent_files': recent_files,
        'file_types': file_types,
        'storage_percent': profile.get_usage_percent(),
    }
    return render(request, 'dashboard.html', context)


# ---------------- File List ----------------
def get_all_subfolders(folder):
    """Recursively get all child folders"""
    subfolders = list(folder.children.all())
    for sub in subfolders:
        subfolders.extend(get_all_subfolders(sub))
    return subfolders


@login_required
def file_list_view(request):
    query = request.GET.get('q', '')
    folder_id = request.GET.get('folder', None)
    file_type = request.GET.get('type', '')
    sort = request.GET.get('sort', '-created_at')

    files = UserFile.objects.filter(user=request.user)

    current_folder = None
    folder_list = []

    # -------------------------------
    # Folder filtering (recursive)
    # -------------------------------
    if folder_id:
        current_folder = get_object_or_404(Folder, id=folder_id, user=request.user)

        # include selected folder + all subfolders
        folder_list = [current_folder] + get_all_subfolders(current_folder)

        files = files.filter(folder__in=folder_list)
    else:
        files = files.filter(folder=None)

    # -------------------------------
    # Search query
    # -------------------------------
    if query:
        files = files.filter(
            Q(name__icontains=query) |
            Q(original_name__icontains=query) |
            Q(tags__icontains=query) |
            Q(description__icontains=query)
        )

    # -------------------------------
    # File type filter (efficient way)
    # -------------------------------
    if file_type:
        files = [f for f in files if f.get_file_type().lower() == file_type.lower()]

    # -------------------------------
    # Sorting
    # -------------------------------
    valid_sorts = ['name', '-name', 'created_at', '-created_at', 'file_size', '-file_size']
    if sort in valid_sorts:
        files = files.order_by(sort)

    # -------------------------------
    # Folder navigation (children of current)
    # -------------------------------
    folders = Folder.objects.filter(
        user=request.user,
        parent=None if not current_folder else current_folder
    )

    context = {
        'files': files,
        'folders': folders,
        'current_folder': current_folder,
        'query': query,
        'sort': sort,
        'file_type': file_type,
    }

    return render(request, 'files.html', context)
# ---------------- Upload ----------------
@login_required
def upload_view(request):
    profile = get_or_create_profile(request.user)
    folders = Folder.objects.filter(user=request.user)
    
    if request.method == 'POST':
        uploaded_files = request.FILES.getlist('files')
        folder_id = request.POST.get('folder', None)
        description = request.POST.get('description', '')
        tags = request.POST.get('tags', '')
        
        if not uploaded_files:
            messages.error(request, 'Please select at least one file to upload.')
            return render(request, 'upload.html', {'profile': profile, 'folders': folders})
        
        folder = None
        if folder_id:
            folder = get_object_or_404(Folder, id=folder_id, user=request.user)
        
        success_count = 0
        error_count = 0
        
        for file_obj in uploaded_files:
            if file_obj.size > settings.MAX_UPLOAD_SIZE:
                messages.error(
                    request,
                    f"'{file_obj.name}' exceeds the maximum upload size of {settings.MAX_UPLOAD_SIZE_MB}MB."
                )
                error_count += 1
                continue
            
            # Generate unique S3 key
            prefix = get_user_s3_prefix(request.user)
            unique_name = f"{uuid.uuid4().hex}{os.path.splitext(file_obj.name)[1]}"
            s3_key = f"{prefix}{unique_name}"
            
            content_type = file_obj.content_type or mimetypes.guess_type(file_obj.name)[0] or 'application/octet-stream'
            
            success, error = upload_file_to_s3(file_obj, s3_key, content_type)
            
            if success:
                with transaction.atomic():
                    user_file = UserFile.objects.create(
                        user=request.user,
                        folder=folder,
                        name=file_obj.name,
                        original_name=file_obj.name,
                        s3_key=s3_key,
                        file_size=file_obj.size,
                        content_type=content_type,
                        description=description,
                        tags=tags,
                    )
                    profile.storage_used += file_obj.size
                    profile.save()
                success_count += 1
            else:
                messages.error(request, f"Failed to upload '{file_obj.name}': {error}")
                error_count += 1
        
        if success_count:
            messages.success(request, f"Successfully uploaded {success_count} file(s).")
        if error_count:
            messages.warning(request, f"{error_count} file(s) failed to upload.")
        
        return redirect('file_list')
    
    return render(request, 'upload.html', {'profile': profile, 'folders': folders})


# ---------------- Download ----------------
@login_required
def download_file_view(request, file_id):
    user_file = get_object_or_404(UserFile, id=file_id, user=request.user)
    
    url = generate_presigned_url(user_file.s3_key)
    if not url:
        messages.error(request, 'Could not generate download link. Please try again.')
        return redirect('file_list')
    
    user_file.last_accessed = timezone.now()
    user_file.save(update_fields=['last_accessed'])
    
    return redirect(url)


# ---------------- Delete Single File ----------------
@login_required
@require_http_methods(['POST'])
def delete_file_view(request, file_id):
    user_file = get_object_or_404(UserFile, id=file_id, user=request.user)
    
    success, error = delete_file_from_s3(user_file.s3_key)
    
    profile = get_or_create_profile(request.user)
    profile.storage_used = max(0, profile.storage_used - user_file.file_size)
    profile.save()
    
    user_file.delete()
    
    if success:
        messages.success(request, f"'{user_file.name}' has been deleted.")
    else:
        messages.warning(request, f"File deleted from database, but S3 removal may have failed: {error}")
    
    return redirect('file_list')


# ---------------- Delete Multiple Files ----------------
@login_required
@require_http_methods(['POST'])
def delete_multiple_files_view(request):
    file_ids = request.POST.getlist('file_ids')
    if not file_ids:
        messages.error(request, 'No files selected.')
        return redirect('file_list')
    
    files = UserFile.objects.filter(id__in=file_ids, user=request.user)
    s3_keys = [f.s3_key for f in files]
    total_size = sum(f.file_size for f in files)
    
    delete_multiple_files_from_s3(s3_keys)
    count = files.count()
    files.delete()
    
    profile = get_or_create_profile(request.user)
    profile.storage_used = max(0, profile.storage_used - total_size)
    profile.save()
    
    messages.success(request, f"{count} file(s) deleted successfully.")
    return redirect('file_list')


# ---------------- File Details ----------------
@login_required
def file_detail_view(request, file_id):
    user_file = get_object_or_404(UserFile, id=file_id, user=request.user)
    preview_url = None
    
    if user_file.get_file_type().lower() in ['image', 'video', 'audio', 'document']:
        preview_url = generate_presigned_url(user_file.s3_key, expiry=300)
    
    if request.method == 'POST':
        user_file.description = request.POST.get('description', user_file.description)
        user_file.tags = request.POST.get('tags', user_file.tags)
        new_name = request.POST.get('name', '').strip()
        if new_name:
            user_file.name = new_name
        user_file.save()
        messages.success(request, 'File details updated.')
        return redirect('file_detail', file_id=file_id)
    
    return render(request, 'file_detail.html', {'file': user_file, 'preview_url': preview_url})


# ---------------- Create Folder ----------------
@login_required
def create_folder_view(request):
    if request.method == 'POST':
        name = request.POST.get('name', '').strip()
        parent_id = request.POST.get('parent', None)
        
        if not name:
            messages.error(request, 'Folder name cannot be empty.')
            return redirect('file_list')
        
        parent = None
        if parent_id:
            parent = get_object_or_404(Folder, id=parent_id, user=request.user)
        
        folder, created = Folder.objects.get_or_create(
            user=request.user,
            name=name,
            parent=parent,
        )
        
        if created:
            messages.success(request, f"Folder '{name}' created.")
        else:
            messages.warning(request, f"A folder named '{name}' already exists.")
    
    return redirect('file_list')


# ---------------- Delete Folder ----------------
@login_required
@require_http_methods(['POST'])
def delete_folder_view(request, folder_id):
    folder = get_object_or_404(Folder, id=folder_id, user=request.user)
    
    # Delete all files in folder
    files = UserFile.objects.filter(folder=folder, user=request.user)
    s3_keys = [f.s3_key for f in files]
    total_size = sum(f.file_size for f in files)
    
    delete_multiple_files_from_s3(s3_keys)
    files.delete()
    
    profile = get_or_create_profile(request.user)
    profile.storage_used = max(0, profile.storage_used - total_size)
    profile.save()
    
    folder_name = folder.name
    folder.delete()
    messages.success(request, f"Folder '{folder_name}' and all its contents deleted.")
    return redirect('file_list')


# ---------------- AJAX: File Stats ----------------
@login_required
def api_file_stats(request):
    files = UserFile.objects.filter(user=request.user)
    type_stats = {}
    
    for f in files:
        ftype = f.get_file_type()
        if ftype not in type_stats:
            type_stats[ftype] = {'count': 0, 'size': 0}
        type_stats[ftype]['count'] += 1
        type_stats[ftype]['size'] += f.file_size
    
    # Optional: convert size to human-readable
    for t in type_stats:
        type_stats[t]['size'] = UserFile.format_size_static(type_stats[t]['size'])
    
    return JsonResponse({'file_types': type_stats})