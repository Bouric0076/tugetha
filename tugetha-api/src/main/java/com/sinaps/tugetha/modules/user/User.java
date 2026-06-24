package com.sinaps.tugetha.modules.user;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

import java.time.Instant;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "firebase_uid", nullable = false, unique = true, length = 128)
    private String firebaseUid;

    @Column(nullable = false, unique = true, length = 20)
    private String phone;

    private String name;

    @Column(name = "mpesa_number", length = 20)
    private String mpesaNumber;

    private String email;

    @Column(name = "trust_score", nullable = false)
    private int trustScore = 50;

    @Enumerated(EnumType.STRING)
    @Column(name = "kyc_status", nullable = false, length = 20)
    private KycStatus kycStatus = KycStatus.PENDING;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private UserRole role = UserRole.USER;

    @Column(nullable = false)
    private boolean active = true;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;

    protected User() {
    }

    private User(String firebaseUid, String phone, String email, String name, String mpesaNumber) {
        this.firebaseUid = firebaseUid;
        this.phone = phone;
        this.email = email;
        this.name = name;
        this.mpesaNumber = mpesaNumber;
    }

    public static User createFirebaseUser(String firebaseUid, String phone, String email, String name, String mpesaNumber) {
        if (firebaseUid == null || firebaseUid.isBlank()) {
            throw new IllegalArgumentException("Firebase UID is required");
        }
        if (phone == null || phone.isBlank()) {
            throw new IllegalArgumentException("Phone number is required");
        }
        return new User(firebaseUid, phone, email, name, mpesaNumber);
    }

    public void updateProfile(String name, String email, String mpesaNumber) {
        this.name = name;
        this.email = email;
        this.mpesaNumber = mpesaNumber;
    }

    @PrePersist
    void prePersist() {
        createdAt = Instant.now();
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = Instant.now();
    }

    public Long getId() {
        return id;
    }

    public String getFirebaseUid() {
        return firebaseUid;
    }

    public String getPhone() {
        return phone;
    }

    public String getName() {
        return name;
    }

    public String getMpesaNumber() {
        return mpesaNumber;
    }

    public String getEmail() {
        return email;
    }

    public int getTrustScore() {
        return trustScore;
    }

    public KycStatus getKycStatus() {
        return kycStatus;
    }

    public UserRole getRole() {
        return role;
    }

    public boolean isActive() {
        return active;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
