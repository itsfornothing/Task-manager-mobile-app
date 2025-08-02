from django.contrib.auth.backends import ModelBackend
from .models import CustomUser


class EmailBackend(ModelBackend):
    def authenticate(self, request, email=None, password=None, **kwargs):
        try:
            users = CustomUser.objects.filter(email__iexact=email.lower())
            if users.count() == 1 and users[0].check_password(password):
                return users[0]
            return None
        except CustomUser.DoesNotExist:
            return None