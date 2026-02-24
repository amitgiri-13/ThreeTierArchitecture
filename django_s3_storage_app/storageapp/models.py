from django.db import models
from django.contrib.auth.models import User
from django.db.models import Q
import os


class Folder(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='folders')
    name = models.CharField(max_length=191)
    parent = models.ForeignKey(
        'self',
        null=True,
        blank=True,
        on_delete=models.CASCADE,
        related_name='children'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['name']
        constraints = [
            # For subfolders (parent NOT NULL)
            models.UniqueConstraint(
                fields=['user', 'name', 'parent'],
                condition=Q(parent__isnull=False),
                name='unique_folder_per_parent'
            ),

            # For root folders (parent IS NULL)
            models.UniqueConstraint(
                fields=['user', 'name'],
                condition=Q(parent__isnull=True),
                name='unique_root_folder_per_user'
            ),
        ]

    def __str__(self):
        return self.name

    def get_full_path(self):
        parts = [self.name]
        parent = self.parent
        while parent:
            parts.insert(0, parent.name)
            parent = parent.parent
        return '/'.join(parts)


class UserFile(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='files')
    folder = models.ForeignKey(
        Folder,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='files'
    )
    name = models.CharField(max_length=255)
    original_name = models.CharField(max_length=255)
    s3_key = models.CharField(max_length=255, unique=True)
    file_size = models.BigIntegerField(default=0)
    content_type = models.CharField(max_length=100, blank=True)
    description = models.TextField(blank=True)
    tags = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_accessed = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.name

    def get_extension(self):
        _, ext = os.path.splitext(self.original_name)
        return ext.lower()

    def get_file_type(self):
        ext = self.get_extension()
        type_map = {
            'image': ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'],
            'video': ['.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm'],
            'audio': ['.mp3', '.wav', '.ogg', '.flac', '.aac', '.m4a'],
            'document': ['.pdf', '.doc', '.docx', '.txt', '.odt', '.rtf'],
            'spreadsheet': ['.xls', '.xlsx', '.csv', '.ods'],
            'presentation': ['.ppt', '.pptx', '.odp'],
            'archive': ['.zip', '.tar', '.gz', '.rar', '.7z'],
            'code': ['.py', '.js', '.html', '.css', '.json', '.xml', '.sql'],
        }
        for ftype, extensions in type_map.items():
            if ext in extensions:
                return ftype
        return 'other'

    def format_size(self):
        size = self.file_size
        for unit in ['B', 'KB', 'MB', 'GB']:
            if size < 1024:
                return f"{size:.1f} {unit}"
            size /= 1024
        return f"{size:.1f} TB"

    def get_icon(self):
        icons = {
            'image': 'bi-file-image',
            'video': 'bi-file-play',
            'audio': 'bi-file-music',
            'document': 'bi-file-text',
            'spreadsheet': 'bi-file-spreadsheet',
            'presentation': 'bi-file-slides',
            'archive': 'bi-file-zip',
            'code': 'bi-file-code',
            'other': 'bi-file',
        }
        return icons.get(self.get_file_type(), 'bi-file')

    @staticmethod
    def format_size_static(size):
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if size < 1024:
                return f"{size:.2f} {unit}"
            size /= 1024
        return f"{size:.2f} PB"