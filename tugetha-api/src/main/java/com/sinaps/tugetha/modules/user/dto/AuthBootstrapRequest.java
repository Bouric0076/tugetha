package com.sinaps.tugetha.modules.user.dto;

import jakarta.validation.constraints.Size;

public record AuthBootstrapRequest(
        @Size(max = 255) String name,
        @Size(max = 255) String email,
        @Size(max = 20) String mpesaNumber
) {
}
