#  CloudVault — Django S3 Storage Application

A  cloud storage management app built with **Django**, **MySQL**, and **AWS S3**. Users can securely upload, manage, download, and backup files — each user gets their own isolated S3 directory. This app is built for demonstration purpose.

**Docker Image**: amitgiri13/cloudvault:3.0.1


##  Features

- **Authentication** — Register, login, logout with session management
- **File Management** — Upload, download, delete files with a modern UI
- **S3 Storage** — Files stored in AWS S3, isolated per user (`users/{user_id}/`)
- **Backup System** — Per-file or full backup to a dedicated S3 backup directory
- **Folder Organization** — Create folders to organize your files
- **Bulk Operations** — Select and delete multiple files at once
- **File Preview** — Preview images, video, and audio in browser
- **Search & Sort** — Search files by name, tags, description; sort by various fields
- **Storage Quota** — Visual storage usage indicator per user
- **Admin Panel** — Full Django admin access

## Project Structure

```
django_s3_storage_app/
├── docker-compose.yml          
├── Dockerfile                  
├── requirements.txt
├── .env                       
│
├── manage.py
├── core/                       # Django project config
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
│
├── accounts/                   # Auth + user profiles
│   ├── models.py               # UserProfile model
│   ├── views.py                # Login, register, profile
│   ├── urls.py
│   └── forms.py
│
├── storageapp/                 # Core storage features
│   ├── models.py               # UserFile, Folder, BackupJob
│   ├── views.py                # All file management views
│   ├── urls.py
│   ├── s3_utils.py             # All boto3/S3 operations
│   └── tests.py                # Comprehensive test suite
│
└── templates/
    ├── base.html               # Dark sidebar layout
    ├── login.html
    ├── register.html
    ├── dashboard.html          # Stats, recent files, storage bar
    ├── upload.html             # Drag & drop uploader
    ├── files.html              # File grid with search/filter
    ├── file_detail.html        # Preview + edit
    ├── profile.html
```

### Presigned URLs
Files are served via time-limited **presigned S3 URLs** (1 hour default), so files are never proxied through the Django server — direct, secure downloads from S3.


##  Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SECRET_KEY` | Django secret key | Required |
| `DEBUG` | Debug mode | `True` |
| `DB_NAME` | MySQL database name | `s3storage_db` |
| `DB_USER` | MySQL user | `django_user` |
| `DB_PASSWORD` | MySQL password | Required |
| `DB_HOST` | MySQL host | `db` |
| `AWS_ACCESS_KEY_ID` | AWS access key | Required |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | Required |
| `AWS_STORAGE_BUCKET_NAME` | S3 bucket name | Required |
| `AWS_S3_REGION_NAME` | S3 region | `us-east-1` |
| `MAX_UPLOAD_SIZE_MB` | Max file upload size | `100` |
