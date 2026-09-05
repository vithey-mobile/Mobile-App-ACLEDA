# 11 - Forgot Password Prompt

Build / document the **Forgot Password** screen for Vithey App.

## Product spec

### Quick info

| Field | Value |
|-------|-------|
| Screen ID | `auth-forgot` |
| Route | `AppRoutes.forgotPassword` (`/auth/forgot-password`) |
| Flutter module | `lib/modules/auth/forgot_password_screen.dart` |
| Backend service(s) | `auth-service` |
| Auth required | No |
| Competition feature | Yes |

### Purpose

Let users request a password reset email / OTP from the login screen.

### Open from

- Login → “Forgot password?”

### Main UI

| Element | Description |
|---------|-------------|
| Teal wave / auth chrome | Same as login |
| Email field | Validated email |
| Submit | Primary button |
| Back | Returns to login |

### API endpoints

| Method | Path | Notes |
|--------|------|-------|
| POST | `/auth/forgot-password` | `{ "email" }` |

### Status checklist

- [x] Frontend screen exists
- [ ] Live API verified
