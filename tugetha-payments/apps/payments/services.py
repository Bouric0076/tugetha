from django.db import transaction as db_transaction
from decimal import Decimal
import logging

from .models import Transaction
from apps.ledger.models import Account, LedgerService
from common.firebase_sync import sync_wallet_balance, sync_transaction
from common.idempotency import IdempotencyGuard

logger = logging.getLogger(__name__)


@db_transaction.atomic
def process_successful_payment(tx: Transaction, paystack_data: dict) -> bool:
    """
    Atomically moves funds into the user's ledger
    and syncs the new balance to Firestore.
    Shared by both VerifyView and WebhookView.
    """
    if tx.status == 'success':
        logger.info(
            f"Transaction {tx.reference} already processed."
        )
        return True

    # 1. Update Django Transaction Status
    tx.status = 'success'
    tx.metadata['paystack_data'] = paystack_data
    tx.save()

    # 2. Ledger Movement
    try:
        amount = tx.amount
        tx_type = tx.type
        
        if tx_type == 'top_up':
            # M-Pesa Float (External) → User Wallet (Internal)
            LedgerService.move_funds(
                from_account_uid='mpesa_float',
                to_account_uid=tx.user_uid,
                amount=amount,
                tx_type=tx_type,
                tx_id=tx.reference,
                description=f"Top Up via Paystack/M-Pesa ({tx.phone})",
            )
        elif tx_type == 'goal_contribution':
            # 1. First Top Up the User's Wallet from Float
            LedgerService.move_funds(
                from_account_uid='mpesa_float',
                to_account_uid=tx.user_uid,
                amount=amount,
                tx_type='top_up',
                tx_id=f"topup_{tx.reference}",
                description="Auto-topup for goal contribution",
            )
            
            # 2. Then move from User Wallet to Group Escrow
            group_id = tx.metadata.get('group_id', 'system_escrow')
            LedgerService.move_funds(
                from_account_uid=tx.user_uid,
                to_account_uid=f"group_{group_id}",
                amount=amount,
                tx_type=tx_type,
                tx_id=tx.reference,
                description=f"Contribution to group {group_id}",
            )
        elif tx_type == 'p2p_transfer':
            # Handle direct user-to-user via subaccounts if needed
            # For now, we assume funds are already in subaccount
            pass

        # 3. Mark Idempotency Key as Completed
        idempotency_key = tx.metadata.get('idempotency_key')
        if idempotency_key:
            IdempotencyGuard.mark_complete(idempotency_key)

        # 4. Sync to Firebase (Fire-and-forget or async task)
        # We fetch the latest balance from Django Ledger
        account = Account.objects.get(owner_uid=tx.user_uid)
        sync_wallet_balance(tx.user_uid, float(account.balance))
        
        sync_transaction(tx.user_uid, {
            'type': tx.type,
            'amount': float(tx.amount),
            'reference': tx.reference,
            'status': 'success',
            'description': f"Top Up via Paystack/M-Pesa ({tx.phone})",
        })

        logger.info(
            f"Processed success for {tx.reference} for user {tx.user_uid}"
        )
        return True
    except Exception as e:
        logger.error(
            f"Failed to move funds for {tx.reference}: {e}"
        )
        # Transaction will be rolled back by db_transaction.atomic
        return False
