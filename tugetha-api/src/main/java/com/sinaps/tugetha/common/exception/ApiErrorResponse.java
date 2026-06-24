package com.sinaps.tugetha.common.exception;

import java.time.Instant;

public record ApiErrorResponse(
        String code,
        String message,
        String correlationId,
        Instant timestamp
) {
}
