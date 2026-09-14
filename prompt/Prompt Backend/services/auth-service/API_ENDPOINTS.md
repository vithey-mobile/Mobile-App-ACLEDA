# Auth Service — API Endpoints

Base path: `/api/v1`

Frontend contract source: `Prompt Frontend/api-intergration/api-overview.md`

## Public endpoints

| Method | Path | Purpose | Response |
| --- | --- | --- | --- |
| POST | `/auth/register` | Create user account | `201`, user + access/refresh tokens |
| POST | `/auth/login` | Login by email or phone | `200`, user + access/refresh tokens |
| POST | `/auth/refresh` | Rotate refresh token | `200`, new access/refresh tokens |
| POST | `/auth/forgot-password` | Start password reset | `200`, generic success message |
| POST | `/auth/reset-password` | Complete password reset | `200`, success message |
| POST | `/auth/verify-email` | Verify email token | `200`, success message |

## Protected endpoints

| Method | Path | Purpose | Response |
| --- | --- | --- | --- |
| POST | `/auth/logout` | Revoke caller refresh token | `204` |
| GET | `/auth/me` | Current auth identity and roles | `200`, auth user summary |
| PATCH | `/auth/me/password` | Change password (`current_password`, `new_password`) | `200`, success message |
| POST | `/students/verify` | Verify AUB student status | `200`, updated role/status |

## Request examples

```json
{ "email": "student@aub.edu.kh", "phone": "+855123456789", "password": "SecurePass123!", "full_name": "Jane Doe", "role": "USER" }
```

```json
{ "email_or_phone": "student@aub.edu.kh", "password": "SecurePass123!" }
```

```json
{ "student_id": "AUB2024001", "university_email": "student@aub.edu.kh" }
```

## Response rules

- Use standard envelope: `{ "data": ... }` or `{ "error": { "code", "message", "details" } }`.
- JWT claims: `sub`, `email`, `roles[]`, `iat`, `exp`.
- Access token TTL: 15 minutes. Refresh token TTL: 7 days.
- `role` during registration accepts `USER` or `COMPANY`; `STUDENT` is assigned only by verification.

