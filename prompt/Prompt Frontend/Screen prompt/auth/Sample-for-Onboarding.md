# 02 - Onboarding Screen Prompt

Build the **Onboarding screen** for the Vithey App in Flutter, matching the supplied reference image as closely as possible.

## Visual reference

- Reference image: `Prompt Frontend/screen image/auth/Onboarding Screen.png`
- Reference canvas: approximately full screen for background (portrait mobile)
- Treat the image as the source of truth for composition, spacing, colors, and visual hierarchy.
- Recreate the UI responsively; do not hard-code the entire screen to the reference dimensions.
- Same layout for all 3 onboarding pages — only the illustration, title, and subtitle change.

## Quick info

| Field | Value |
|---|---|
| Screen ID | `02` |
| Primary route | `Routes.ONBOARDING` |
| Next route | `Routes.AUTH` / `Routes.LOGIN` |
| Flutter module | `lib/modules/onboarding/` |
| Backend service | — (local only) |
| Auth required | No (public) |
| Primary feature | 3-page feature introduction with Skip / Next |

## Goal

Introduce Vithey to a first-time user after Splash with **one screen** that pages through **three content states** (Onboarding 1, 2, and 3). Persist completion, then navigate to Auth. There is no email/password form on this screen.

## Screen composition

Build the screen from top to bottom in this order:

1. **Teal decorative header**
   - Occupies roughly the top `55%` of the reference screen.
   - Use a turquoise/teal background close to `#2FC5C1`.
   - Place a white **Skip** `TextButton` in the **top-right** corner (safe-area aware).
   - Center the onboarding illustration in the teal area.
   - Illustration max width is `60%` of the screen width (`maxWidth: MediaQuery.width * 0.60`); keep aspect ratio and do not stretch.
   - Use slide assets from `assets/images/onboarding/onboarding_1.png`, `onboarding_2.png`, and `onboarding_3.png`.
   - The bottom edge is an organic layered wave: a lighter aqua wave behind and a white foreground wave that blends into the page body.
   - Implement the waves with `CustomPainter`, `ClipPath`, or reusable vector assets. Do not substitute a straight or diagonal edge.

2. **White content area (bottom layer)**
   - Continues seamlessly from the white foreground wave.
   - Occupies roughly the bottom `45%` of the reference screen.
   - Use safe-area-aware responsive spacing.
   - Horizontal page padding is approximately `24 px` at the reference size.
   - This layer holds **only**: Title, Subtitle, page dots, and the Next button.
   - Do **not** include email, password, Google, or any auth form controls.

3. **Title**
   - Centered, bold, dark charcoal, approximately `22–24 px` in the reference.
   - Leave clear space between the wave and the title.
   - Changes per onboarding page (see slide content below).

4. **Subtitle**
   - Centered under the title, medium gray, approximately `13–14 px`.
   - Prefer 1–2 short lines; keep line length readable on narrow phones.
   - Changes per onboarding page.

5. **Page indicator (3 dots)**
   - Centered under the subtitle.
   - Exactly **3** dots for Onboarding 1, 2, and 3.
   - Active dot: teal brand color.
   - Inactive dots: light muted gray.
   - Dot diameter about `8 px`, spacing about `8 px`.
   - Update the active index when the user swipes or taps Next.

6. **Primary action**
   - Full-width teal rounded button near the bottom of the white layer.
   - Pages 1–2 text: **→ Next** (leading arrow icon + **Next**). Prefer an appropriate Flutter icon rather than a text glyph.
   - Page 3 text: **→ Get Started** (same style).
   - White medium/bold text, approximately `14 px`.
   - Button height about `44–48 px` logical with roughly `24–28 px` corner radius (pill-like in the reference).
   - Use the app's teal brand color, close to `#08B9B3`.

### Slide content

| Page | Title | Subtitle | Illustration |
|---|---|---|---|
| 1 | Connect with Your Campus Community | Discover posts, connect with friends, and stay updated. | `assets/images/onboarding/onboarding_1.png` |
| 2 | Jobs & Career Growth | Discover job posts, apply with your CV, and connect with opportunities on campus. | `assets/images/onboarding/onboarding_2.png` |
| 3 | Finance, Chat & AI Support | Track tuition payments, chat privately, and get AI help for study and career. | `assets/images/onboarding/onboarding_3.png` |

Use a single shared layout template for all three pages. Swap illustration, title, and subtitle only.

## Visual style

| Token | Direction |
|---|---|
| Page background | White / very light neutral |
| Header teal | Approximately `#2FC5C1` |
| Primary button / active dot | Approximately `#08B9B3` |
| Rear wave | Light aqua, approximately `#6AD6D2` |
| Heading | Dark charcoal, approximately `#303236` |
| Subtitle/body | Medium muted gray |
| Skip text | White |
| Inactive dots | Light cool gray |
| Font | App theme font; use a clean sans-serif appearance |

