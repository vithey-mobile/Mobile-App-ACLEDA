# Onboarding Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `02` |
| Route | `Routes.ONBOARDING` |
| Flutter module | `lib/modules/onboarding/` |
| Backend service(s) | — |
| Auth required | No |

## Purpose

Introduce main app features to **first-time users only** with 2 simple slides.

## Open from

- Splash (when `onboarding_completed` is false)

## Main UI

| Element | Description |
|---------|-------------|
| PageView | 2 slides horizontal swipe |
| Slide content | Illustration, title, short description |
| Page indicator | Dots (2) |
| Next button | Slide 1 only |
| Get Started button | Slide 2 only |
| Skip button | Top-right, both slides |

## Slides

| Slide | Content |
|-------|---------|
| 1 | Social Feed, Profile, Job Apply |
| 2 | Finance, Chat, AI Chatbot |

## User actions

| Action | Result |
|--------|--------|
| Next | Go to slide 2 |
| Skip | Set onboarding flag → Auth |
| Get Started | Set onboarding flag → Auth |

## Logic & behavior

- Only shown once per install (persist flag in `shared_preferences`)
- `PageController` with 2 pages
- Skip and Get Started both set `onboarding_completed = true`

## Navigation

| From | Action | To |
|------|--------|-----|
| Onboarding | Skip / Get Started | Auth |

## API endpoints

None.

## Reusable widgets

| Widget | Location |
|--------|----------|
| `CustomButton` | `core/widgets/custom_button.dart` |
| `OnboardingSlide` | `modules/onboarding/widgets/onboarding_slide.dart` |

## Status checklist

- [ ] UX/UI designed
- [ ] Frontend implemented
- [ ] Tested
