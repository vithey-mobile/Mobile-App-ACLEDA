# Auth Service — Common Context

## Service Role
Authentication, authorization tokens, roles, and AUB student verification.

## Identity
| Item | Value |
|------|-------|
| Eureka name | `auth-service` |
| Port | 8081 |
| Database | `auth_db` (PostgreSQL) |
| Package | `com.vithey.auth` |

## Entities
- `User` — id, email, phone, passwordHash, role, isActive, isEmailVerified, isStudentVerified, createdAt
- `RefreshToken` — id, userId, token, expiresAt, revoked
- `StudentVerification` — id, userId, studentId, universityEmail, status, verifiedAt

## Roles (RBAC)
`USER`, `STUDENT`, `COMPANY`, `ADMIN`

## Events Published
- `user.registered` → { userId, email, fullName, role }
- `student.verified` → { userId, studentId }

## Dependencies
- Eureka, Config Server, PostgreSQL, RabbitMQ

## Does NOT Own
- User profile (bio, avatar, social links) → User-Profile Service
- Payment data → Finance Service
