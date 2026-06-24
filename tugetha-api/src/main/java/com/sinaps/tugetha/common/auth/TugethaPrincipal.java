package com.sinaps.tugetha.common.auth;

import com.sinaps.tugetha.modules.user.UserRole;

public record TugethaPrincipal(
        Long userId,
        String provider,
        String subject,
        String phone,
        String email,
        UserRole role,
        boolean active
) {
    public boolean isBootstrapped() {
        return userId != null;
    }
}
