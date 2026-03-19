from django.core.cache import cache
import logging

logger = logging.getLogger(__name__)


class IdempotencyGuard:
    """
    Prevents duplicate processing of the same request.
    Uses Redis to track processed idempotency keys.
    """

    PREFIX = 'idempotency:'
    TTL = 86400 * 7  # 7 days

    @classmethod
    def check_and_lock(cls, key: str) -> bool:
        """
        Returns True if key is new (safe to process).
        Returns False if key already exists (duplicate).
        """
        cache_key = f'{cls.PREFIX}{key}'
        result = cache.add(cache_key, 'processing', cls.TTL)
        if not result:
            logger.warning(
                f'Duplicate idempotency key detected: {key}'
            )
        return result

    @classmethod
    def mark_complete(cls, key: str) -> None:
        cache_key = f'{cls.PREFIX}{key}'
        cache.set(cache_key, 'completed', cls.TTL)

    @classmethod
    def mark_failed(cls, key: str) -> None:
        """Release lock on failure so it can be retried."""
        cache_key = f'{cls.PREFIX}{key}'
        cache.delete(cache_key)

    @classmethod
    def is_completed(cls, key: str) -> bool:
        cache_key = f'{cls.PREFIX}{key}'
        return cache.get(cache_key) == 'completed'
