package com.sinaps.tugetha.common.auth;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
public class CurrentUser {

    public TugethaPrincipal principal() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof TugethaPrincipal principal)) {
            throw new AccessDeniedException("Authenticated Tugetha principal required");
        }
        return principal;
    }

    public Long requiredUserId() {
        TugethaPrincipal principal = principal();
        if (!principal.isBootstrapped()) {
            throw new AccessDeniedException("User must be bootstrapped before accessing this resource");
        }
        return principal.userId();
    }
}
