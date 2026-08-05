# Auth and Startup Prompt Index

**UI status: implemented** in `vithey_app` (Splash → Language → Onboarding → Auth / Google → Startup).

Prompts live **directly in this folder** (no `v0` / `v1`).

## Folder layout

| Path | Contents |
| --- | --- |
| `01`–`10` | Screen prompts |
| `update.md` | As-built teal/white sheet + **AppLogo white circle** |
| `WAVE_SHAPES.md` | Wave geometry notes |
| `Sample-for-Onboarding.md` | Sample reference |
| `README.md` | This index |

## Current prompts

| # | Prompt | Module |
| --- | --- | --- |
| 1 | [`01-splash-prompt.md`](01-splash-prompt.md) | `lib/modules/splash/` |
| 2 | [`02-select-language-prompt.md`](02-select-language-prompt.md) | `lib/modules/select_language/` |
| 3 | [`03-onboarding-prompt.md`](03-onboarding-prompt.md) | `lib/modules/onboarding/` |
| 4 | [`04-auth-prompt.md`](04-auth-prompt.md) | `lib/modules/auth/` (login) |
| 5 | [`05-register-prompt.md`](05-register-prompt.md) | register panel |
| 6 | [`06-auth-google-1-prompt.md`](06-auth-google-1-prompt.md) | Google chooser |
| 7 | [`07-auth-google-2-prompt.md`](07-auth-google-2-prompt.md) | Google confirm |
| 8 | [`08-startup-1-prompt.md`](08-startup-1-prompt.md) | skills |
| 9 | [`09-startup-2-prompt.md`](09-startup-2-prompt.md) | interests |
| 10 | [`10-startup-3-prompt.md`](10-startup-3-prompt.md) | discovery |

## Shared chrome

- Teal + morphing white sheet (`update.md`)
- **`AppLogo`** always on a **white** circular background (`lib/core/widgets/app_logo.dart`)
