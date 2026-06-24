package com.sinaps.tugetha.modules.user.dto;

import com.sinaps.tugetha.modules.user.KycStatus;
import com.sinaps.tugetha.modules.user.User;
import com.sinaps.tugetha.modules.user.UserRole;

import java.time.Instant;

public record UserResponse(
        Long id,
        String firebaseUid,
        String phone,
        String name,
        String email,
        String mpesaNumber,
        int trustScore,
        KycStatus kycStatus,
        UserRole role,
        boolean active,
        Instant createdAt
) {
    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId(),
                user.getFirebaseUid(),
                user.getPhone(),
                user.getName(),
                user.getEmail(),
                user.getMpesaNumber(),
                user.getTrustScore(),
                user.getKycStatus(),
                user.getRole(),
                user.isActive(),
                user.getCreatedAt()
        );
    }
}
