from django.db import models
from django.conf import settings
from decimal import Decimal
import logging

logger = logging.getLogger(__name__)


class Transaction(models.Model):
    """
    Tracks lifecycle of Paystack (M-Pesa) payments.
    """

    TRANSACTION_TYPES = (
        ('top_up', 'Wallet Top Up'),
        ('withdrawal', 'Withdrawal'),
        ('loan_disbursement', 'Loan Disbursement'),
        ('loan_repayment', 'Loan Repayment'),
        ('goal_contribution', 'Goal Contribution'),
    )

    STATUS_CHOICES = (
        ('pending', 'Pending Initialization'),
        ('processing', 'STK Push Sent'),
        ('success', 'Success (Verified)'),
        ('failed', 'Failed'),
        ('reversed', 'Reversed'),
        ('abandoned', 'Abandoned by User'),
    )

    user_uid = models.CharField(max_length=128, db_index=True)
    reference = models.CharField(
        max_length=128,
        unique=True,
        db_index=True,
        help_text="Paystack reference ID."
    )
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    currency = models.CharField(max_length=3, default='KES')
    type = models.CharField(
        max_length=20,
        choices=TRANSACTION_TYPES
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending'
    )
    phone = models.CharField(max_length=15)
    email = models.EmailField()
    subaccount_code = models.CharField(
        max_length=64,
        blank=True,
        null=True,
        help_text="Receiver's Paystack Subaccount for Split Payments."
    )
    metadata = models.JSONField(default=dict, blank=True)
    error_message = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.reference} ({self.status})"

    class Meta:
        ordering = ['-created_at']


class PaystackService:
    """
    Orchestrates Paystack API calls.
    """

    @staticmethod
    def initialize_payment(
        user_uid: str,
        phone: str,
        amount: Decimal,
        tx_type: str,
        receiver_subaccount: str = None,
        metadata: dict = None
    ) -> dict:
        import requests
        from common.exceptions import PaystackError

        url = f"{settings.PAYSTACK_BASE_URL}/charge"
        headers = {
            "Authorization": f"Bearer {settings.PAYSTACK_SECRET_KEY}",
            "Content-Type": "application/json",
        }

        payload = {
            "email": f"{phone}@tugetha.com",
            "amount": int(amount * 100),  # KES to Cents
            "currency": "KES",
            "mobile_money": {
                "phone": phone,
                "provider": "mpesa",
            },
            "metadata": {
                "user_uid": user_uid,
                "tx_type": tx_type,
                **(metadata or {})
            }
        }

        if receiver_subaccount:
            payload["subaccount"] = receiver_subaccount
            # Facilitation fee (2.5%) is already set on the subaccount

        try:
            response = requests.post(
                url,
                json=payload,
                headers=headers,
                timeout=10
            )
            data = response.json()

            if not data.get('status'):
                raise PaystackError(
                    data.get('message', 'Initialization failed.')
                )

            return data['data']
        except Exception as e:
            logger.error(f"Paystack initialization error: {e}")
            raise PaystackError(str(e))

    @staticmethod
    def verify_payment(reference: str) -> dict:
        import requests
        url = f"{settings.PAYSTACK_BASE_URL}/transaction/verify/{reference}"
        headers = {
            "Authorization": f"Bearer {settings.PAYSTACK_SECRET_KEY}",
        }

        try:
            response = requests.get(
                url,
                headers=headers,
                timeout=10
            )
            return response.json()
        except Exception as e:
            logger.error(f"Paystack verification error: {e}")
            return {"status": False, "message": str(e)}
