from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status
import logging

logger = logging.getLogger(__name__)


def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    if response is not None:
        response.data = {
            'success': False,
            'error': response.data,
            'status_code': response.status_code,
        }
        return response

    # Unhandled exceptions
    logger.exception(
        f'Unhandled exception in {context["view"].__class__.__name__}: {exc}'
    )
    return Response(
        {
            'success': False,
            'error': 'An internal server error occurred.',
            'status_code': 500,
        },
        status=status.HTTP_500_INTERNAL_SERVER_ERROR,
    )


class InsufficientBalanceError(Exception):
    pass


class IdempotencyError(Exception):
    pass


class PaystackError(Exception):
    pass


class TransactionStateError(Exception):
    pass
