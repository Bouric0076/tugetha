package com.sinaps.tugetha.modules.wallet;

import com.sinaps.tugetha.modules.ledger.AccountType;
import com.sinaps.tugetha.modules.ledger.EntryType;
import com.sinaps.tugetha.modules.ledger.LedgerEntryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
public class WalletQueryService {

    private final LedgerEntryRepository ledgerEntryRepository;

    public WalletQueryService(LedgerEntryRepository ledgerEntryRepository) {
        this.ledgerEntryRepository = ledgerEntryRepository;
    }

    @Transactional(readOnly = true)
    public BigDecimal balance(Long userId) {
        BigDecimal credits = ledgerEntryRepository
                .sumByUserAccountAndEntryType(userId, AccountType.USER_WALLET, EntryType.CREDIT)
                .orElse(BigDecimal.ZERO);
        BigDecimal debits = ledgerEntryRepository
                .sumByUserAccountAndEntryType(userId, AccountType.USER_WALLET, EntryType.DEBIT)
                .orElse(BigDecimal.ZERO);
        return credits.subtract(debits);
    }
}
