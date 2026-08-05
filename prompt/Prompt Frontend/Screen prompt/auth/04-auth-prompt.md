# 04 - Auth / Sign In Screen Prompt (Version 2)

Build the **Auth screen (Sign In panel)** for the Vithey App in Flutter.

> **Pair with** `05-register-prompt.md` — Sign In and Sign Up live on **one Auth screen** and morph between each other (grow/shrink).  
> **Wave style source of truth:** Onboarding v2 / `onboarding_background.dart` + `COMMON_CONTEXT.md` → *Shared teal wave background*.

## Design reference

![Auth Screen](../../screen%20image/auth/Auth%20Screen.png)

## Visual reference

- Reference image: `Prompt Frontend/screen image/auth/Auth Screen.png`
- Logo asset: `Prompt Frontend/screen image/auth/logo app.png` → `assets/images/brand/logo_app.png` (`AppLogo` / `AppAssets.logoApp`)
- Treat the image as the source of truth for form fields, labels, and hierarchy.
- Recreate responsively; do not hard-code to reference pixel sizes.
- **UI language** matches Onboarding v2 (teal / light teal / white wavy layers), with Auth-specific motion rules below.

## Quick info

| Field | Value |
| --- | --- |
| Screen ID | `04` |
| Primary route | `AppRoutes.auth` / `AppRoutes.login` |
| Sibling panel | Sign Up / Register (same screen — see `05-register-prompt.md`) |
| Flutter module | `lib/modules/auth/` |
| Backend service | `auth-service` |
| Auth required | No (public) |
| Primary feature | Email/password + Google sign-in on a shared Auth shell (grow/shrink toggle) |

## Goal

One **Auth screen** hosts **Sign In** and **Sign Up**. Users tap footer links to morph between panels (no swipe). This prompt defines the **Sign In** panel and the **shared shell** (background + logo + motion). Sign Up field details live in register v2.

Sign In content is **shorter** than Sign Up — layout must grow/shrink with content without breaking the fixed teal back layer.

## Critical difference vs Onboarding v2

| | Onboarding v2 | Auth v2 |
| --- | --- | --- |
| Fixed layer | Teal + light teal + white (all fixed) | **Only teal** fixed (full-screen back) |
| Moves with content | Illustration + text only | **Light teal + white** wavy overlay **and** form content |
| Top content | Skip + illustration | **No Skip** — **logo** only on teal |
| White content | Title / subtitle / dots / Next | **Auth form** (Sign In or Sign Up) |
| Height model | ~55/45 split | **Content-driven** height; teal is just the back |

## Screen composition

### Shared Auth shell

`text
Scaffold
â””â”€â”€ Stack
    â”œâ”€â”€ AuthTealBackdrop()                 // FIXED full-back teal
    â””â”€â”€ Column
        â”œâ”€â”€ Expanded → logo (teal auto height)
        â””â”€â”€ AuthMovingWaveSheet            // MOVING with panel toggle only
            â”œâ”€â”€ wave band â‰ˆ 10% screen     // light teal + white curly edge
            â””â”€â”€ white body                 // HUGS form content (Figma hug)
`

### Background (Auth-specific)

1. **Fixed — teal only**
   - Full-back teal (`AppColors.authHeaderTeal` â‰ˆ `#2FC5C1`).
   - Height is **auto**: fills whatever space remains above the white sheet.
   - Rough visual guide â‰ˆ 30% when Sign In content is short; grows/shrinks as white hugs taller/shorter forms.
   - Does not move when switching Sign In â†” Sign Up.

2. **Moving — light teal wave band + white body**
   - Wave band â‰ˆ **10% of screen height** (light teal + white curly edge together).
   - White body **hugs its content** (not a fixed 60% lock) — all form fields must fit in white without vertical scroll.
   - Sheet switches with a **height morph** (grow/shrink), not a left/right slide:
     1. Current form fades out (text does **not** scale with the sheet)
     2. White sheet **grows upward** (Sign In → Sign Up) or **shrinks downward** (Sign Up → Sign In) to hug the next form
     3. Next form fades in once the height is mostly ready
     4. Logo gently eases (subtle scale/opacity) while teal auto-fills the space above the sheet

3. **No scroll / no swipe**
   - **No vertical scroll** and **no horizontal swipe**.
   - Panel change **only** via footer toggle (**Sign Up** / **Sign In** buttons).
   - Ignore duplicate taps while `isPanelAnimating` is true.
   - `resizeToAvoidBottomInset: false`.

Reuse Onboarding’s painter math where practical. Do **not** keep light teal + white fixed like Onboarding.

### Content on teal (Sign In page)

- **No Skip button.**
- Center **Vithey logo** in the teal band (`AppLogo`, white circle as in current Auth design / reference).
- Logo size ~`82` logical px circle (responsive).
- Naming: this is the **brand logo**, not the onboarding **illustration** scene art — different asset, similar placement role.

### Content on white (Sign In panel)

