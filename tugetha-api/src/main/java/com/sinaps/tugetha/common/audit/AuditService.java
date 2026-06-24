package com.sinaps.tugetha.common.audit;

import com.sinaps.tugetha.modules.user.User;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class AuditService {

    private final AuditLogRepository auditLogRepository;

    public AuditService(AuditLogRepository auditLogRepository) {
        this.auditLogRepository = auditLogRepository;
    }

    public void record(
            User actorUser,
            String actorFirebaseUid,
            String action,
            String targetType,
            String targetId,
            String correlationId,
            Map<String, Object> metadata
    ) {
        auditLogRepository.save(new AuditLog(
                actorUser,
                actorFirebaseUid,
                action,
                targetType,
                targetId,
                correlationId,
                metadata
        ));
    }
}
