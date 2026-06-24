package com.sinaps.tugetha.common.auth;

import com.sinaps.tugetha.modules.user.User;
import com.sinaps.tugetha.modules.user.UserRepository;
import com.sinaps.tugetha.modules.user.UserRole;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Optional;

@Component
public class BearerTokenAuthenticationFilter extends OncePerRequestFilter {

    private final AuthProvider authProvider;
    private final UserRepository userRepository;

    public BearerTokenAuthenticationFilter(AuthProvider authProvider, UserRepository userRepository) {
        this.authProvider = authProvider;
        this.userRepository = userRepository;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        if (isPublic(request)) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            String token = bearerToken(request);
            ExternalAuthUser externalUser = authProvider.verify(token);
            TugethaPrincipal principal = resolvePrincipal(externalUser);
            SecurityContextHolder.getContext().setAuthentication(new TugethaAuthenticationToken(principal));
            filterChain.doFilter(request, response);
        } catch (BadCredentialsException ex) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid or missing bearer token");
        } catch (DisabledException ex) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "User account is disabled");
        } finally {
            SecurityContextHolder.clearContext();
        }
    }

    private TugethaPrincipal resolvePrincipal(ExternalAuthUser externalUser) {
        Optional<User> maybeUser = userRepository.findByFirebaseUid(externalUser.subject());
        if (maybeUser.isEmpty()) {
            return new TugethaPrincipal(
                    null,
                    externalUser.provider(),
                    externalUser.subject(),
                    externalUser.phone(),
                    externalUser.email(),
                    UserRole.USER,
                    true
            );
        }

        User user = maybeUser.get();
        if (!user.isActive()) {
            throw new DisabledException("User account is disabled");
        }

        return new TugethaPrincipal(
                user.getId(),
                externalUser.provider(),
                user.getFirebaseUid(),
                user.getPhone(),
                user.getEmail(),
                user.getRole(),
                user.isActive()
        );
    }

    private String bearerToken(HttpServletRequest request) {
        String header = request.getHeader("Authorization");
        if (!StringUtils.hasText(header) || !header.startsWith("Bearer ")) {
            throw new BadCredentialsException("Missing bearer token");
        }
        return header.substring(7);
    }

    private boolean isPublic(HttpServletRequest request) {
        String path = request.getRequestURI();
        return path.equals("/api/health") || path.equals("/actuator/health");
    }
}
