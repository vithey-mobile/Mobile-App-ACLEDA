# Auth Service API

Base path: `/api/v1`

All success responses use `{ "data": ... }`. Errors use `{ "error": { "code", "message", "details" } }`.

## Public

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/auth/register` | Register `USER` or `COMPANY`, then return user and access/refresh tokens. |
| `POST` | `/auth/login` | Login by email or phone. |
| `POST` | `/auth/refresh` | Rotate a refresh token and issue new tokens. |
| `POST` | `/auth/forgot-password` | Start reset flow with a generic response. |
| `POST` | `/auth/reset-password` | Reset password using a one-time token. |
| `POST` | `/auth/verify-email` | Verify email using a one-time token. |

## Protected

Send `Authorization: Bearer <access_token>` or gateway headers `X-User-Id` and `X-User-Roles`.

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/auth/logout` | Revoke submitted refresh token. |
| `GET` | `/auth/me` | Return current auth identity. |
| `POST` | `/students/verify` | Verify AUB student status and promote role to `STUDENT`. |

## Token Rules

- Access token TTL: 15 minutes.
- Refresh token TTL: 7 days.
- JWT claims: `sub`, `email`, `roles[]`, `iat`, `exp`.
- Refresh/reset/email verification tokens are stored only as SHA-256 hashes.
