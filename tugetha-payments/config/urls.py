from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/payments/', include('apps.payments.urls')),
    path('api/loans/', include('apps.loans.urls')),
    path('api/ledger/', include('apps.ledger.urls')),
    path('api/webhooks/', include('apps.webhooks.urls')),
    path('api/health/', include('common.health')),
]
