# Startup Background Redesign — As-Built (ayheng)

## Objective

Startup / auth screens share a teal + morphing white sheet background. Business logic is unchanged.

> Implemented. This file documents **as-built** UI rules for auth-related chrome owned on `ayheng`.

---

# Scope

Screens:

- Language
- Onboarding
- Authentication (Sign In / Sign Up / Forgot / Reset / Verification / Google auth)
- Splash / Startup skill steps (where AppLogo appears)

---

# Background Structure

`text
┌──────────────────────────────────────────┐
│              TEAL BACKGROUND             │
│         App Logo / Illustrations         │
│~~~~~~~~~~~~ Morphing White Sheet ~~~~~~~~│
│            Screen Content                │
└──────────────────────────────────────────┘
`

- Teal fills the screen.
- White Sheet rises from the bottom, full width, no side/bottom margins.
- White + White 50% opacity layers act as one sheet element.
- Sheet wave morphs per screen; content lives inside the sheet.

---

# App Logo (as built — required)

**Everywhere** the Vithey app logo is shown, use `AppLogo`:

| Spec | Value |
|------|-------|
| Widget | `lib/core/widgets/app_logo.dart` |
| Background | **Always** a **white** circular container (`Colors.white`) |
| Dark mode | Still white (not `scheme.surface`) |
| Asset | `assets/images/brand/app_logo.png` |
| API | `AppLogo(size: …)`; `onWhiteCircle` kept for compatibility but ignored |

Used on: splash, select language, auth headers, Google auth, startup app bar, home app bar, About settings header, chatbot sources, etc.

Do **not** use bare `Image.asset(AppAssets.logoApp)` without `AppLogo`.

---

# What To Update / Preserve

## Update (UI only)

- Teal + White Sheet background system
- Wave shapes per screen
- AppLogo white circle everywhere

## Do NOT change

- Auth business logic, navigation, validation, controllers, services, models

---

# Design Requirements

- Teal full bleed; White Sheet full width from bottom
- Support light and dark mode (logo circle stays white)
- Reuse shared widgets (`AppLogo`, wave/sheet helpers)

---

# Key paths

`text
lib/core/widgets/app_logo.dart
lib/modules/auth/widgets/auth_wave_header.dart
lib/modules/auth/login_screen.dart
lib/modules/select_language/select_language_screen.dart
lib/modules/splash/splash_screen.dart
lib/modules/startup/widgets/startup_app_bar.dart
`

---

# Acceptance

- [x] Startup screens use teal + morphing white sheet
- [x] App logo always on white circular background
- [x] Auth logic unchanged
