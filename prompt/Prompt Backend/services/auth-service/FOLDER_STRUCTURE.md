# Auth Service — Folder Structure

Target output:

```text
backend/services/auth-service/
├── pom.xml
├── README.md
├── API.md
├── ARCHITECTURE.md
└── src/
    ├── main/
    │   ├── java/com/vithey/auth/
    │   │   ├── AuthServiceApplication.java
    │   │   ├── config/
    │   │   │   ├── SecurityConfig.java
    │   │   │   ├── RabbitMqConfig.java
    │   │   │   ├── OpenApiConfig.java
    │   │   │   └── JacksonConfig.java
    │   │   ├── controller/
    │   │   │   ├── AuthController.java
    │   │   │   └── StudentVerificationController.java
    │   │   ├── service/
    │   │   │   ├── AuthService.java
    │   │   │   ├── TokenService.java
    │   │   │   ├── PasswordResetService.java
    │   │   │   └── StudentVerificationService.java
    │   │   ├── repository/
    │   │   │   ├── UserRepository.java
    │   │   │   ├── RefreshTokenRepository.java
    │   │   │   └── StudentVerificationRepository.java
    │   │   ├── entity/
    │   │   │   ├── User.java
    │   │   │   ├── RefreshToken.java
    │   │   │   └── StudentVerification.java
    │   │   ├── dto/request/
    │   │   ├── dto/response/
    │   │   ├── mapper/
    │   │   ├── security/
    │   │   ├── event/publisher/
    │   │   ├── event/payload/
    │   │   ├── exception/
    │   │   └── util/
    │   └── resources/
    │       ├── bootstrap.yml
    │       ├── application.yml
    │       ├── application-dev.yml
    │       └── db/migration/V1__init_auth_schema.sql
    └── test/java/com/vithey/auth/
```

## Required dependencies

- Spring Web, Spring Security, Validation, Actuator
- Spring Data JPA, PostgreSQL, Flyway
- Eureka Client, Config Client
- RabbitMQ for `user.registered` and `student.verified`
- JJWT, BCrypt, MapStruct, Lombok, springdoc-openapi

