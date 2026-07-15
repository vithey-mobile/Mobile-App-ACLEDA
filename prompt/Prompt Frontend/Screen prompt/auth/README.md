# Auth and Startup Prompt Index

Use this folder as the single source of truth for app entry, authentication, registration, Google auth, and post-registration startup screens.

## Folder layout

| Folder | Contents |
| --- | --- |
| `v0/` | Original prompts (unchanged filenames) |
| `v1/` | Current iteration (`*-v1.md`, formerly `*-version-2.md`) |

`update.md`, `Sample-for-Onboarding.md`, and this README stay at the auth root.

## Reading order (v0 originals)

1. `v0/01-splash-prompt.md` — launch branding and token/onboarding routing.
2. `v0/02-onboarding-prompt.md` — first-time onboarding.
3. `v0/03-auth-prompt.md` — sign in.
4. `v0/04-register-prompt.md` — create account.
5. `v0/05-auth-google-1-prompt.md` — Google auth first screen/entry.
6. `v0/06-auth-google-2-prompt.md` — Google auth continuation.
7. `v0/07-startup-1-prompt.md` — profile setup step 1.
8. `v0/08-startup-2-prompt.md` — interests setup step 2.
9. `v0/09-startup-3-prompt.md` — final startup step.

## Current prompts (v1)

1. `v1/01-splash-prompt-v1.md`
2. `v1/02-onboarding-prompt-v1.md`
3. `v1/03-auth-prompt-v1.md`
4. `v1/04-register-prompt-v1.md`
5. `v1/07-startup-1-prompt-v1.md`
6. `v1/08-startup-2-prompt-v1.md`
7. `v1/09-startup-3-prompt-v1.md`

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
