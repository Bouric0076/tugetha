package com.sinaps.tugetha.common.auth;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(prefix = "tugetha.auth", name = "provider", havingValue = "firebase")
public class FirebaseAuthProvider implements AuthProvider {

    @Override
    public ExternalAuthUser verify(String bearerToken) {
        try {
            FirebaseToken token = FirebaseAuth.getInstance().verifyIdToken(bearerToken);
            return new ExternalAuthUser(
                    "firebase",
                    token.getUid(),
                    claimAsString(token, "phone_number"),
                    token.getEmail(),
                    token.isEmailVerified()
            );
        } catch (FirebaseAuthException ex) {
            throw new BadCredentialsException("Invalid Firebase token", ex);
        }
    }

    private String claimAsString(FirebaseToken token, String claimName) {
        Object value = token.getClaims().get(claimName);
        return value == null ? null : value.toString();
    }
}
