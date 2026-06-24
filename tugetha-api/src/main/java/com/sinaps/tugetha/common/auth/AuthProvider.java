package com.sinaps.tugetha.common.auth;

public interface AuthProvider {
    ExternalAuthUser verify(String bearerToken);
}
