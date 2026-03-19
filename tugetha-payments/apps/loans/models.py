from django.db import models
from decimal import Decimal
import logging

logger = logging.getLogger(__name__)


class Loan(models.Model):
    """
    Tracks lifecycle of Loans between users.
    Disbursement and repayment are handled by Ledger movements.
    """

    STATUS_CHOICES = (
        ('pending', 'Pending Review'),
        ('active', 'Active (Disbursed)'),
        ('overdue', 'Overdue'),
        ('completed', 'Fully Repaid'),
        ('defaulted', 'Defaulted'),
    )

    borrower_uid = models.CharField(max_length=128, db_index=True)
    lender_uid = models.CharField(max_length=128, db_index=True)
    loan_id = models.CharField(
        max_length=128,
        unique=True,
        db_index=True,
        help_text="Firestore Loan ID."
    )
    principal_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2
    )
    interest_rate = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=Decimal('5.00')
    )
    total_repayable = models.DecimalField(
        max_digits=12,
        decimal_places=2
    )
    remaining_balance = models.DecimalField(
        max_digits=12,
        decimal_places=2
    )
    platform_fee = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=Decimal('0.00')
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending'
    )
    due_date = models.DateTimeField()
    disbursed_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Loan {self.loan_id}: {self.status}"


class LoanRepayment(models.Model):
    """
    Records an individual repayment installment.
    """

    loan = models.ForeignKey(
        Loan,
        related_name='repayments',
        on_delete=models.CASCADE
    )
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    transaction_id = models.CharField(
        max_length=128,
        db_index=True,
        help_text="Common Ledger ID for this repayment."
    )
    repaid_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Repayment {self.amount} for Loan {self.loan.loan_id}"
