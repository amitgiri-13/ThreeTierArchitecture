# ☁️ CloudVault — Django S3 Storage Application

A full-featured cloud storage management app built with **Django**, **MySQL**, and **AWS S3**. Users can securely upload, manage, download, and backup files — each user gets their own isolated S3 directory.

## ✨ Features

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

## 🗂️ Project Structure

```
django_s3_storage_app/
├── docker-compose.yml          # Production compose
├── docker-compose.test.yml     # Testing compose (with LocalStack)
├── Dockerfile                  # Multi-stage Docker build
├── docker-entrypoint.sh        # DB wait + migrate + superuser creation
├── nginx.conf                  # Nginx reverse proxy config
├── requirements.txt
├── .env                        # Environment variables (copy and fill)
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
    ├── file_detail.html        # Preview + edit + backup
    ├── profile.html
    └── backup_history.html
```

## 🚀 Quick Start

### 1. Configure Environment

```bash
cp .env .env.local
# Edit .env with your AWS credentials and database settings
```

Required `.env` values:
```env
SECRET_KEY=your-django-secret-key
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
AWS_STORAGE_BUCKET_NAME=your-bucket-name
AWS_S3_REGION_NAME=us-east-1
DB_PASSWORD=your-db-password
```

### 2. Set Up AWS S3 Bucket

Create an S3 bucket and configure it:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:CopyObject"],
      "Resource": "arn:aws:s3:::your-bucket-name/*"
    },
    {
      "Effect": "Allow", 
      "Action": ["s3:ListBucket"],
      "Resource": "arn:aws:s3:::your-bucket-name"
    }
  ]
}
```

### 3. Run with Docker Compose

```bash
# Start all services (web + db + nginx)
docker compose up -d

# Check logs
docker compose logs -f web

# The app will be available at:
# http://localhost       (via Nginx)
# http://localhost:8000  (direct)
```

Default superuser: `admin` / `admin123!`

### 4. Local Development (without Docker)

```bash
pip install -r requirements.txt

# Start MySQL locally and update .env DB_HOST to 'localhost'
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

## 🧪 Running Tests

### With Docker:
```bash
docker compose -f docker-compose.test.yml up --abort-on-container-exit
```

### Locally:
```bash
python manage.py test storageapp --verbosity=2
```

The test suite covers:
- Authentication flows (login, register, logout)
- File CRUD operations with mocked S3
- Folder management
- User isolation (can't access other users' files)
- S3 utility functions (upload, delete, presigned URLs)
- Model methods (file type detection, size formatting)

## 🏗️ Architecture

```
Browser → Nginx (port 80)
              ↓
         Django/Gunicorn (port 8000)
              ↓
         MySQL DB (file metadata)
              ↓
         AWS S3 (actual file storage)

S3 Structure:
  users/{user_id}/          ← uploaded files
  backups/{user_id}/        ← backup copies
```

### Presigned URLs
Files are served via time-limited **presigned S3 URLs** (1 hour default), so files are never proxied through the Django server — direct, secure downloads from S3.

## 🔒 Security Features

- Files stored with `private` ACL — no public access
- Server-side encryption (`AES256`) on all S3 objects
- Presigned URLs expire after 1 hour
- User isolation enforced at the database level
- CSRF protection on all forms
- Django's built-in auth security

## 📝 Environment Variables

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
