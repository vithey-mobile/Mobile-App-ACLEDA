# 03 - Onboarding Screen Prompt (Version 2)

Build the **Onboarding Screen** for the Vithey App in Flutter, matching the supplied reference image as closely as possible.

> **Source of truth for this version:** the current Flutter module under `vithey_app/lib/modules/onboarding/` (especially `widgets/onboarding_background.dart`).

## Design reference (match this layout on every slide)

![Onboarding Screen — Slide 1](../../screen%20image/auth/Onboarding%20Screen.png)

## Visual reference

- Reference image: `Prompt Frontend/screen image/auth/Onboarding Screen.png`
- Comparison helper: `Prompt Frontend/screen image/auth/image.png` (left = requirement, right = build)
- Reference canvas: approximately full screen (portrait mobile)
- Treat the image as the source of truth for composition, spacing, colors, and visual hierarchy.
- Recreate the UI responsively; do not hard-code the entire screen to the reference dimensions.
- Same layout for all 3 onboarding pages — only the illustration, title, and subtitle change.

## Quick info

| Field           | Value                                        |
| --------------- | -------------------------------------------- |
| Screen ID       | `03`                                         |
| Primary route   | `AppRoutes.onboarding` (`/onboarding`)       |
| Next route      | `AppRoutes.login` (`/login`)                 |
| Flutter module  | `lib/modules/onboarding/`                    |
| Backend service | — (local only)                               |
| Auth required   | No (public)                                  |
| Primary feature | 3-page feature introduction with Skip / Next |

## Goal

Introduce Vithey to a first-time user after Splash with **one screen** that pages through **three content states** (Onboarding 1, 2, and 3). Persist completion, then navigate to Login/Auth. There is no email/password form on this screen.

**Critical UX rule:** the **background stays fixed**. Swipe / Next only changes onboarding **content** (illustration, title, subtitle, active dot / CTA label). Do not rebuild or animate the teal/white wave background per page.

## Screen composition

Use a `Stack` so the background layers stay fixed behind the changing content.

### Fixed background (does not move on swipe / Next)

Implemented in `OnboardingBackground` (`CustomPainter`). Three layers, back → front:

1. **White** — full-screen base
2. **Light teal** — rear wave (`AppColors.waveRearOn(cardSurface)` — `primaryLight` @ 50%)
3. **Teal** — front wave (`AppColors.primaryLight` ≈ `#2FC5C1`)

Each wave edge is a smooth Catmull-Rom → cubic path through width/height keyframes. Teal and light teal use **separate X keyframes** (staggered bends).

#### Implemented keyframes (match code)

**Teal** — `_tealX` / `_tealY`:

| Width  | Y (fraction of screen height) | Behavior                         |
| ------ | ----------------------------- | -------------------------------- |
| `0%`   | `0.510`                       | Start; small gap vs light teal   |
| `20%`  | `0.528`                       | Dip lower                        |
| `40%`  | `0.485`                       | Rise / expanded peak             |
| `50%`  | `0.485`                       | **Hold up** (same as 40%)        |
| `80%`  | `0.525`                       | Fall / close bend (dipped a bit) |
| `100%` | `0.460`                       | Rise up                          |

**Light teal** — `_lightX` / `_lightY`:

| Width  | Y (fraction of screen height) | Behavior                                |
| ------ | ----------------------------- | --------------------------------------- |
| `0%`   | `0.535`                       | Start; small gap                        |
| `20%`  | `0.575`                       | Mid gap + dip                           |
| `40%`  | `0.570`                       | Expanded gap                            |
| `60%`  | `0.535`                       | Close bend starts; **hold through 75%** |
| `75%`  | `0.535`                       | Still held close/up                     |
| `95%`  | `0.580`                       | Lowest point                            |
| `100%` | `0.580`                       | **Flat / stable** (no rise)             |

**Gap rule:** max separation between the two edges ≈ **10% of screen height** at expanded points; small-gap points stay tighter.

Do **not** put this painter inside the `PageView`.

> **Reuse for Auth (later):** this wave background (colors + wavy keyframe style) is the **shared Vithey entry-screen look**. Auth should use the same or a scaled variant. Documented also in `Prompt Frontend/COMMON_CONTEXT.md` → _Shared teal wave background_. Canonical code: `onboarding_background.dart`.

### Changing content (moves on swipe / Next)

1. **Skip** (fixed overlay)
   - White `TextButton`, top-right, `SafeArea`
   - Min target `44 × 44`
   - Calls `controller.skip`

2. **Illustration** (`OnboardingTopSection`)
   - In `PageView`, top `Expanded(flex: 55)`
   - Centered; max width **60%** of screen; `BoxFit.contain`
   - **Image only** — no card / placeholder fill behind the asset

3. **Title + subtitle** (`OnboardingBottomSection` with `showChrome: false`)
   - In `PageView`, bottom `Expanded(flex: 45)` with bottom padding `112` for chrome
   - Text sits **lower** in the white area (`Spacer(flex: 5)` above, `Spacer(flex: 2)` below)
   - Centered title (~22 bold) + description (~14 muted)

4. **Dots + CTA** (`OnboardingBottomChrome` — fixed overlay)
   - 3 dots; active = onboarding teal; inactive = light gray
   - Pill CTA (`ElevatedButton`, height 48, radius 28): arrow + label **centered as a group**
   - Pages 1–2: **Next**; page 3: **Get Started**
   - Brand color `AppColors.primary` ≈ `#08B9B3`

