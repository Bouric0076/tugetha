from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from decimal import Decimal
import logging

from .models import Transaction, PaystackService
from apps.ledger.models import Account, LedgerService
from common.idempotency import IdempotencyGuard
from common.firebase_sync import sync_wallet_balance, sync_transaction

logger = logging.getLogger(__name__)


class InitializePaymentView(APIView):
    """
    Endpoint for Flutter app to start a payment (Top Up, Loan Repayment, etc.)
    """

    def post(self, request):
        user_uid = request.user.username  # Firebase UID
        phone = request.data.get('phone')
        amount = Decimal(str(request.data.get('amount', '0')))
        tx_type = request.data.get('type')  # top_up, loan_repayment, etc.
        receiver_uid = request.data.get('receiver_uid')
        idempotency_key = request.data.get('idempotency_key')

        if not phone or amount <= 0 or not tx_type:
            return Response(
                {
                    'success': False,
                    'error': 'Missing or invalid parameters.',
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        # 1. Idempotency Check
        if idempotency_key:
            if not IdempotencyGuard.check_and_lock(idempotency_key):
                return Response(
                    {
                        'success': False,
                        'error': 'Duplicate request detected.',
                    },
                    status=status.HTTP_409_CONFLICT,
                )

        try:
            # 2. Prepare Receiver Subaccount (if P2P like loan repayment)
            subaccount = None
            if receiver_uid:
                acc = Account.objects.filter(owner_uid=receiver_uid).first()
                if acc and acc.metadata.get('paystack_subaccount_code'):
                    subaccount = acc.metadata['paystack_subaccount_code']

            # 3. Call Paystack API
            data = PaystackService.initialize_payment(
                user_uid=user_uid,
                phone=phone,
                amount=amount,
                tx_type=tx_type,
                receiver_subaccount=subaccount,
            )

            # 4. Record pending transaction in Django
            Transaction.objects.create(
                user_uid=user_uid,
                reference=data['reference'],
                amount=amount,
                type=tx_type,
                status='processing',
                phone=phone,
                email=f"{phone}@tugetha.com",
                subaccount_code=subaccount,
                metadata={'idempotency_key': idempotency_key},
            )

            return Response(
                {
                    'success': True,
                    'reference': data['reference'],
                    'status': 'processing',
                },
                status=status.HTTP_200_OK,
            )
        except Exception as e:
            if idempotency_key:
                IdempotencyGuard.mark_failed(idempotency_key)
            logger.error(f'Initialization failed for {user_uid}: {e}')
            return Response(
                {'success': False, 'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


class VerifyPaymentView(APIView):
    """
    Endpoint for Flutter app to manually trigger verification.
    Most verification should happen via Webhooks.
    """

    def get(self, request, reference):
        user_uid = request.user.username
        
        tx = Transaction.objects.filter(
            reference=reference,
            user_uid=user_uid
        ).first()

        if not tx:
            return Response(
                {'success': False, 'error': 'Transaction not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        # If already success, return immediately
        if tx.status == 'success':
            return Response(
                {
                    'success': True,
                    'status': 'success',
                    'amount': tx.amount,
                },
                status=status.HTTP_200_OK,
            )

        # 1. Check with Paystack
        data = PaystackService.verify_payment(reference)
        
        if data.get('status') and data.get('data', {}).get('status') == 'success':
            # 2. Process success logic (Atomic ledger movement)
            # This logic should be shared with the Webhook view
            from .services import process_successful_payment
            
            success = process_successful_payment(tx, data['data'])
            
            if success:
                return Response(
                    {
                        'success': True,
                        'status': 'success',
                        'amount': tx.amount,
                    },
                    status=status.HTTP_200_OK,
                )
        
        return Response(
            {
                'success': True,
                'status': tx.status,
                'message': 'Payment is still processing or failed.',
            },
            status=status.HTTP_200_OK,
        )
