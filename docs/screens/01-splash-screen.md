# Splash Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `01` |
| Route | `Routes.SPLASH` |
| Flutter module | `lib/modules/splash/` |
| Backend service(s) | — |
| Auth required | No |
| Competition feature | No (entry) |

## Purpose

Show app logo and branding while checking if the user is already logged in.

## Open from

- App launch (initial route)

## Main UI

| Element | Description |
|---------|-------------|
| Logo | Vithey app logo, centered |
| App name | "Vithey" text below logo |
| Loading indicator | Spinner or Lottie animation |
| Background | Brand gradient |

## User actions

| Action | Result |
|--------|--------|
| None | Automatic navigation after check |

## Logic & behavior

- Show splash minimum ~1.5 seconds (branding)
- Read `access_token` from `flutter_secure_storage`
- Read `onboarding_completed` from `shared_preferences`
- **If valid token** → `Home` (`Get.offAllNamed`)
- **If no token + first time** → `Onboarding`
- **If no token + onboarding done** → `Auth`
- Prevent back navigation to splash

## Navigation

| From | Action | To |
|------|--------|-----|
| Splash | Token valid | Home |
| Splash | No token, first launch | Onboarding |
| Splash | No token, returning user | Auth |

## API endpoints

None.

## Reusable widgets

| Widget | Location |
|--------|----------|
| `LoadingWidget` | `core/widgets/loading_widget.dart` |
| `SplashLogo` | `modules/splash/widgets/splash_logo.dart` |

## UX notes

- Lottie animation optional on logo
- Works in light and dark mode

## Status checklist

- [ ] UX/UI designed (Figma)
- [ ] Screen doc reviewed
- [ ] Frontend implemented
- [ ] API integrated
- [ ] Tested on Android
- [ ] Tested on iOS
