# Auth Service — Service Prompt

Authoritative API contract and build checklist for the Vithey Auth microservice.
Read `KICKOFF_PROMPT.md` and both `COMMON_CONTEXT.md` files first.

## Goal

Implement registration, login, token refresh, logout, password reset, email
verification, and AUB student verification with JWT issuance.

## Stack

Java 21, Spring Boot 3.3+, Maven, Spring Data JPA, PostgreSQL 16, Spring Security,
JWT (jjwt), RabbitMQ, Flyway, springdoc-openapi, Lombok, MapStruct, Bean Validation.

## Conventions (avoid drift)

- **JSON fields:** `snake_case` (e.g. `full_name`). **Java entity fields:** `camelCase`. Map via MapStruct/Jackson.
- **All responses** use the root success/error envelope (`{ "data": ... }` / `{ "error": ... }`).
- **All IDs** are UUID strings.

## API Endpoints

### Public (no auth)

| Method | Path                           | Description                                             | Success |
| ------ | ------------------------------ | ------------------------------------------------------- | ------- |
| POST   | `/api/v1/auth/register`        | Register user, return user + tokens                     | 201     |
| POST   | `/api/v1/auth/login`           | Login with email/phone + password                       | 200     |
| POST   | `/api/v1/auth/refresh`         | Exchange refresh token (rotates it)                     | 200     |
| POST   | `/api/v1/auth/forgot-password` | Send reset email — **always 200** (no user enumeration) | 200     |
| POST   | `/api/v1/auth/reset-password`  | Reset password with emailed token                       | 200     |
| POST   | `/api/v1/auth/verify-email`    | Confirm email with token                                | 200     |

### Protected (`Authorization: Bearer <access_token>`)

| Method | Path                      | Description                                              | Success |
| ------ | ------------------------- | -------------------------------------------------------- | ------- |
| POST   | `/api/v1/auth/logout`     | Revoke caller's refresh token                            | 204     |
| GET    | `/api/v1/auth/me`         | Current user auth info (id, email, role, verified flags) | 200     |
| POST   | `/api/v1/students/verify` | Submit student ID + university email                     | 200     |

## Request / Response Shapes

### Register — request

```json
{
  "email": "student@aub.edu.kh",
  "phone": "+855123456789",
  "password": "SecurePass123!",
  "full_name": "Jane Doe",
  "role": "USER"
}
```

Validation: valid email; E.164 phone; password ≥ 8 chars with upper, lower, digit,
symbol; `role` ∈ {`USER`, `COMPANY`} (never accept `STUDENT`/`ADMIN` on register).

### Login — request

```json
{ "email_or_phone": "student@aub.edu.kh", "password": "SecurePass123!" }
```

### Token response (register & login)

```json
{
  "data": {
    "user": {
      "user_id": "uuid",
      "email": "...",
      "role": "USER",
      "is_student_verified": false
    },
    "tokens": {
      "access_token": "eyJ...",
      "refresh_token": "...",
      "expires_in": 900
    }
  }
}
```

`expires_in` is seconds and **must equal the access TTL (900 = 15 min)**.

### Student verification — request

```json
{ "student_id": "AUB2024001", "university_email": "student@aub.edu.kh" }
```

On success: set `isStudentVerified=true`, promote `role` → `STUDENT`,
set `StudentVerification.status=VERIFIED`, publish `student.verified`.
Reject (422) if `university_email` is not an AUB domain or `student_id` is invalid.

## JWT Claims

`sub` (userId), `email`, `roles[]`, `iat`, `exp`. Access token TTL 15 min;
sign with secret/key from Config Server or env — never hard-coded.

## Error Behavior (use root envelope + codes)

| Case                                   | Code                      | HTTP |
| -------------------------------------- | ------------------------- | ---- |
| Duplicate email/phone on register      | `CONFLICT`                | 409  |
| Bad credentials on login               | `INVALID_CREDENTIALS`     | 401  |
| Invalid/expired refresh or reset token | `INVALID_TOKEN`           | 401  |
| Validation failure                     | `VALIDATION_ERROR`        | 400  |
| Non-AUB email / bad student id         | `BUSINESS_RULE_VIOLATION` | 422  |

## Required Modules

- Controllers: `AuthController`, `StudentVerificationController`
- Services: `AuthService`, `TokenService`, `StudentVerificationService`
- Repositories: `UserRepository`, `RefreshTokenRepository`, `StudentVerificationRepository`
- Security/config: `JwtProvider`, `SecurityConfig`, `GlobalExceptionHandler`
- Events: `UserRegisteredEventPublisher`, `StudentVerifiedEventPublisher`
- Migration: `V1__init_auth_schema.sql`

## Security

- BCrypt password hashing.
- Refresh token rotation: issue a new refresh token and revoke the old one on every `/refresh`.
- Store refresh tokens hashed at rest.
- Rate-limit login attempts (optional Redis counter).

## Testing

- Register + login integration test (Testcontainers PostgreSQL).
- JWT generation/validation unit test.
- Student verification success **and** failure (non-AUB email) tests.
- Event-published assertions with mocked RabbitMQ.

## Docs

`README.md` (run, env vars, port), `API.md` (endpoint summary), `ARCHITECTURE.md` (boundaries, DB, events).

## Output

Complete, runnable auth-service on port 8081.
