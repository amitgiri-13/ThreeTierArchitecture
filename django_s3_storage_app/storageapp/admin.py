from django.contrib import admin
from .models import UserFile, Folder


@admin.register(UserFile)
class UserFileAdmin(admin.ModelAdmin):
    list_display = ['name', 'user', 'file_size', 'content_type', 'created_at']
    list_filter = ['created_at']
    search_fields = ['name', 'original_name', 'user__username', 'tags']
    readonly_fields = ['s3_key', 'created_at', 'updated_at']
    date_hierarchy = 'created_at'


@admin.register(Folder)
class FolderAdmin(admin.ModelAdmin):
    list_display = ['name', 'user', 'parent', 'created_at']
    search_fields = ['name', 'user__username']
