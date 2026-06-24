package com.sinaps.tugetha.modules.user;

import com.sinaps.tugetha.common.audit.AuditService;
import com.sinaps.tugetha.common.auth.TugethaPrincipal;
import com.sinaps.tugetha.modules.user.dto.AuthBootstrapRequest;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final AuditService auditService;

    public UserService(UserRepository userRepository, AuditService auditService) {
        this.userRepository = userRepository;
        this.auditService = auditService;
    }

    @Transactional
    public User bootstrap(TugethaPrincipal principal, AuthBootstrapRequest request, HttpServletRequest servletRequest) {
        if (principal.phone() == null || principal.phone().isBlank()) {
            throw new AccessDeniedException("Verified phone number is required");
        }

        User user = userRepository.findByFirebaseUid(principal.subject())
                .map(existing -> updateExisting(existing, request))
                .orElseGet(() -> createUser(principal, request));

        auditService.record(
                user,
                principal.subject(),
                "AUTH_BOOTSTRAP",
                "USER",
                user.getId().toString(),
                (String) servletRequest.getAttribute("correlationId"),
                Map.of("provider", principal.provider())
        );

        return user;
    }

    @Transactional(readOnly = true)
    public User getRequiredActiveUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AccessDeniedException("User not found"));
        if (!user.isActive()) {
            throw new AccessDeniedException("User account is disabled");
        }
        return user;
    }

    private User updateExisting(User user, AuthBootstrapRequest request) {
        user.updateProfile(
                request.name(),
                request.email() == null ? user.getEmail() : request.email(),
                request.mpesaNumber() == null ? user.getMpesaNumber() : request.mpesaNumber()
        );
        return user;
    }

    private User createUser(TugethaPrincipal principal, AuthBootstrapRequest request) {
        if (userRepository.existsByPhoneAndFirebaseUidNot(principal.phone(), principal.subject())) {
            throw new IllegalArgumentException("Phone number is already linked to another account");
        }
        return userRepository.save(User.createFirebaseUser(
                principal.subject(),
                principal.phone(),
                request.email() == null ? principal.email() : request.email(),
                request.name(),
                request.mpesaNumber()
        ));
    }
}
