from django.urls import path
from .views import DisburseLoanView, RepayLoanView

urlpatterns = [
    path('disburse/', DisburseLoanView.as_view(), name='disburse_loan'),
    path('repay/', RepayLoanView.as_view(), name='repay_loan'),
]
