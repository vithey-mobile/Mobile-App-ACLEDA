# 03 - Auth Screen Prompt

Build the **Auth** module (Login + Register) for Vithey App.

## Goal
Allow users to register, login, and optionally use OAuth2 — save tokens and navigate to Home.

## Depends On
- `00-foundation-prompt.md`, `02-onboarding-prompt.md`

## Reuse From Core
- `CustomButton`
- `CustomTextField`
- `LoadingWidget`
- `AppErrorWidget`
- `validators.dart`

## Module Files
```text
lib/modules/auth/
  auth_screen.dart            # Tab or toggle: Login | Register
  login_screen.dart           # Optional sub-screen
  register_screen.dart
  auth_controller.dart
  auth_binding.dart
  widgets/
    login_form.dart
    register_form.dart
    oauth_button.dart

lib/data/models/user_model.dart
lib/data/services/auth_service.dart
lib/data/repositories/auth_repository.dart
```

## Screen Spec
| Item | Detail |
|------|--------|
| Register fields | Name, email, phone, password, confirm password |
| Login fields | Email or phone, password |
| OAuth | Auth0 / OAuth2 button (optional wiring) |
| API | `POST /auth/register`, `POST /auth/login` |
| Success | Save tokens → Home |

## Controller Logic
- `login()` — validate → `AuthRepository.login` → save tokens → `Get.offAllNamed(Routes.HOME)`
- `register()` — validate passwords match → register → save tokens → Home
- `loginWithOAuth()` — placeholder or Auth0 flow
- Loading and error states via `RxBool isLoading`, `RxString errorMessage`
- Show field-level validation errors

## UI Requirements
- Clean auth layout with app logo at top.
- Toggle or TabBar: Login / Register.
- `login_form.dart` and `register_form.dart` compose `CustomTextField` + `CustomButton`.
- Password visibility toggle.
- OAuth button below divider "or continue with".
- Link to switch between login/register.

## Widget Rules
- Forms are module widgets but must use **only** `CustomTextField` and `CustomButton` from core.
- No raw `TextField` or `ElevatedButton` in forms.

## Data Layer
- `AuthService` — Dio calls to auth endpoints
- `AuthRepository` — maps response to `UserModel`, handles errors
- Mock mode: if API fails, allow dev login with stored mock user (env flag `USE_MOCK_AUTH=true`)

## Route Registration
Add `Routes.AUTH`, `Routes.LOGIN`, `Routes.REGISTER` as needed.

## Testing
- Validator unit tests
- Widget test: login form renders all fields
- Controller test: successful login navigates to home

## Output
Complete auth UI with repository layer ready for backend integration.
