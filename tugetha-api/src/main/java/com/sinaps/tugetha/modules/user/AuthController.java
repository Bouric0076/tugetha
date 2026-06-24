package com.sinaps.tugetha.modules.user;

import com.sinaps.tugetha.common.auth.CurrentUser;
import com.sinaps.tugetha.modules.user.dto.AuthBootstrapRequest;
import com.sinaps.tugetha.modules.user.dto.UserResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final CurrentUser currentUser;
    private final UserService userService;

    public AuthController(CurrentUser currentUser, UserService userService) {
        this.currentUser = currentUser;
        this.userService = userService;
    }

    @PostMapping("/bootstrap")
    public UserResponse bootstrap(
            @Valid @RequestBody AuthBootstrapRequest request,
            HttpServletRequest servletRequest
    ) {
        User user = userService.bootstrap(currentUser.principal(), request, servletRequest);
        return UserResponse.from(user);
    }
}
