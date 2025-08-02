from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
import jwt
from jwt.exceptions import ExpiredSignatureError, InvalidTokenError
from .models import CustomUser, BlacklistedToken
from django.conf import settings
import logging


logger = logging.getLogger(__name__)

class JWTAuthentication(BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            logger.warning("Missing Authorization header")
            raise AuthenticationFailed("Authorization header is missing!")
        if not auth_header.startswith('Bearer '):
            raise AuthenticationFailed("Invalid token prefix! Use 'Bearer'.")
        
        token = auth_header.split(' ')[1]
        if BlacklistedToken.objects.filter(token=token).exists():
            raise AuthenticationFailed("Token has been blacklisted!")
        try:
            payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
            user = CustomUser.objects.get(id=payload['user_id'])

            if user.username != payload['username']:
                raise AuthenticationFailed("Token payload mismatch!")
            return (user, token)
        
        except ExpiredSignatureError:
            raise AuthenticationFailed("Your token has expired!")
        
        except CustomUser.DoesNotExist:
            raise AuthenticationFailed("User not found!")
        
        except InvalidTokenError:
            raise AuthenticationFailed("You have provided an invalid token!")
        
    def authenticate_header(self, request):
        return 'Bearer'
    