import firebase_admin
from firebase_admin import firestore
from django.conf import settings
import logging

logger = logging.getLogger(__name__)


def get_firestore_client():
    try:
        return firestore.client()
    except Exception as e:
        logger.error(f'Firestore client error: {e}')
        raise


def sync_wallet_balance(firebase_uid: str, balance: float) -> bool:
    """
    Syncs the authoritative Django ledger balance
    to Firestore for Flutter UI display.
    This is ONE-WAY: Django → Firestore only.
    Firestore balance is display only, never trusted for payments.
    """
    try:
        db = get_firestore_client()
        db.collection('users').document(firebase_uid).update({
            'walletBalance': float(balance),
            'balanceLastSyncedAt': firestore.SERVER_TIMESTAMP,
        })
        logger.info(
            f'Synced balance for {firebase_uid}: KES {balance}'
        )
        return True
    except Exception as e:
        logger.error(
            f'Failed to sync balance for {firebase_uid}: {e}'
        )
        return False


def sync_transaction(
    firebase_uid: str,
    transaction_data: dict
) -> bool:
    """
    Adds a transaction record to Firestore
    for display in the Flutter transaction history.
    """
    try:
        db = get_firestore_client()
        db.collection('users') \
          .document(firebase_uid) \
          .collection('transactions') \
          .add({
            **transaction_data,
            'createdAt': firestore.SERVER_TIMESTAMP,
            'source': 'django_payment_backend',
        })
        return True
    except Exception as e:
        logger.error(
            f'Failed to sync transaction for {firebase_uid}: {e}'
        )
        return False
