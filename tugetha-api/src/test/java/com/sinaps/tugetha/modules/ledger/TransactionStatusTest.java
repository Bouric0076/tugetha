package com.sinaps.tugetha.modules.ledger;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;

class TransactionStatusTest {

    @Test
    void allowsValidTransitions() {
        assertDoesNotThrow(() -> TransactionStatus.INITIATED.validateTransition(TransactionStatus.PROCESSING));
        assertDoesNotThrow(() -> TransactionStatus.INITIATED.validateTransition(TransactionStatus.COMPLETED));
        assertDoesNotThrow(() -> TransactionStatus.INITIATED.validateTransition(TransactionStatus.FAILED));
        assertDoesNotThrow(() -> TransactionStatus.PROCESSING.validateTransition(TransactionStatus.COMPLETED));
        assertDoesNotThrow(() -> TransactionStatus.PROCESSING.validateTransition(TransactionStatus.FAILED));
        assertDoesNotThrow(() -> TransactionStatus.COMPLETED.validateTransition(TransactionStatus.REVERSED));
    }

    @Test
    void rejectsInvalidTransitions() {
        assertThrows(IllegalStateException.class,
                () -> TransactionStatus.COMPLETED.validateTransition(TransactionStatus.PROCESSING));
        assertThrows(IllegalStateException.class,
                () -> TransactionStatus.FAILED.validateTransition(TransactionStatus.COMPLETED));
        assertThrows(IllegalStateException.class,
                () -> TransactionStatus.REVERSED.validateTransition(TransactionStatus.COMPLETED));
    }
}
