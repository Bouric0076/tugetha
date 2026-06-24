package com.sinaps.tugetha.modules.user;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
        "tugetha.auth.provider=stub",
        "spring.datasource.url=jdbc:h2:mem:tugetha-auth-test;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE",
        "spring.datasource.driver-class-name=org.h2.Driver",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.flyway.enabled=false",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "spring.data.redis.repositories.enabled=false"
})
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void bootstrapCreatesUserAndMeReturnsIt() throws Exception {
        mockMvc.perform(post("/api/v1/auth/bootstrap")
                        .header("Authorization", "Bearer test:firebase-uid-1:+254700000001:one@example.com")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "name": "Test User",
                                  "email": "one@example.com",
                                  "mpesaNumber": "+254700000001"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firebaseUid").value("firebase-uid-1"))
                .andExpect(jsonPath("$.phone").value("+254700000001"))
                .andExpect(jsonPath("$.role").value("USER"))
                .andExpect(jsonPath("$.active").value(true));

        mockMvc.perform(get("/api/v1/users/me")
                        .header("Authorization", "Bearer test:firebase-uid-1:+254700000001:one@example.com"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firebaseUid").value("firebase-uid-1"))
                .andExpect(jsonPath("$.phone").value("+254700000001"));
    }

    @Test
    void meRequiresBootstrappedUser() throws Exception {
        mockMvc.perform(get("/api/v1/users/me")
                        .header("Authorization", "Bearer test:not-bootstrapped:+254700000002"))
                .andExpect(status().isForbidden());
    }

    @Test
    void protectedEndpointRequiresBearerToken() throws Exception {
        mockMvc.perform(get("/api/v1/users/me"))
                .andExpect(status().isUnauthorized());
    }
}
