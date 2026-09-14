# 04 - Auth / Sign In Screen Prompt (Version 2)

Build the **Auth screen (Sign In panel)** for the Vithey App in Flutter.

> **Pair with** `05-register-prompt.md` — Sign In and Sign Up live on **one Auth screen** and morph between each other (grow/shrink).  
> **Background source of truth:** same shared mixed teal + white waves as Language + Onboarding (`onboarding_background.dart`).  
> **Alignment prompt:** `update.md` (Auth background + intro morph). Do not edit Language or Onboarding.

## Design reference

![Auth Screen](../../screen%20image/auth/Auth%20Screen.png)

## Visual reference

- Reference image: `Prompt Frontend/screen image/auth/Auth Screen.png` (form content / hierarchy)
- Logo: `AppLogo` / `AppAssets.logoApp` on white circle
- Recreate responsively; do not hard-code to reference pixel sizes
- **Background UI language** matches Language + Onboarding (mixed waves, **no** white overlay container)

## Quick info

| Field | Value |
| --- | --- |
| Screen ID | `04` |
| Primary route | `AppRoutes.auth` / `AppRoutes.login` |
| Sibling panel | Sign Up / Register (same screen — see `05-register-prompt.md`) |
| Flutter module | `lib/modules/auth/` |
| Shell file | `login_screen.dart` |
| Backend service | `auth-service` |
| Auth required | No (public) |
| Primary feature | Email/password + Google sign-in on a shared Auth shell |

## Goal

One **Auth screen** hosts **Sign In** and **Sign Up**. Users tap footer links to morph between panels (no swipe). This prompt defines the **Sign In** panel and the **shared shell** (background + logo + intro morph). Sign Up field details live in `05-register-prompt.md`.

Keep all Sign In / Sign Up **content**. Only chrome/background follows Language / Onboarding.

## Same family as Language + Onboarding

| | Language / Onboarding | Auth (required) |
| --- | --- | --- |
| Background | Mixed teal + light teal + white waves (`OnboardingBackground`) | **Same** widget / style |
| White overlay container | None | **None** — do not wrap forms in `AuthMovingWaveSheet` |
| Content | Language picker / slides | Sign In / Sign Up forms |
| Intro morph | Language ↔ Onboarding wave + content fade | Onboarding ↔ Auth: **content fade/rise** on shared waves |

### Critical: remove old Auth chrome

| Old Auth (do not use) | New Auth |
| --- | --- |
| Solid teal back + white moving sheet overlay | Full-page `OnboardingBackground` |
| Forms only inside white overlay | Forms sit **on** the mixed background |
| `bgMorph` / `authMorph` → solid teal | No solid-teal Auth resting state |

## Screen composition

### Shared Auth shell

```text
Scaffold
└── Stack
    ├── OnboardingBackground(onboardingFactor)   // shared with Language/Onboarding
    └── Opacity + translate (intro content reveal)
        └── Column
            ├── Expanded(~34%) → AppLogo
            └── Expanded(~66%) → AuthPanelSwitcher (Sign In | Sign Up forms)
        + Back (ghost)
```

### Background

1. **Reuse** `OnboardingBackground` with `OnboardingBackground.onboardingFactor` (same resting waves as Onboarding).
2. **Do not** set `authMorph` to solid teal for Auth resting UI.
3. **Do not** use a full-width white overlay / morphing white sheet as the form container.
4. Field fills / local cards for controls are OK; a page-level white sheet is not.

### Sign In ↔ Sign Up panel slide

Direct continuum slide (no disappear gap). Logo stays put.

| Action | Motion |
| --- | --- |
| Sign In → Sign Up | Panels move **left** (incoming from the right) |
| Sign Up → Sign In | Panels move **right** (incoming from the left) |

- White hug / `waveFactor` still content-driven.
- Footer toggles only (no swipe). Ignore duplicate taps while `isPanelAnimating`.

### Intro morph (Onboarding ↔ Auth)

Sequence (Auth-owned; Language / Onboarding unchanged):

`transition (wave) → show content → … → hide content → transition (wave) → next screen content`

