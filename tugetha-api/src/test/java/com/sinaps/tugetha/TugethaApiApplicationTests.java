package com.sinaps.tugetha;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
@org.springframework.test.context.TestPropertySource(properties = {
		"tugetha.auth.provider=stub",
		"spring.datasource.url=jdbc:h2:mem:tugetha-test;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE",
		"spring.datasource.driver-class-name=org.h2.Driver",
		"spring.datasource.username=sa",
		"spring.datasource.password=",
		"spring.flyway.enabled=false",
		"spring.jpa.hibernate.ddl-auto=create-drop",
		"spring.data.redis.repositories.enabled=false"
})
class TugethaApiApplicationTests {

	@Test
	void contextLoads() {
	}

}
