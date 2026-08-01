# Auth and Startup Prompt Index

**UI status: v1 complete** in `vithey_app` (Splash → Select Language → Onboarding → Auth / Google → Startup).

Use this folder as the single source of truth for app entry, authentication, registration, Google auth, and post-registration startup screens.

## Folder layout

| Folder | Contents |
| --- | --- |
| `v0/` | Original prompts (archive — do not implement from these) |
| `v1/` | **Current implemented UI** (`*-v1.md`) |
| Root | `update.md` (auth background history), `WAVE_SHAPES.md`, `Sample-for-Onboarding.md`, this README |

`update.md` documents the auth wave-background work that is **already implemented**. Treat it as reference, not a new build task.

## Current prompts (v1) — implement / maintain these

| # | Prompt | Module path |
| --- | --- | --- |
| 1 | [`v1/01-splash-prompt-v1.md`](v1/01-splash-prompt-v1.md) | `lib/modules/splash/` |
| 2 | [`v1/02-select-language-prompt-v1.md`](v1/02-select-language-prompt-v1.md) | `lib/modules/select_language/` |
| 3 | [`v1/03-onboarding-prompt-v1.md`](v1/03-onboarding-prompt-v1.md) | `lib/modules/onboarding/` |
| 4 | [`v1/04-auth-prompt-v1.md`](v1/04-auth-prompt-v1.md) | `lib/modules/auth/` (login) |
| 5 | [`v1/05-register-prompt-v1.md`](v1/05-register-prompt-v1.md) | `lib/modules/auth/` (register) |
| 6 | [`v1/06-auth-google-1-prompt-v1.md`](v1/06-auth-google-1-prompt-v1.md) | Google account chooser |
| 7 | [`v1/07-auth-google-2-prompt-v1.md`](v1/07-auth-google-2-prompt-v1.md) | Google confirm |
| 8 | [`v1/08-startup-1-prompt-v1.md`](v1/08-startup-1-prompt-v1.md) | `lib/modules/startup/` skills |
| 9 | [`v1/09-startup-2-prompt-v1.md`](v1/09-startup-2-prompt-v1.md) | interests |
| 10 | [`v1/10-startup-3-prompt-v1.md`](v1/10-startup-3-prompt-v1.md) | discovery |

Google Auth screens use **vertical sheet** transitions (`Transition.downToUp`). Splash → Select Language / Onboarding / Auth use `Transition.noTransition` for continuous wave morph.

Language flags (app assets): `assets/images/locale/english_language.png`, `assets/images/locale/khmer_language.png`.

## Entry flow (implemented)

```text
Splash → Select Language → Onboarding → Auth (Login/Register/Google)
       → Startup (skills / interests / discovery) → Home (MainShell)
```

## Route constants (sync with `AppRoutes`)

```dart
static const splash = '/splash';
static const selectLanguage = '/select-language';
static const onboarding = '/onboarding';
static const auth = '/auth';
static const login = '/login';
static const register = '/register';
static const forgotPassword = '/auth/forgot-password';
static const googleAccountChooser = '/auth/google';
static const googleAuthConfirmation = '/auth/google/confirm';
static const startupSkills = '/startup/skills';
static const startupInterests = '/startup/interests';
static const startupDiscovery = '/startup/discovery';
```

## Backend mapping

| Flow | Backend |
| --- | --- |
| Login/register/refresh/logout | `auth-service` |
| Current user/profile setup | `user-profile-service` |
| Avatar upload if used | `file-service` |

## API contract

```text
Prompt Frontend/api-intergration/integration-contract.md
```

## Acceptance checklist (v1 release)

- [x] Splash teal wash + brand + handoff to Select Language
- [x] Select Language (EN/KM) with locale flag assets
- [x] Onboarding wave morph + pages
- [x] Login / Register / Forgot Password wave backgrounds
- [x] Google account chooser + confirm sheets
- [x] Startup 3-step flow after auth
- [x] Tokens only via `SecureStorageService`
- [x] Routes registered in `app_pages.dart`

## Notes

- Splash / Select Language / Onboarding are local-only except token checks.
- `FORCE_DEV_FUNNEL=true` in `.env` forces the full funnel every cold start (dev).
- Do not reintroduce root-level duplicate `01-splash-prompt.md` names — use `v0/` or `v1/` only.
