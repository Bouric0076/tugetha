package com.sinaps.tugetha.modules.ledger;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

public interface LedgerEntryRepository extends JpaRepository<LedgerEntry, UUID> {

    @Query("""
            select coalesce(sum(e.amount), 0)
            from LedgerEntry e
            where e.user.id = :userId
              and e.accountType = :accountType
              and e.entryType = :entryType
            """)
    Optional<BigDecimal> sumByUserAccountAndEntryType(
            @Param("userId") Long userId,
            @Param("accountType") AccountType accountType,
            @Param("entryType") EntryType entryType
    );
}
