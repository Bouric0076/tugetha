from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from decimal import Decimal
import logging

from .models import Loan, LoanRepayment
from apps.ledger.models import Account, LedgerService
from common.firebase_sync import sync_wallet_balance, sync_transaction
from common.idempotency import IdempotencyGuard

logger = logging.getLogger(__name__)


class DisburseLoanView(APIView):
    """
    Endpoint for Flutter app to trigger loan disbursement.
    """

    def post(self, request):
        lender_uid = request.user.username
        borrower_uid = request.data.get('borrower_uid')
        loan_id = request.data.get('loan_id')
        amount = Decimal(str(request.data.get('amount', '0')))
        idempotency_key = request.data.get('idempotency_key')

        if not borrower_uid or amount <= 0 or not loan_id:
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
            # 2. Process Ledger movement (Atomic)
            # Lender Wallet → Borrower Wallet
            LedgerService.move_funds(
                from_account_uid=lender_uid,
                to_account_uid=borrower_uid,
                amount=amount,
                tx_type='loan_disbursement',
                tx_id=f"loan_disb_{loan_id}",
                description=f"Disbursement for Loan {loan_id}",
            )

            # 3. Mark Idempotency Key as Completed
            if idempotency_key:
                IdempotencyGuard.mark_complete(idempotency_key)

            # 4. Sync new balances to Firestore
            for uid in [lender_uid, borrower_uid]:
                acc = Account.objects.get(owner_uid=uid)
                sync_wallet_balance(uid, float(acc.balance))
                
                sync_transaction(uid, {
                    'type': 'loan_disbursement',
                    'amount': float(amount if uid == borrower_uid else -amount),
                    'loanId': loan_id,
                    'status': 'success',
                    'description': f"Disbursement for Loan {loan_id}",
                })

            return Response(
                {
                    'success': True,
                    'status': 'disbursed',
                    'loan_id': loan_id,
                },
                status=status.HTTP_200_OK,
            )
        except Exception as e:
            if idempotency_key:
                IdempotencyGuard.mark_failed(idempotency_key)
            logger.error(f'Disbursement failed for Loan {loan_id}: {e}')
            return Response(
                {'success': False, 'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


class RepayLoanView(APIView):
    """
    Endpoint for Flutter app to trigger loan repayment from wallet.
    """

    def post(self, request):
        borrower_uid = request.user.username
        loan_id = request.data.get('loan_id')
        lender_uid = request.data.get('lender_uid')
        amount = Decimal(str(request.data.get('amount', '0')))
        idempotency_key = request.data.get('idempotency_key')

        if not lender_uid or amount <= 0 or not loan_id:
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
            # 2. Process Ledger movement (Atomic)
            # Borrower Wallet → Lender Wallet
            LedgerService.move_funds(
                from_account_uid=borrower_uid,
                to_account_uid=lender_uid,
                amount=amount,
                tx_type='loan_repayment',
                tx_id=f"loan_repay_{loan_id}_{idempotency_key}",
                description=f"Repayment for Loan {loan_id}",
            )

            # 3. Mark Idempotency Key as Completed
            if idempotency_key:
                IdempotencyGuard.mark_complete(idempotency_key)

            # 4. Sync new balances to Firestore
            for uid in [lender_uid, borrower_uid]:
                acc = Account.objects.get(owner_uid=uid)
                sync_wallet_balance(uid, float(acc.balance))
                
                sync_transaction(uid, {
                    'type': 'loan_repayment',
                    'amount': float(amount if uid == lender_uid else -amount),
                    'loanId': loan_id,
                    'status': 'success',
                    'description': f"Repayment for Loan {loan_id}",
                })

            return Response(
                {
                    'success': True,
                    'status': 'repaid',
                    'loan_id': loan_id,
                },
                status=status.HTTP_200_OK,
            )
        except Exception as e:
            if idempotency_key:
                IdempotencyGuard.mark_failed(idempotency_key)
            logger.error(f'Repayment failed for Loan {loan_id}: {e}')
            return Response(
                {'success': False, 'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
