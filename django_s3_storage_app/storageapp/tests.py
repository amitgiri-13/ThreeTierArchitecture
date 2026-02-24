from django.test import TestCase, Client
from django.contrib.auth.models import User
from django.urls import reverse
from unittest.mock import patch, MagicMock
from storageapp.models import UserFile, Folder, BackupJob
from accounts.models import UserProfile


class AccountTests(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(
            username='testuser', password='TestPass123!', email='test@example.com'
        )
        UserProfile.objects.create(user=self.user)

    def test_login_page_loads(self):
        response = self.client.get(reverse('login'))
        self.assertEqual(response.status_code, 200)

    def test_register_page_loads(self):
        response = self.client.get(reverse('register'))
        self.assertEqual(response.status_code, 200)

    def test_login_success(self):
        response = self.client.post(reverse('login'), {
            'username': 'testuser',
            'password': 'TestPass123!',
        })
        self.assertRedirects(response, reverse('dashboard'))

    def test_login_failure(self):
        response = self.client.post(reverse('login'), {
            'username': 'testuser',
            'password': 'wrongpassword',
        })
        self.assertEqual(response.status_code, 200)

    def test_register_creates_user(self):
        response = self.client.post(reverse('register'), {
            'username': 'newuser',
            'email': 'new@example.com',
            'password1': 'NewPass123!',
            'password2': 'NewPass123!',
        })
        self.assertTrue(User.objects.filter(username='newuser').exists())
        self.assertTrue(UserProfile.objects.filter(user__username='newuser').exists())

    def test_dashboard_requires_login(self):
        response = self.client.get(reverse('dashboard'))
        self.assertRedirects(response, f"{reverse('login')}?next={reverse('dashboard')}")

    def test_dashboard_accessible_when_logged_in(self):
        self.client.login(username='testuser', password='TestPass123!')
        response = self.client.get(reverse('dashboard'))
        self.assertEqual(response.status_code, 200)

    def test_logout(self):
        self.client.login(username='testuser', password='TestPass123!')
        response = self.client.get(reverse('logout'))
        self.assertRedirects(response, reverse('login'))


class FileModelTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='fileuser', password='pass123')
        UserProfile.objects.create(user=self.user)

    def test_file_type_detection(self):
        test_cases = [
            ('photo.jpg', 'image'),
            ('video.mp4', 'video'),
            ('doc.pdf', 'document'),
            ('sheet.xlsx', 'spreadsheet'),
            ('archive.zip', 'archive'),
            ('script.py', 'code'),
            ('random.xyz', 'other'),
        ]
        for filename, expected_type in test_cases:
            f = UserFile(
                user=self.user,
                name=filename,
                original_name=filename,
                s3_key=f'users/1/{filename}',
            )
            self.assertEqual(f.get_file_type(), expected_type)

    def test_format_size(self):
        f = UserFile(user=self.user, name='test', original_name='test', s3_key='k', file_size=1024)
        self.assertEqual(f.format_size(), '1.0 KB')

        f.file_size = 1024 * 1024
        self.assertEqual(f.format_size(), '1.0 MB')

    def test_folder_creation(self):
        folder = Folder.objects.create(user=self.user, name='TestFolder')
        self.assertEqual(str(folder), 'TestFolder')
        self.assertIsNone(folder.parent)


class StorageViewTests(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(username='viewuser', password='ViewPass123!')
        UserProfile.objects.create(user=self.user)
        self.client.login(username='viewuser', password='ViewPass123!')

    def test_file_list_view(self):
        response = self.client.get(reverse('file_list'))
        self.assertEqual(response.status_code, 200)

    def test_upload_page_loads(self):
        response = self.client.get(reverse('upload'))
        self.assertEqual(response.status_code, 200)

    def test_backup_history_loads(self):
        response = self.client.get(reverse('backup_history'))
        self.assertEqual(response.status_code, 200)

    @patch('storageapp.views.upload_file_to_s3')
    def test_file_upload(self, mock_upload):
        mock_upload.return_value = (True, None)
        from io import BytesIO
        from django.core.files.uploadedfile import SimpleUploadedFile
        
        test_file = SimpleUploadedFile('test.txt', b'Hello, World!', content_type='text/plain')
        response = self.client.post(reverse('upload'), {
            'files': test_file,
        })
        self.assertRedirects(response, reverse('file_list'))
        self.assertTrue(UserFile.objects.filter(user=self.user, original_name='test.txt').exists())

    @patch('storageapp.views.delete_file_from_s3')
    def test_file_delete(self, mock_delete):
        mock_delete.return_value = (True, None)
        user_file = UserFile.objects.create(
            user=self.user,
            name='todelete.txt',
            original_name='todelete.txt',
            s3_key='users/1/todelete.txt',
            file_size=100,
        )
        response = self.client.post(reverse('delete_file', kwargs={'file_id': user_file.id}))
        self.assertRedirects(response, reverse('file_list'))
        self.assertFalse(UserFile.objects.filter(id=user_file.id).exists())

    def test_create_folder(self):
        response = self.client.post(reverse('create_folder'), {'name': 'NewFolder'})
        self.assertRedirects(response, reverse('file_list'))
        self.assertTrue(Folder.objects.filter(user=self.user, name='NewFolder').exists())

    def test_user_isolation(self):
        """Users should not see each other's files"""
        other_user = User.objects.create_user(username='other', password='OtherPass123!')
        other_file = UserFile.objects.create(
            user=other_user,
            name='private.txt',
            original_name='private.txt',
            s3_key='users/2/private.txt',
        )
        response = self.client.get(reverse('file_detail', kwargs={'file_id': other_file.id}))
        self.assertEqual(response.status_code, 404)


class S3UtilsTests(TestCase):
    @patch('storageapp.s3_utils.boto3.client')
    def test_upload_success(self, mock_boto):
        from storageapp.s3_utils import upload_file_to_s3
        mock_client = MagicMock()
        mock_boto.return_value = mock_client
        mock_client.upload_fileobj.return_value = None

        from io import BytesIO
        result, error = upload_file_to_s3(BytesIO(b'test'), 'users/1/test.txt')
        self.assertTrue(result)
        self.assertIsNone(error)

    @patch('storageapp.s3_utils.boto3.client')
    def test_upload_failure(self, mock_boto):
        from storageapp.s3_utils import upload_file_to_s3
        from botocore.exceptions import ClientError
        mock_client = MagicMock()
        mock_boto.return_value = mock_client
        mock_client.upload_fileobj.side_effect = ClientError(
            {'Error': {'Code': 'NoSuchBucket', 'Message': 'Bucket not found'}},
            'upload_fileobj'
        )

        from io import BytesIO
        result, error = upload_file_to_s3(BytesIO(b'test'), 'users/1/test.txt')
        self.assertFalse(result)
        self.assertIsNotNone(error)