| Transition | Behavior |
| --- | --- |
| Onboarding → Auth | Measure form (hidden) → morph `waveFactor` → fade content in |
| Auth → Onboarding | Fade content out → morph wave to onboarding → navigate |
| Auth Sign In ↔ Sign Up | Continuum slide; white hug lerps to each panel's content height |

- Auth forms are **bottom-aligned**; logo stays **centered in the teal band**.
- White hug is **content-driven** (errors / parts change height → wave follows).

### No swipe between Sign In / Sign Up

- Panel change **only** via footer toggles.
- `resizeToAvoidBottomInset: false` on the shell.

### Content (Sign In) — preserve

- Logo on teal band (`AppLogo`, white circle) — size ~100 like Language
- **Welcome Back**
- Email / Password fields (placeholders `Email`, `Password`)
- **Forgot password?** (small, primary, right-aligned)
- **Sign In** primary CTA
- **Sign in with** + **Continue with Google**
- Footer: **Don’t have an account?** + **Sign Up** → Sign Up panel
- Back → Onboarding (intro handoff)

Horizontal padding ~`24`. Prefer fitting content without relying on a white sheet; light scroll only if needed for small devices.

## Visual style

| Token | Direction |
| --- | --- |
| Page background | Shared Onboarding waves |
| Primary / links | `#08B9B3` / theme primary |
| Heading | `#303236` / semantic heading |
| Input fill | `#F5F5F5` |
| Font | App theme sans-serif |

Avoid: AuthTealBackdrop, AuthMovingWaveSheet on Sign In/Up, Skip, onboarding dots, solid-teal Auth end-state.

## Architecture

```text
lib/modules/auth/
  login_screen.dart              # shell + Sign In / Sign Up forms
  auth_controller.dart           # panel index, intro reveal, auth logic
  auth_binding.dart              # fadeContentIn from IntroMorph
  widgets/
    auth_panel_switcher.dart     # Sign In ↔ Sign Up continuum slide
    oauth_button.dart
    register_step_slider.dart
  onboarding/widgets/
    onboarding_background.dart   # REUSE — do not fork for Auth
```

- Keep business logic in `AuthController`.
- Reuse `CustomTextField`, validators, OAuth patterns.
- `AuthMovingWaveSheet` may remain for other screens (e.g. Forgot Password) but **not** for Sign In / Sign Up shell.

## Controller behavior

- `login()` / Google auth — existing contracts
- `showSignIn()` / `showSignUp()` — panel index
- `goBack()` — Auth → Onboarding continuous handoff
- `layoutReveal` / `contentOpacity` — intro content morph (not solid teal)

## API endpoints

| Method | Path | Notes |
| --- | --- | --- |
| `POST` | `/api/v1/auth/login` | Email + password |
| `POST` | `/api/v1/auth/refresh` | Token refresh |

## Navigation

| From | Action | To |
| --- | --- | --- |
| Onboarding | Finish / Get Started | Auth (Sign In) + content morph |
| Auth | Back | Onboarding (continuous waves) |
| Sign In | Success | Home / startup |
| Sign In | Tap **Sign Up** | Sign Up panel (same screen) |
| Sign Up | Tap **Sign In** | Sign In panel (same screen) |

## Testing and acceptance criteria

- [ ] Auth uses same mixed wave background as Language / Onboarding (no white overlay sheet).
- [ ] Sign In and Sign Up content preserved and usable.
- [ ] Sign In ↔ Sign Up continuum slide (Sign Up from right, Sign In from left).
- [ ] Onboarding → Auth content morph is continuous (no hard cut to solid teal / white sheet).
- [ ] Auth → Onboarding back stays in the same wave family.
- [ ] Language and Onboarding modules unchanged.
- [ ] Validation, loading, Google, tokens still work.

## Dependencies

- `03-onboarding-prompt.md` / Select Language (background reference only)
- `05-register-prompt.md`
- `update.md` (alignment requirements)
- `Prompt Frontend/COMMON_CONTEXT.md` if present

## Output

Shared Auth shell on **OnboardingBackground**, Sign In form content on that surface, grow/shrink morph to Sign Up per register v2, intro morph aligned with Language ↔ Onboarding.
