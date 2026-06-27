# Auth Service — Service Prompt

Build the Auth microservice for Vithey App.

## Goal
Implement registration, login, token refresh, logout, password reset, and AUB student verification with JWT issuance.

## Stack
Java 21, Spring Boot 3+, Maven, Spring Data JPA, PostgreSQL, Spring Security, JWT (jjwt), RabbitMQ, Flyway, springdoc-openapi, Lombok, MapStruct.

## API Endpoints

### Public
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/auth/register` | Register user, return tokens |
| POST | `/api/v1/auth/login` | Login with email/phone + password |
| POST | `/api/v1/auth/refresh` | Exchange refresh token |
| POST | `/api/v1/auth/forgot-password` | Send reset email (always 200) |
| POST | `/api/v1/auth/reset-password` | Reset with token |
| POST | `/api/v1/auth/verify-email` | Confirm email token |

### Protected
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/auth/logout` | Revoke refresh token |
| POST | `/api/v1/students/verify` | Submit student ID + university email |
| GET | `/api/v1/auth/me` | Current user auth info (id, email, roles) |

## Register Request
```json
{
  "email": "student@aub.edu.kh",
  "phone": "+855123456789",
  "password": "SecurePass123!",
  "full_name": "Jane Doe",
  "role": "USER"
}
```

## Login Request
```json
{
  "email_or_phone": "student@aub.edu.kh",
  "password": "SecurePass123!"
}
```

## Token Response
```json
{
  "data": {
    "user": { "user_id": "uuid", "email": "...", "role": "USER", "is_student_verified": false },
    "tokens": {
      "access_token": "eyJ...",
      "refresh_token": "...",
      "expires_in": 900
    }
  }
}
```

## Student Verification
```json
{
  "student_id": "AUB2024001",
  "university_email": "student@aub.edu.kh"
}
```
On success: set `isStudentVerified=true`, role → `STUDENT`, publish `student.verified`.

## JWT Claims
`sub`, `email`, `roles`, `iat`, `exp` (15 min access)

## Required Modules
- `AuthController`, `StudentVerificationController`
- `AuthService`, `TokenService`, `StudentVerificationService`
- `UserRepository`, `RefreshTokenRepository`, `StudentVerificationRepository`
- `JwtProvider`, `SecurityConfig`, `GlobalExceptionHandler`
- `UserRegisteredEventPublisher`, `StudentVerifiedEventPublisher`
- Flyway: `V1__init_auth_schema.sql`

## Security
- BCrypt password encoding
- Refresh token rotation on refresh
- Rate limit login attempts (optional Redis counter)

## Testing
- Register + login integration test
- JWT generation/validation unit test
- Student verification success/failure test
- Event published verification (mock RabbitMQ)

## Docs
README.md, API.md, ARCHITECTURE.md

## Output
Complete runnable auth-service on port 8081.
