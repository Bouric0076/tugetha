package com.sinaps.tugetha.common.audit;

import com.sinaps.tugetha.modules.user.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "audit_logs")
public class AuditLog {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "actor_user_id")
    private User actorUser;

    @Column(name = "actor_firebase_uid", length = 128)
    private String actorFirebaseUid;

    @Column(nullable = false, length = 80)
    private String action;

    @Column(name = "target_type", length = 80)
    private String targetType;

    @Column(name = "target_id", length = 128)
    private String targetId;

    @Column(name = "correlation_id", length = 80)
    private String correlationId;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private Map<String, Object> metadata = Map.of();

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    protected AuditLog() {
    }

    public AuditLog(
            User actorUser,
            String actorFirebaseUid,
            String action,
            String targetType,
            String targetId,
            String correlationId,
            Map<String, Object> metadata
    ) {
        this.actorUser = actorUser;
        this.actorFirebaseUid = actorFirebaseUid;
        this.action = action;
        this.targetType = targetType;
        this.targetId = targetId;
        this.correlationId = correlationId;
        this.metadata = metadata == null ? Map.of() : metadata;
    }

    @PrePersist
    void prePersist() {
        createdAt = Instant.now();
    }
}