Avoid extra elements that are not visible in the reference: no tab bar, no app bar, no back button, no email/password fields, no Google button, and no Sign Up / Sign In footer links on this screen.

## Responsive behavior

- Preserve the reference proportions on narrow portrait phones while scaling naturally on larger devices.
- Wrap the content in `SafeArea` where appropriate (especially Skip and the bottom button).
- Use `LayoutBuilder`/constraints rather than fixed screen coordinates.
- Keep the illustration capped at **60% max width** and vertically centered in the teal header.
- Keep title and subtitle readable when text scaling is enabled.
- The content must not overflow at `320 px` width; allow the bottom layer to remain stable while the `PageView` pages horizontally.
- Keep the wave header visually stable across all three pages.

## Interaction and behavior

- Show this flow once per install when `onboarding_completed` is false (after Splash).
- Use a horizontal `PageView` with `PageController` and exactly **3** pages.
- Swipe left/right updates the current page and active dot.
- **Next** advances to the next page; on page 3, **Get Started** finishes onboarding.
- **Skip** (any page) finishes onboarding immediately.
- On finish:
  1. Persist `onboarding_completed = true` in local storage / `shared_preferences`.
  2. Navigate with `Get.offAllNamed(Routes.AUTH)`.
- Disable duplicate finish actions while navigation is in progress.
- Animate page changes with a short ease-in-out duration (about `300 ms`).

## Accessibility

- Provide semantic labels for Skip, the illustration, title, subtitle, page indicator, and Next / Get Started.
- Ensure every interactive target is at least `44 × 44 logical pixels`.
- Maintain sufficient contrast for Skip on teal, body text on white, and the primary button.
- Announce page changes for assistive technologies when the active index updates.

## Architecture and reusable widgets

Use the existing project structure and core components:

```text
lib/modules/onboarding/
  onboarding_screen.dart
  onboarding_controller.dart
  onboarding_binding.dart
  widgets/
    onboarding_page_view.dart
    onboarding_slide.dart
    onboarding_top_section.dart
    onboarding_bottom_section.dart
    onboarding_wave_clipper.dart
    onboarding_page_indicator.dart

assets/images/onboarding/
  onboarding_1.png
  onboarding_2.png
  onboarding_3.png
```

- Reuse the auth-style wave approach where practical (`CustomPainter` / `ClipPath`), but keep onboarding widgets in `lib/modules/onboarding/`.
- Use `CustomButton` from `core/widgets/custom_button.dart` for the primary CTA when it can match the teal pill style.
- Do not use raw `ElevatedButton` unless a core component cannot support a reference-specific requirement; extend the reusable component instead.
- Keep wave-header rendering in a dedicated reusable widget/painter.
- Keep business logic out of UI widgets.

## Controller behavior

- `onPageChanged(index)` → update `currentPage`.
- `next()` → if not last page, animate to next page; else call `finish()`.
- `skip()` → call `finish()`.
- `finish()` → set `onboarding_completed` → `Get.offAllNamed(Routes.AUTH)`.
- Loading/navigation guards use reactive controller state such as `RxBool isFinishing`.
- CTA label is reactive: **Next** on pages 0–1, **Get Started** on page 2.

## API endpoints

None. Onboarding is local-only.

## Navigation

| From | Action | To |
|---|---|---|
| Splash | `onboarding_completed == false` | Onboarding |
| Onboarding | Tap **Skip** | Auth |
| Onboarding | Tap **Next** (pages 1–2) | Next onboarding page |
| Onboarding | Tap **Get Started** (page 3) | Auth |
| Splash | `onboarding_completed == true` and logged out | Auth |

## Testing and acceptance criteria

- The implementation visually matches `Onboarding Screen.png`, including the layered curved header, Skip placement, centered illustration, title/subtitle hierarchy, 3 dots, and Next button.
- One screen hosts three pages; only illustration, title, and subtitle change.
- Illustration width never exceeds `60%` of the screen width.
- Email/password and other auth form controls are absent.
- Skip finishes onboarding from any page and navigates to Auth.
- Next advances pages; Get Started finishes on the last page.
- Active dot tracks the current page on swipe and button press.
- `onboarding_completed` is persisted before leaving the screen.
- Widget tests cover rendering, page changes, Skip, Next, Get Started, and navigation.
- The screen has no overflow on common small and large phone sizes.

## Dependencies

- `00-foundation-prompt.md`
- `01-splash-prompt.md` / `01-splash-prompt-version-2.md`
- `03-auth-prompt.md`

## Output

Deliver a polished, responsive Flutter onboarding screen that closely reproduces the supplied reference image, pages through three content states with Skip / Next / Get Started, and routes to Auth after persisting completion.
