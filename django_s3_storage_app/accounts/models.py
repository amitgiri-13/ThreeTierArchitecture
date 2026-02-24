from django.db import models
from django.contrib.auth.models import User


class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    avatar = models.CharField(max_length=255, blank=True, default='')
    storage_used = models.BigIntegerField(default=0)  # bytes
    storage_quota = models.BigIntegerField(default=10 * 1024 * 1024 * 1024)  # 10GB default
    created_at = models.DateTimeField(auto_now_add=True)

    def get_storage_used_display(self):
        return self.format_bytes(self.storage_used)

    def get_quota_display(self):
        return self.format_bytes(self.storage_quota)

    def get_usage_percent(self):
        if self.storage_quota == 0:
            return 0
        return min(100, int((self.storage_used / self.storage_quota) * 100))

    @staticmethod
    def format_bytes(size):
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if size < 1024:
                return f"{size:.1f} {unit}"
            size /= 1024
        return f"{size:.1f} PB"

    def __str__(self):
        return f"{self.user.username}'s profile"