### Actual layout structure (current Flutter)

`text
Scaffold (white)
└── Stack
    ├── OnboardingBackground()              // FIXED painter
    ├── PageView                            // CHANGING content
    │   └── Column
    │       ├── Expanded(55) OnboardingTopSection(image)
    │       └── Expanded(45) OnboardingBottomSection(title/desc, showChrome: false)
    ├── Positioned top-right SafeArea Skip  // FIXED
    └── Positioned bottom OnboardingBottomChrome(dots + CTA)  // FIXED
`

### Slide content (from `OnboardingController`)

| Page | Title                              | Subtitle                                                                          | Illustration                                |
| ---- | ---------------------------------- | --------------------------------------------------------------------------------- | ------------------------------------------- |
| 1    | Connect with Your Campus Community | Discover posts, connect with friends, and stay updated.                           | `assets/images/onboarding/onboarding_1.png` |
| 2    | Jobs & Career Growth               | Discover job posts, apply with your CV, and connect with opportunities on campus. | `assets/images/onboarding/onboarding_2.png` |
| 3    | Finance, Chat & AI Support         | Track tuition payments, chat privately, and get AI help for study and career.     | `assets/images/onboarding/onboarding_3.png` |

## Visual style

| Token                       | Direction                                                     |
| --------------------------- | ------------------------------------------------------------- |
| Page background             | White                                                         |
| Front / top teal            | `AppColors.primaryLight` ≈ `#2FC5C1`                        |
| Rear / light teal           | `AppColors.waveRearOn(cardSurface)`                          |
| Primary button / active dot | `AppColors.primary` ≈ `#08B9B3`                               |
| Heading                     | `AppColors.titleLight` / `context.appColors.heading`         |
| Subtitle/body               | `AppColors.bodyLight` / `context.appColors.muted`            |
| Skip text                   | White                                                         |
| Illustration                | Image only — no card / fill background                        |

Avoid: tab bar, app bar, back button, email/password fields, Google button, Sign Up/Sign In footer, half-circle header edge, per-page background rebuild.

## Responsive behavior

- Preserve proportions on narrow portrait phones; scale on larger devices.
- `SafeArea` for Skip and bottom CTA inset.
- Illustration max width = `60%` of screen width.
- Background waves stay fixed while `PageView` pages horizontally.
- No overflow at `320 px` width.

## Interaction and behavior

- Shown after Splash when `onboarding_completed` is false (unless `FORCE_SHOW_ONBOARDING=true` in `.env` for dev).
- Horizontal `PageView` with exactly **3** pages; `BouncingScrollPhysics`.
- Swipe or **Next** advances content only; background stays put.
- **Skip** (any page) → `finish()`.
- Page 3 **Get Started** → `finish()`.
- On finish:
  1. `setOnboardingCompleted(true)`
  2. `Get.offAllNamed(AppRoutes.login)`
- Page animation ~`300 ms` ease-in-out.

## Accessibility

- Semantic labels for Skip, illustration, title, subtitle, dots, and Next / Get Started.
- Interactive targets at least `44 × 44` logical pixels.
- Sufficient contrast for white Skip on teal and body text on white.

## Architecture (current files)

`text
lib/modules/onboarding/
onboarding_screen.dart
onboarding_controller.dart
onboarding_binding.dart
widgets/
onboarding_background.dart # FIXED wave painter (teal + light teal keyframes)
onboarding_top_section.dart # illustration only
onboarding_bottom_section.dart # title/description + OnboardingBottomChrome (dots/CTA)

assets/images/onboarding/
onboarding_1.png
onboarding_2.png
onboarding_3.png
`

- Business logic stays in `OnboardingController`.
- CTA is a module-local centered pill `ElevatedButton` (not left-aligned `CustomButton` leading icon).
- Background stays outside the `PageView`.

## Controller behavior

- `onPageChanged(index)` → `currentPage`
- `next()` → next page, or `finish()` on last page
- `skip()` → `finish()`
- `finish()` → persist flag → `AppRoutes.login`
- CTA label: **Next** on pages 0–1, **Get Started** on page 2

## API endpoints

None. Onboarding is local-only.

## Navigation

| From       | Action                                               | To                   |
| ---------- | ---------------------------------------------------- | -------------------- |
| Splash     | `onboarding_completed == false` (or force-show flag) | Onboarding           |
| Onboarding | Tap **Skip**                                         | Login                |
| Onboarding | Tap **Next** (pages 1–2)                             | Next onboarding page |
| Onboarding | Tap **Get Started** (page 3)                         | Login                |
| Splash     | `onboarding_completed == true` and logged out        | Login                |

## Testing and acceptance criteria

- Background (white + light-teal + teal) stays fixed while content swipes / Next advances.
- Wave keyframes match the tables above (including teal `50%` hold, light teal `60%→75%` hold, light teal `95%→100%` flat).
- Skip is white and top-right.
- Illustration has no background card; max width 60%.
- Title/description sit lower in the white area; dots + centered pill CTA at bottom.
- Three pages; only illustration/title/subtitle change.
- Skip / Next / Get Started persist and navigate to login.
- No overflow on common phone sizes.

## Dependencies

- `00-foundation-prompt.md`
- `01-splash-prompt.md` / `01-splash-prompt.md`
- `03-auth-prompt.md`

## Output

Keep the Flutter onboarding screen aligned with this prompt: **fixed layered wavy background** + **swiping content**, then route to Login after persisting completion.
