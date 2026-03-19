import firebase_admin
from firebase_admin import auth, credentials
from django.conf import settings
from django.contrib.auth import get_user_model
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
import logging

logger = logging.getLogger(__name__)
User = get_user_model()

# Initialize Firebase Admin once
try:
    firebase_admin.get_app()
except ValueError:
    try:
        cred = credentials.Certificate(
            settings.FIREBASE_CREDENTIALS_PATH
        )
        firebase_admin.initialize_app(cred)
    except Exception as e:
        logger.warning(f"Could not initialize Firebase Admin: {e}. Authentication will fail.")


class FirebaseAuthentication(BaseAuthentication):
    """
    Verifies Firebase JWT tokens from Flutter app.
    Creates Django user on first login.
    """

    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return None

        token = auth_header.split(' ')[1]

        try:
            decoded = auth.verify_id_token(token)
        except auth.ExpiredIdTokenError:
            raise AuthenticationFailed('Token expired.')
        except auth.InvalidIdTokenError:
            raise AuthenticationFailed('Invalid token.')
        except Exception as e:
            logger.error(f'Firebase auth error: {e}')
            raise AuthenticationFailed('Authentication failed.')

        firebase_uid = decoded['uid']
        
        # Get or create Django user
        user, created = User.objects.get_or_create(
            username=firebase_uid,
            defaults={
                'first_name': decoded.get('name', '').split(' ')[0] if decoded.get('name') else '',
                'last_name': ' '.join(decoded.get('name', '').split(' ')[1:]) if decoded.get('name') else '',
            }
        )

        if created:
            logger.info(
                f'New user created from Firebase: {firebase_uid}'
            )

        return (user, decoded)
