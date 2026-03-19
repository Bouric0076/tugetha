from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.db import connections
from django.db.utils import OperationalError
from django.core.cache import cache
from django.urls import path


class HealthCheckView(APIView):
    """
    Checks status of DB, Redis, and overall API.
    """
    authentication_classes = []
    permission_classes = []

    def get(self, request):
        health_status = {
            'status': 'healthy',
            'database': 'up',
            'cache': 'up',
        }
        
        # Check DB
        db_conn = connections['default']
        try:
            db_conn.cursor()
        except OperationalError:
            health_status['database'] = 'down'
            health_status['status'] = 'degraded'

        # Check Redis
        try:
            cache.set('health_check', 'ok', timeout=5)
            if cache.get('health_check') != 'ok':
                health_status['cache'] = 'down'
                health_status['status'] = 'degraded'
        except Exception:
            health_status['cache'] = 'down'
            health_status['status'] = 'degraded'

        return Response(
            health_status,
            status=status.HTTP_200_OK if health_status['status'] == 'healthy' else status.HTTP_503_SERVICE_UNAVAILABLE
        )


urlpatterns = [
    path('', HealthCheckView.as_view(), name='health_check'),
]
