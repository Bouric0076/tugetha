package com.sinaps.tugetha.modules.user;

import com.sinaps.tugetha.common.auth.CurrentUser;
import com.sinaps.tugetha.modules.user.dto.UserResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    private final CurrentUser currentUser;
    private final UserService userService;

    public UserController(CurrentUser currentUser, UserService userService) {
        this.currentUser = currentUser;
        this.userService = userService;
    }

    @GetMapping("/me")
    public UserResponse me() {
        User user = userService.getRequiredActiveUser(currentUser.requiredUserId());
        return UserResponse.from(user);
    }
}
