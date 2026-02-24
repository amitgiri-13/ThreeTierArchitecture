import boto3
import os
import logging
from botocore.exceptions import ClientError
from django.conf import settings

logger = logging.getLogger(__name__)


def get_s3_client():
    session_kwargs = {
        "aws_access_key_id": settings.AWS_ACCESS_KEY_ID,
        "aws_secret_access_key": settings.AWS_SECRET_ACCESS_KEY,
        "region_name": settings.AWS_S3_REGION_NAME,
    }

    if getattr(settings, "AWS_SESSION_TOKEN", None):
        session_kwargs["aws_session_token"] = settings.AWS_SESSION_TOKEN

    return boto3.client("s3", **session_kwargs)

def get_user_s3_prefix(user):
    """Each user gets their own directory: users/{user_id}/"""
    return f"users/{user.id}/"


def upload_file_to_s3(file_obj, s3_key, content_type='application/octet-stream'):
    """Upload a file object to S3."""
    client = get_s3_client()
    try:
        client.upload_fileobj(
            file_obj,
            settings.AWS_STORAGE_BUCKET_NAME,
            s3_key,
            ExtraArgs={
                'ContentType': content_type,
                'ServerSideEncryption': 'AES256',
            }
        )
        return True, None
    except ClientError as e:
        logger.error(f"S3 upload error for {s3_key}: {e}")
        return False, str(e)


def generate_presigned_url(s3_key, expiry=3600):
    """Generate a presigned URL for secure download."""
    client = get_s3_client()
    try:
        url = client.generate_presigned_url(
            'get_object',
            Params={
                'Bucket': settings.AWS_STORAGE_BUCKET_NAME,
                'Key': s3_key,
            },
            ExpiresIn=expiry,
        )
        return url
    except ClientError as e:
        logger.error(f"Presigned URL error for {s3_key}: {e}")
        return None


def delete_file_from_s3(s3_key):
    """Delete a file from S3."""
    client = get_s3_client()
    try:
        client.delete_object(
            Bucket=settings.AWS_STORAGE_BUCKET_NAME,
            Key=s3_key,
        )
        return True, None
    except ClientError as e:
        logger.error(f"S3 delete error for {s3_key}: {e}")
        return False, str(e)


def delete_multiple_files_from_s3(s3_keys):
    """Delete multiple files from S3 in one request."""
    if not s3_keys:
        return True, None
    client = get_s3_client()
    try:
        objects = [{'Key': key} for key in s3_keys]
        response = client.delete_objects(
            Bucket=settings.AWS_STORAGE_BUCKET_NAME,
            Delete={'Objects': objects}
        )
        errors = response.get('Errors', [])
        if errors:
            return False, str(errors)
        return True, None
    except ClientError as e:
        logger.error(f"S3 bulk delete error: {e}")
        return False, str(e)


def copy_file_in_s3(source_key, dest_key):
    """Copy a file within S3 (for backups)."""
    client = get_s3_client()
    try:
        client.copy_object(
            Bucket=settings.AWS_STORAGE_BUCKET_NAME,
            CopySource={'Bucket': settings.AWS_STORAGE_BUCKET_NAME, 'Key': source_key},
            Key=dest_key,
            ServerSideEncryption='AES256',
        )
        return True, None
    except ClientError as e:
        logger.error(f"S3 copy error from {source_key} to {dest_key}: {e}")
        return False, str(e)


def list_user_files_in_s3(user):
    """List all files in a user's S3 directory."""
    client = get_s3_client()
    prefix = get_user_s3_prefix(user)
    try:
        paginator = client.get_paginator('list_objects_v2')
        pages = paginator.paginate(
            Bucket=settings.AWS_STORAGE_BUCKET_NAME,
            Prefix=prefix,
        )
        files = []
        for page in pages:
            for obj in page.get('Contents', []):
                files.append({
                    'key': obj['Key'],
                    'size': obj['Size'],
                    'last_modified': obj['LastModified'],
                })
        return files
    except ClientError as e:
        logger.error(f"S3 list error for {prefix}: {e}")
        return []


def get_file_metadata_from_s3(s3_key):
    """Get metadata for a specific S3 object."""
    client = get_s3_client()
    try:
        response = client.head_object(
            Bucket=settings.AWS_STORAGE_BUCKET_NAME,
            Key=s3_key,
        )
        return {
            'size': response['ContentLength'],
            'content_type': response.get('ContentType', ''),
            'last_modified': response['LastModified'],
        }
    except ClientError as e:
        logger.error(f"S3 metadata error for {s3_key}: {e}")
        return None


def check_s3_connection():
    """Test S3 connectivity."""
    client = get_s3_client()
    try:
        client.head_bucket(Bucket=settings.AWS_STORAGE_BUCKET_NAME)
        return True
    except ClientError:
        return False
