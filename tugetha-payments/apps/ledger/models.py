from django.db import models
from django.db import transaction as db_transaction
from django.conf import settings
from decimal import Decimal
import logging

logger = logging.getLogger(__name__)


class Account(models.Model):
    """
    Represents a double-entry ledger account.
    Each user has a single 'user_wallet' account.
    System accounts include 'tugetha_facilitation_fees', 'mpesa_float'.
    """

    ACCOUNT_TYPES = (
        ('user_wallet', 'User Wallet'),
        ('system_fees', 'System Facilitation Fees'),
        ('system_escrow', 'System Escrow'),
        ('mpesa_float', 'M-Pesa Float (External)'),
    )

    owner_uid = models.CharField(
        max_length=128,
        unique=True,
        db_index=True,
        help_text="Firebase UID or system name."
    )
    account_type = models.CharField(
        max_length=20,
        choices=ACCOUNT_TYPES,
        default='user_wallet'
    )
    balance = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=Decimal('0.00')
    )
    last_transaction_id = models.CharField(
        max_length=128,
        blank=True,
        null=True
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.owner_uid} ({self.account_type})"


class LedgerEntry(models.Model):
    """
    Records a single transaction (Double Entry).
    Every credit MUST have a corresponding debit.
    """

    TRANSACTION_TYPES = (
        ('top_up', 'Wallet Top Up'),
        ('withdrawal', 'Withdrawal'),
        ('loan_disbursement', 'Loan Disbursement'),
        ('loan_repayment', 'Loan Repayment'),
        ('platform_fee', 'Platform Facilitation Fee'),
        ('goal_contribution', 'Goal Contribution'),
    )

    transaction_id = models.CharField(
        max_length=128,
        db_index=True,
        help_text="Common ID for the debit/credit pair."
    )
    debit_account = models.ForeignKey(
        Account,
        related_name='debits',
        on_delete=models.PROTECT
    )
    credit_account = models.ForeignKey(
        Account,
        related_name='credits',
        on_delete=models.PROTECT
    )
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    type = models.CharField(
        max_length=20,
        choices=TRANSACTION_TYPES
    )
    description = models.TextField(blank=True)
    metadata = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name_plural = "Ledger Entries"
        indexes = [
            models.Index(fields=['transaction_id']),
            models.Index(fields=['type']),
            models.Index(fields=['created_at']),
        ]


class LedgerService:
    """
    Handles atomic ledger movements.
    """

    @classmethod
    @db_transaction.atomic
    def move_funds(
        cls,
        from_account_uid: str,
        to_account_uid: str,
        amount: Decimal,
        tx_type: str,
        tx_id: str,
        description: str = "",
        metadata: dict = None
    ) -> LedgerEntry:
        """
        Atomically transfers funds between accounts.
        Locks both accounts to prevent race conditions.
        """
        if amount <= 0:
            raise ValueError("Amount must be positive.")

        # 1. Fetch and Lock accounts (alphabetical order to prevent deadlocks)
        uids = sorted([from_account_uid, to_account_uid])
        accounts = {
            acc.owner_uid: acc
            for acc in Account.objects.select_for_update() \
                                     .filter(owner_uid__in=uids)
        }

        from_acc = accounts.get(from_account_uid)
        to_acc = accounts.get(to_account_uid)

        if not from_acc or not to_acc:
            raise ValueError("One or both accounts not found.")

        # 2. Check balance (only for user/system accounts, not float)
        if from_acc.account_type != 'mpesa_float' and from_acc.balance < amount:
            raise ValueError(
                f"Insufficient balance in {from_account_uid}"
            )

        # 3. Update balances
        from_acc.balance -= amount
        from_acc.last_transaction_id = tx_id
        from_acc.save()

        to_acc.balance += amount
        to_acc.last_transaction_id = tx_id
        to_acc.save()

        # 4. Record ledger entry
        entry = LedgerEntry.objects.create(
            transaction_id=tx_id,
            debit_account=from_acc,
            credit_account=to_acc,
            amount=amount,
            type=tx_type,
            description=description,
            metadata=metadata or {}
        )

        logger.info(
            f"Ledger: Moved KES {amount} from {from_account_uid} to {to_account_uid}"
        )
        return entry
