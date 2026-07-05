# Auth Service — Complete API Design

> Read `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`, service `COMMON_CONTEXT.md`.  
> **Scope:** Backend REST API only — registration, JWT, student verification.

## Identity

| Item | Value |
|------|-------|
| Path | `vithey-backend/services/auth-service/` |
| Port | 8081 |
| Eureka | `auth-service` |
| Database | `auth_db` |
| Package | `com.vithey.auth` |

## Spring Cloud + tools

Eureka Client, Config Client, OpenFeign (optional), RabbitMQ, JPA, Flyway, Spring Security, jjwt, MapStruct, springdoc-openapi.

## Folder structure

```text
services/auth-service/
├── pom.xml
├── README.md · API.md · ARCHITECTURE.md
└── src/main/java/com/vithey/auth/
    ├── AuthServiceApplication.java       # @EnableDiscoveryClient @EnableFeignClients
    ├── config/
    │   ├── SecurityConfig.java
    │   ├── RabbitMqConfig.java
    │   ├── OpenApiConfig.java
    │   └── JacksonConfig.java
    ├── controller/
    │   ├── AuthController.java
    │   └── StudentVerificationController.java
    ├── service/
    │   ├── AuthService.java
    │   ├── TokenService.java
    │   ├── StudentVerificationService.java
    │   └── PasswordResetService.java
    ├── repository/
    │   ├── UserRepository.java
    │   ├── RefreshTokenRepository.java
    │   └── StudentVerificationRepository.java
    ├── entity/
    │   ├── User.java
    │   ├── RefreshToken.java
    │   └── StudentVerification.java
    ├── dto/request/
    │   ├── RegisterRequest.java
    │   ├── LoginRequest.java
    │   ├── RefreshTokenRequest.java
    │   ├── ForgotPasswordRequest.java
    │   ├── ResetPasswordRequest.java
    │   └── StudentVerifyRequest.java
    ├── dto/response/
    │   ├── AuthResponse.java
    │   ├── UserAuthResponse.java
    │   └── TokenResponse.java
    ├── mapper/UserMapper.java
    ├── security/
    │   ├── JwtProvider.java
    │   └── PasswordEncoderConfig.java
    ├── event/
    │   ├── publisher/UserRegisteredEventPublisher.java
    │   ├── publisher/StudentVerifiedEventPublisher.java
    │   └── payload/UserRegisteredEvent.java, StudentVerifiedEvent.java
    ├── exception/GlobalExceptionHandler.java
    └── util/ApiResponseWrapper.java
└── resources/
    ├── bootstrap.yml
    ├── application-dev.yml
    └── db/migration/V1__init_auth_schema.sql
```

## Database entities

**User:** `id` UUID PK, `email` unique, `phone` unique, `password_hash`, `full_name`, `role` enum, `is_student_verified`, `is_email_verified`, `created_at`, `updated_at`

**RefreshToken:** `id`, `user_id` FK, `token_hash`, `expires_at`, `revoked_at`, `created_at`

**StudentVerification:** `id`, `user_id` FK, `student_id`, `university_email`, `status` PENDING|VERIFIED|REJECTED, `verified_at`

## Complete API

### Public

| Method | Path | Request | Response | HTTP |
|--------|------|---------|----------|------|
| POST | `/api/v1/auth/register` | See below | user + tokens | 201 |
| POST | `/api/v1/auth/login` | `{ "email_or_phone", "password" }` | user + tokens | 200 |
| POST | `/api/v1/auth/refresh` | `{ "refresh_token" }` | new tokens (rotated) | 200 |
| POST | `/api/v1/auth/forgot-password` | `{ "email" }` | `{ "data": { "message": "..." } }` | 200 always |
| POST | `/api/v1/auth/reset-password` | `{ "token", "new_password" }` | success message | 200 |
| POST | `/api/v1/auth/verify-email` | `{ "token" }` | success message | 200 |

**Register request:**
```json
{ "email": "student@aub.edu.kh", "phone": "+855123456789", "password": "SecurePass123!", "full_name": "Jane Doe", "role": "USER" }
```
`role` ∈ `USER`, `COMPANY` only.

**Token response:**
```json
{
  "data": {
    "user": { "user_id": "uuid", "email": "...", "role": "USER", "is_student_verified": false },
    "tokens": { "access_token": "eyJ...", "refresh_token": "...", "expires_in": 900 }
  }
}
```

### Protected (JWT or `X-User-Id` from gateway)

| Method | Path | Description | HTTP |
|--------|------|-------------|------|
| POST | `/api/v1/auth/logout` | Revoke refresh token | 204 |
| GET | `/api/v1/auth/me` | Auth info for current user | 200 |
| POST | `/api/v1/students/verify` | AUB student verification | 200 |

**Student verify:**
```json
{ "student_id": "AUB2024001", "university_email": "student@aub.edu.kh" }
```
→ role `STUDENT`, publish `student.verified`.

## Business logic

| Flow | Steps |
|------|-------|
| Register | Validate → hash password → save User → issue JWT + refresh → publish `user.registered` |
| Login | Find by email/phone → BCrypt verify → issue tokens |
| Refresh | Validate refresh hash → rotate (revoke old, issue new) |
| Logout | Revoke caller's refresh token |
| Student verify | Validate AUB email domain → update role → publish `student.verified` |

## JWT claims

`sub`, `email`, `roles[]`, `iat`, `exp` — TTL 15 min access, 7 day refresh.

## Events published

| Event | When |
|-------|------|
| `user.registered` | After register |
| `student.verified` | After successful verify |

## Errors

| Case | Code | HTTP |
|------|------|------|
| Duplicate email/phone | CONFLICT | 409 |
| Bad credentials | INVALID_CREDENTIALS | 401 |
| Invalid refresh | INVALID_TOKEN | 401 |
| Non-AUB email | BUSINESS_RULE_VIOLATION | 422 |

## Testing

Testcontainers PostgreSQL; JWT unit tests; register+login integration; student verify success/fail; mocked RabbitMQ.

## Output

Complete runnable auth-service on **8081**, Eureka registered, Swagger documented.
