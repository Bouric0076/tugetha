package com.sinaps.tugetha.common.auth;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

@Component
@ConditionalOnProperty(prefix = "tugetha.auth", name = "provider", havingValue = "stub")
public class StubAuthProvider implements AuthProvider {

    @Override
    public ExternalAuthUser verify(String bearerToken) {
        if (!StringUtils.hasText(bearerToken) || !bearerToken.startsWith("test:")) {
            throw new BadCredentialsException("Invalid test token");
        }

        String[] parts = bearerToken.split(":", 4);
        if (parts.length < 3 || !StringUtils.hasText(parts[1]) || !StringUtils.hasText(parts[2])) {
            throw new BadCredentialsException("Test token must be test:{uid}:{phone}[:email]");
        }

        return new ExternalAuthUser(
                "stub",
                parts[1],
                parts[2],
                parts.length == 4 ? parts[3] : null,
                true
        );
    }
}
