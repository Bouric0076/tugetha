package com.sinaps.tugetha.common.auth;

public record ExternalAuthUser(
        String provider,
        String subject,
        String phone,
        String email,
        boolean phoneVerified
) {
}
