# GLM 5.3 Flash — Shadcn Phase 1 of 6 — Settings + Auth

Copy everything below the line into a **new chat** after Phase 0 is merged.

---

You are a Flutter screen agent on Vithey App. Apply the **Shadcn kit** to Settings and Auth only. Do not rebuild Home, Map, or backend.

## Read first

- `prompt/Prompt Frontend/SHADCN_STANDARD_PLAN.md` §2 rules + §4 auth/settings
- `prompt/Prompt Frontend/COMPONENT_KIT.md`
- `vithey_app/lib/core/widgets/widgets.dart`
- `vithey_app/lib/modules/settings/`
- `vithey_app/lib/modules/auth/` (login, forgot, startup, language, onboarding, oauth)

## Allowed paths

```text
vithey_app/lib/modules/settings/**
vithey_app/lib/modules/auth/**
```

You may **only** fix a kit bug in `lib/core/widgets/` if analyze fails. Prefer not to.

## Job

Replace Material CTAs / `TextFormField` / `SwitchListTile` / raw `shad.*` with:

- `CustomButton` (primary, outline, ghost, destructive)
- `CustomTextField` / `VitheyField` / `VitheyTextArea`
- `VitheySwitch` (privacy, security, notification prefs)
- `VitheyListTile` (settings home, help, about)
- `VitheyCard` / `VitheyInfoCard`
- `showConfirmDialog` (logout)

Keep:

- Teal wave background on onboarding/auth
- `AppLogo`
- Google sign-in **coming soon** (do not implement OAuth)
- Startup skill/interest chips as **module** widgets (style with `AppColors` / `VitheyCard` only)

Screens to cover: settings home, account, edit account, privacy, security, change password, notification prefs, help, about, login/register, forgot password, startup bottom nav + skip, oauth button wrapper.

## Rules

- **No** `import 'package:shadcn_flutter/...'` under these two module trees
- **No** `ElevatedButton`, `TextButton`, `OutlinedButton`, `TextFormField`, Material `AlertDialog` as the main control
- Tokens: `context.appColors`, `AppColors.primary` only
- Do not change routes or GetX controller logic except to call `showConfirmDialog` instead of inline dialogs

## Stop when

- Settings + Auth compose the kit
- `dart analyze` on touched files is clean
- Print old widget → new kit widget for a few examples

Do not start Phase 2.
