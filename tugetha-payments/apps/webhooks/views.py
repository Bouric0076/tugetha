from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
import hmac
import hashlib
import json
import logging
from django.conf import settings

from apps.payments.models import Transaction
from apps.payments.services import process_successful_payment

logger = logging.getLogger(__name__)


class PaystackWebhookView(APIView):
    """
    Handles asynchronous callbacks from Paystack.
    Verifies HMAC signature for security.
    """
    
    # Disable authentication for webhooks
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        # 1. Verify Paystack Signature
        paystack_signature = request.headers.get('x-paystack-signature')
        if not paystack_signature:
            return Response(status=status.HTTP_401_UNAUTHORIZED)

        payload = request.body
        computed_hmac = hmac.new(
            settings.PAYSTACK_WEBHOOK_SECRET.encode('utf-8'),
            payload,
            hashlib.sha512
        ).hexdigest()

        if paystack_signature != computed_hmac:
            logger.warning(
                f"Invalid webhook signature: {paystack_signature}"
            )
            return Response(status=status.HTTP_401_UNAUTHORIZED)

        # 2. Parse Event
        event_data = json.loads(payload)
        event_type = event_data.get('event')

        logger.info(f"Paystack Webhook Received: {event_type}")

        if event_type == 'charge.success':
            data = event_data.get('data', {})
            reference = data.get('reference')
            
            tx = Transaction.objects.filter(reference=reference).first()
            if tx:
                process_successful_payment(tx, data)
                return Response(status=status.HTTP_200_OK)
            else:
                logger.error(
                    f"Webhook: Transaction not found for ref {reference}"
                )

        # Return 200 to acknowledge receipt even if we don't handle it
        return Response(status=status.HTTP_200_OK)