1. **Heading** — centered **Welcome Back** (bold dark charcoal ~24–26)
2. **Email Address** — label + **placeholder `Email`**, envelope icon
3. **Password** — label + **placeholder `Password`**, lock icon, visibility toggle
4. **Forgot password?** — smaller font (~12), **primary** color (`#08B9B3`), right-aligned
5. **Primary CTA** — full-width teal button; icon + **Sign In** **centered as a group**
6. **Divider** — **Sign in with** in **smaller** muted font (~12) + horizontal rules
7. **Google** — bordered white button; Google mark + **Continue with Google** with **larger** label font (~15); **no helper/hint text under this button**
8. **Footer** — **Don’t have an account?** in **smaller** muted font (~12) + **Sign Up** in **primary** color  
   - Morphs the Auth sheet to Sign Up (same screen)

Horizontal padding ~`24 px`. No vertical page scroll.

## Visual style

| Token | Direction |
| --- | --- |
| Fixed back | Teal `#2FC5C1` |
| Moving rear wave | Light teal `#6AD6D2` |
| Moving body | White |
| Primary / links | `#08B9B3` |
| Heading | `#303236` |
| Input fill | `#F5F5F5` |
| Font | App theme sans-serif |

Avoid: app bar, back button, Skip, onboarding dots/Next, half-circle header, fixed full-screen white (Auth white moves).

## Responsive behavior

- **No vertical scroll** and **no horizontal swipe**.
- Switch Sign In â†” Sign Up **only** with footer toggle buttons.
- White sheet **hugs content**; teal above is **auto** (remaining space).
- Wave band â‰ˆ **10%** of screen height (adaptive %).
- Guide ratios when Sign In is short: teal ~30% / wave ~10% / white ~60% — not hard locks; content wins.
- No overflow / scroll errors; all Sign In fields must remain visible in white.

## Interaction and validation

- Validate via `validators.dart` (email required + format; password required + min length).
- Inline errors; stable button size with loading indicator.
- Success: save tokens → `Get.offAllNamed(AppRoutes.home)` (or startup flow if project requires).
- Google: existing OAuth / `USE_MOCK_AUTH` behavior.
- **Sign Up** footer → animate to Sign Up panel on the same Auth screen.

## Accessibility

- Semantics for logo, fields, visibility toggle, Sign In, Google, Sign Up.
- Min `44 × 44` targets; keyboard submit from password field.

## Architecture

`text
lib/modules/auth/
  auth_screen.dart                 # shared shell + height morph (Sign In | Sign Up)
  login_screen.dart                # may become a panel widget
  register_screen.dart             # may become a panel widget (see register v2)
  auth_controller.dart
  auth_binding.dart
  widgets/
    auth_teal_backdrop.dart        # FIXED teal only
    auth_moving_wave_sheet.dart    # MOVING light teal + white (onboarding-family curves)
    login_form.dart
    oauth_button.dart
    auth_logo_header.dart          # logo on teal band
`

- Prefer extracting shared wave math from `onboarding_background.dart` into a reusable painter/helper when implementing.
- Keep business logic in `AuthController`.
- Reuse `CustomTextField`, validators, OAuth button patterns from current auth module.

## Controller behavior

- `login()` / `loginWithGoogle()` — same existing auth contracts.
- Panel index / `PageController` for Sign In â†” Sign Up.
- Reactive loading / error flags.

## API endpoints

| Method | Path | Notes |
| --- | --- | --- |
| `POST` | `/api/v1/auth/login` | Email + password |
| `POST` | `/api/v1/auth/refresh` | Token refresh |

## Navigation

| From | Action | To |
| --- | --- | --- |
| Onboarding / Splash | Open auth | Auth screen (Sign In panel) |
| Sign In | Success | Home / startup |
| Sign In | Tap **Sign Up** | Sign Up panel (same screen) |
| Sign Up | Tap **Sign In** | Sign In panel (same screen) |

## Testing and acceptance criteria

- Only **teal** is fixed as the back color; wave+white sit on top and hug content.
- **No vertical or horizontal scroll/swipe**; panel changes only via **Sign Up** / **Sign In** toggles.
- White hugs form content; teal auto-fills above without layout overflow.
- Logo on teal; no Skip.
- Fields show placeholders (`Email`, `Password`).
- Forgot password is small + primary; Sign In CTA text centered; divider label small; Google label larger with no hint under it; footer small with primary Sign Up.
- Wave colors/style align with Onboarding v2 family.
- Validation, loading, Google, token save still work.

## Dependencies

- `00-foundation-prompt.md`
- `03-onboarding-prompt.md` (wave style)
- `05-register-prompt.md`
- `Prompt Frontend/COMMON_CONTEXT.md` (shared wave note)
- `Prompt Frontend/api-intergration/integration-contract.md`

## Output

Deliver (when implementing) a shared Auth shell with **fixed teal** + **moving light-teal/white waves**, Sign In form on the white sheet, and grow/shrink morph to Sign Up per register v2.
