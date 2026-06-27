# 01 - Splash Screen Prompt

Build the **Splash** module for Vithey App.

## Goal
Show app logo and loading indicator while checking login status from secure storage, then route to the correct next screen.

## Depends On
- `00-foundation-prompt.md` completed

## Reuse From Core
- `LoadingWidget`
- `AppColors`, theme

## Module Files
```text
lib/modules/splash/
  splash_screen.dart
  splash_controller.dart
  splash_binding.dart
  widgets/
    splash_logo.dart          # Logo + app name animation
```

## Screen Spec (from Project Overview)
| Item | Detail |
|------|--------|
| Purpose | Show logo, check login token |
| Main UI | Logo, app name, loading indicator |
| Logic | Read JWT from secure storage |
| Next | Token valid → Home; no token → Onboarding (first time) or Auth |

## Controller Logic
1. Show splash minimum 1.5s (branding).
2. Read `access_token` from `SecureStorageService`.
3. Read `onboarding_completed` from `LocalStorageService`.
4. Navigate:
   - Valid token → `Routes.HOME`
   - No token + onboarding not done → `Routes.ONBOARDING`
   - No token + onboarding done → `Routes.AUTH`
5. Use `Get.offAllNamed` to prevent back navigation.

## UI Requirements
- Centered logo with subtle scale/fade animation (Lottie optional).
- App name **Vithey** below logo.
- `LoadingWidget` at bottom.
- Full-screen gradient background using theme colors.

## Route Registration
Add to `app_pages.dart`:
- `GetPage(name: Routes.SPLASH, page: () => SplashScreen(), binding: SplashBinding())`
- Set `initialRoute: Routes.SPLASH`

## Widget Rules
- `splash_logo.dart` is splash-specific → stays in module `widgets/`.
- Do not duplicate loading spinner — use `LoadingWidget`.

## Testing
- Widget test: splash renders logo and loading indicator.
- Controller test: mock storage → verify correct navigation target.

## Output
Complete splash flow with working navigation logic (routes may point to placeholder screens until those prompts run).
