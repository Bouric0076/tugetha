package com.sinaps.tugetha.modules.ledger;

import java.util.Map;
import java.util.Set;

public enum TransactionStatus {
    INITIATED,
    PROCESSING,
    COMPLETED,
    FAILED,
    REVERSED;

    private static final Map<TransactionStatus, Set<TransactionStatus>> VALID_TRANSITIONS = Map.of(
            INITIATED, Set.of(PROCESSING, COMPLETED, FAILED),
            PROCESSING, Set.of(COMPLETED, FAILED),
            COMPLETED, Set.of(REVERSED),
            FAILED, Set.of(),
            REVERSED, Set.of()
    );

    public void validateTransition(TransactionStatus next) {
        if (!VALID_TRANSITIONS.get(this).contains(next)) {
            throw new IllegalStateException("Invalid transaction transition from " + this + " to " + next);
        }
    }
}
