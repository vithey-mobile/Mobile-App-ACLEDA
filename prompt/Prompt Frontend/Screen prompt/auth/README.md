# Auth and Startup Prompt Index

Use this folder as the single source of truth for app entry, authentication, registration, Google auth, and post-registration startup screens.

## Reading order

1. `01-splash-prompt.md` — launch branding and token/onboarding routing.
2. `02-onboarding-prompt.md` — first-time onboarding.
3. `03-auth-prompt.md` — sign in.
4. `04-register-prompt.md` — create account.
5. `05-auth-google-1-prompt.md` — Google auth first screen/entry.
6. `06-auth-google-2-prompt.md` — Google auth continuation.
7. `07-startup-1-prompt.md` — profile setup step 1.
8. `08-startup-2-prompt.md` — interests setup step 2.
9. `09-startup-3-prompt.md` — final startup step.

## Backend mapping

| Flow | Backend |
| --- | --- |
| Login/register/refresh/logout | `auth-service` |
| Current user/profile setup | `user-profile-service` |
| Avatar upload if used | `file-service` |

## API contract

Use:

```text
Prompt Frontend/api-intergration/integration-contract.md
```

## Route constants

```dart
static const SPLASH = '/';
static const ONBOARDING = '/onboarding';
static const AUTH = '/auth';
static const LOGIN = '/login';
static const REGISTER = '/register';
static const STARTUP_1 = '/startup/1';
static const STARTUP_2 = '/startup/2';
static const STARTUP_3 = '/startup/3';
```

## Notes

- Splash and Onboarding are local-only except token checks.
- Auth screens must save tokens only through `SecureStorageService`.
- Startup screens run after authentication and must tolerate returning users who skip or resume setup.
