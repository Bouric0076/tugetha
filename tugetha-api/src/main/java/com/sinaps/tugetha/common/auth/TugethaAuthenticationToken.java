package com.sinaps.tugetha.common.auth;

import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.List;

public class TugethaAuthenticationToken extends AbstractAuthenticationToken {

    private final TugethaPrincipal principal;

    public TugethaAuthenticationToken(TugethaPrincipal principal) {
        super(List.of(new SimpleGrantedAuthority("ROLE_" + principal.role().name())));
        this.principal = principal;
        setAuthenticated(true);
    }

    @Override
    public Object getCredentials() {
        return "";
    }

    @Override
    public TugethaPrincipal getPrincipal() {
        return principal;
    }
}
