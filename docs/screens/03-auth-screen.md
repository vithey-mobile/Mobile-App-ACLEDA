# Auth Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `03` |
| Route | `Routes.AUTH` |
| Flutter module | `lib/modules/auth/` |
| Backend service(s) | `auth-service` |
| Auth required | No (public) |
| Competition feature | **Register / Login** |

## Purpose

Allow users to **register**, **login**, and optionally use **OAuth2**.

## Open from

- Onboarding, Splash (returning user), Settings (logout)

## Main UI

| Element | Description |
|---------|-------------|
| App logo | Top of screen |
| Tab / toggle | Login \| Register |
| Login form | Email or phone, password |
| Register form | Name, email, phone, password, confirm password |
| OAuth button | "Continue with …" (Auth0 optional) |
| Switch link | Toggle between login and register |

## User actions

| Action | Result |
|--------|--------|
| Login | Validate → API → save tokens → Home |
| Register | Validate match → API → save tokens → Home |
| OAuth | Auth0 flow → tokens → Home |

## Logic & behavior

- Field validation via `validators.dart`
- Save `access_token` + `refresh_token` in secure storage
- On success: `Get.offAllNamed(Routes.HOME)`
- Show loading state on submit; show errors inline
- Mock auth optional for dev (`USE_MOCK_AUTH`)

## Navigation

| From | Action | To |
|------|--------|-----|
| Auth | Success | Home |

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/v1/auth/register` | Returns user + tokens |
| POST | `/api/v1/auth/login` | Email/phone + password |
| POST | `/api/v1/auth/refresh` | Refresh token exchange |

## Reusable widgets

| Widget | Location |
|--------|----------|
| `CustomTextField` | `core/widgets/custom_text_field.dart` |
| `CustomButton` | `core/widgets/custom_button.dart` |
| `LoginForm` / `RegisterForm` | `modules/auth/widgets/` |

## Status checklist

- [ ] UX/UI designed
- [ ] Frontend implemented
- [ ] API integrated
- [ ] OAuth wired (optional)
