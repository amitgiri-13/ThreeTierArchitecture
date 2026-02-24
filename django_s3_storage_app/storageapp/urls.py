from django.urls import path
from . import views

urlpatterns = [
    path('dashboard/', views.dashboard_view, name='dashboard'),
    path('files/', views.file_list_view, name='file_list'),
    path('upload/', views.upload_view, name='upload'),
    path('files/<int:file_id>/', views.file_detail_view, name='file_detail'),
    path('files/<int:file_id>/download/', views.download_file_view, name='download_file'),
    path('files/<int:file_id>/delete/', views.delete_file_view, name='delete_file'),
    path('files/delete-multiple/', views.delete_multiple_files_view, name='delete_multiple'),
    path('folders/create/', views.create_folder_view, name='create_folder'),
    path('folders/<int:folder_id>/delete/', views.delete_folder_view, name='delete_folder'),
    path('api/stats/', views.api_file_stats, name='api_file_stats'),
]
