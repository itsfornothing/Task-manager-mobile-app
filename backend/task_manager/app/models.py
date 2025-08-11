from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import RegexValidator

class CustomUser(AbstractUser):
    email = models.EmailField(unique=True)
    fullname = models.CharField(max_length=50, validators=[RegexValidator(r'^[a-zA-Z\s-]+$', 'Full name can only contain letters, spaces, or hyphens.')])
    username = models.CharField(max_length=150, unique=False, blank=True, null=True)
    profile_url = models.CharField(max_length=1250, blank=True, null=True)
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['fullname']

class Project(models.Model):
    title = models.CharField(max_length=255)
    owner = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='projects')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ['owner', 'title']

class Task(models.Model):
    title = models.CharField(max_length=255)
    deadline = models.DateField()
    in_project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='tasks')
    is_completed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ['in_project', 'title']


class BlacklistedToken(models.Model):
    token = models.CharField(max_length=500, unique=True)
    blacklisted_at = models.DateTimeField(auto_now_add=True)
    class Meta:
        db_table = 'blacklisted_tokens'