# Auth Service — Service Logic

## Ownership

Auth service owns account credentials, JWT issuing, refresh token rotation, roles, and AUB student verification.

It does not own public profile, avatar files, settings, posts, chat, notifications, or finance records.

## Core flows

| Flow | Logic |
| --- | --- |
| Register | Validate unique email/phone, hash password with BCrypt, save `User`, create tokens, publish `user.registered`. |
| Login | Find active user by email or phone, verify BCrypt password, create access token and refresh token. |
| Refresh | Hash incoming refresh token, verify not expired/revoked, revoke old token, issue a new refresh token and access token. |
| Logout | Revoke the caller refresh token or all user tokens when requested by security endpoints later. |
| Student verification | Validate AUB email/student id, update role/status to `STUDENT`, publish `student.verified`. |
| Forgot/reset password | Generate one-time reset token, store hashed token, reset only if token is valid and unexpired. |

## Events

| Event | When | Consumers |
| --- | --- | --- |
| `user.registered` | After successful registration | user-profile, notification |
| `student.verified` | After successful student verification | finance, notification |

## Security rules

- Never return `password_hash` or refresh token hashes.
- Store refresh tokens as hashes only.
- Register accepts `USER` or `COMPANY`; never direct `ADMIN` or `STUDENT`.
- Gateway validates JWT and forwards `X-User-Id`, `X-User-Roles`, and `X-Request-ID`.
- `/auth/register`, `/auth/login`, `/auth/refresh`, forgot/reset, health, and Swagger are public; everything else is protected.

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Duplicate email/phone | `CONFLICT` | 409 |
| Bad credentials | `INVALID_CREDENTIALS` | 401 |
| Invalid/expired refresh | `INVALID_TOKEN` | 401 |
| Non-AUB verification email | `BUSINESS_RULE_VIOLATION` | 422 |
| Validation failure | `VALIDATION_ERROR` | 400 |

