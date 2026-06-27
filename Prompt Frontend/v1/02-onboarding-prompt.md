# 02 - Onboarding Screen Prompt

Build the **Onboarding** module for Vithey App.

## Goal
Introduce app features to first-time users with **2 slides only**, then route to Auth.

## Depends On
- `01-splash-prompt.md`

## Reuse From Core
- `CustomButton`
- `EmptyStateWidget` (optional for slide illustration area)

## Module Files
```text
lib/modules/onboarding/
  onboarding_screen.dart
  onboarding_controller.dart
  onboarding_binding.dart
  widgets/
    onboarding_slide.dart     # Reusable slide: illustration, title, description
    onboarding_page_indicator.dart
```

## Screen Spec
| Item | Detail |
|------|--------|
| Slides | **2 only** |
| Slide 1 | Social Feed, Profile, Job Apply |
| Slide 2 | Finance, Chat, AI Chatbot |
| Buttons | Next, Skip, Get Started (last slide) |
| Skip / Get Started | → Auth Screen |
| Logic | Show only first-time users; set `onboarding_completed` flag |

## Controller Logic
- `PageController` for 2 pages.
- `next()` → slide 2 or finish on last slide.
- `skip()` / `finish()` → save onboarding flag → `Get.offAllNamed(Routes.AUTH)`.

## UI Requirements
- Horizontal `PageView` with 2 slides.
- Dot page indicator.
- **Next** on slide 1; **Get Started** on slide 2.
- **Skip** top-right on both slides.
- Use `assets/images/onboarding_1.png`, `onboarding_2.png` (or Lottie placeholders).
- Smooth page transition animation.

## Reusable Widget: `onboarding_slide.dart`
Parameters: `image`, `title`, `description` — used twice, stays in module widgets (only used here).

## Route Registration
Add `Routes.ONBOARDING` to `app_pages.dart`.

## Output
Fully working 2-slide onboarding with persistence flag.
