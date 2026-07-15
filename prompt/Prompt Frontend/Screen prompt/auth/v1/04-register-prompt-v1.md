# 04 - Register / Sign Up Screen Prompt (Version 2)

Build the **Sign Up / Register panel** for the Vithey App in Flutter.

> **Do not modify** `04-register-prompt.md`. This version-2 file is the new UI direction.  
> **Pair with** `03-auth-prompt-version-2.md` — Sign Up is **not** a separate background system; it is a **panel inside the same Auth screen** that morphs (grow/shrink) with Sign In.  
> **Wave style source of truth:** Onboarding v2 / shared teal wave family (`COMMON_CONTEXT.md`).

## Design reference

![Register Screen](../../screen%20image/auth/Register%20Screen.png)

*(If the file lives at `Prompt Frontend/screen image/Register Screen.png` or under `auth/`, use the repo path that exists.)*

## Visual reference

- Reference image: `Prompt Frontend/screen image/Register Screen.png` (or `screen image/auth/` equivalent)
- Logo: same Vithey `AppLogo` / size as Sign In (fixed size — no scale on panel toggle)
- Form fields and labels follow this v2 two-part flow; **shell / motion** follow Auth v2 + Onboarding wave family.

## Quick info

| Field | Value |
| --- | --- |
| Screen ID | `04` (v2) / legacy `03B` |
| Host screen | Auth shell (`03-auth-prompt-version-2.md`) |
| Route | Prefer panel on `AppRoutes.auth` / `login`; legacy `AppRoutes.register` may alias into the same shell |
| Sign-in panel | Same Auth screen |
| Flutter module | `lib/modules/auth/` |
| Backend service | `auth-service` |
| Auth required | No (public) |
| Primary feature | Create account in **two parts** (credentials → profile) + Google on Part 1 |

## Goal

Let a new user create an account inside the **shared Auth shell**. Sign Up is **two parts**. Existing users tap footer **Sign In** (sheet shrinks).

### Register parts

| Part | Fields | Primary CTA | Secondary CTA |
| --- | --- | --- | --- |
| **Part 1** | Email, Password, Confirm Password | **Next** (teal primary) | **Continue with Google** (outline) |
| **Part 2** | Full Name, Phone Number, Date of Birth | **Sign Up** (teal primary) | **Back** (same outline chrome as Google) |

- Heading **Create Account** and footer **Already have an account.** + **Sign In** stay fixed (do not slide).
- Only **labels + text fields** slide between parts.

## Critical difference vs Onboarding v2 / vs old Register v1

| | Old Register v1 | Register v2 |
| --- | --- | --- |
| Screen | Separate full route | **Panel** on one Auth screen |
| Background | Own static wave header | Shared Auth shell: **fixed teal**, **moving** light teal + white |
| Steps | Single form | **Part 1 → Part 2** |
| Switch to Sign In | Navigate route | **Footer toggle** — sheet shrinks to Sign In |

## Screen composition

### Hosted inside Auth shell

See `03-auth-prompt-version-2.md` for fixed teal, moving wave sheet, content-driven height, logo on teal.

### Content on white — Part 1

1. **Heading** — **Create Account** (fixed, does not slide)
2. **Email Address** — placeholder **Email**
3. **Password** — placeholder **Password**, visibility toggle
4. **Confirm Password** — placeholder **Confirm Password**, visibility toggle
5. **Next** — teal primary (same style as Sign In button)
6. Divider **Sign in with** + **Continue with Google**
7. Footer → Sign In panel

### Content on white — Part 2

1. Same fixed heading / footer chrome
2. **Full Name** — placeholder **Username**
3. **Phone Number** — placeholder e.g. **012345678**
4. **Date of Birth** — read-only field + date picker
5. **Sign Up** — teal primary (submits registration)
6. **Back** — outline button (same size/font/chrome as Google; icon + Back) → returns to Part 1

### Part 1 ↔ Part 2 animation

- **Next:** Part 1 fields slide **left** out; Part 2 fields slide **in from the right**.
- **Back:** reverse (Part 2 left-to-right out… actually Part 2 slides right out, Part 1 slides in from the left).
- **Only** the field block slides — not heading, buttons, divider, or footer.
- Clip inside the form’s horizontal padding (~24): slides **vanish at the padded lane**, not at the phone screen edge.
- Keep a **gap (~24)** between Part 1 and Part 2 while they travel (not stuck edge-to-edge).

## Visual style

Same tokens as Auth v2 / Onboarding wave family.

| Token | Direction |
| --- | --- |
| Fixed back | Teal `#2FC5C1` |
| Moving rear wave | Light teal `#6AD6D2` |
| Moving body | White |
| Primary / links | `#08B9B3` |
| Heading | `#303236` |
| Input fill | `#F5F5F5` |

## Responsive behavior

- White **hugs** Sign Up content; teal above is auto.
- Wave band ≈ 10% screen height.
- **No vertical/horizontal scroll or swipe** for Sign In ↔ Sign Up; Part change only via **Next** / **Back**.
- Logo size identical on Sign In and Sign Up; **no scale** on panel morph (opacity ease only).

## Validation and interaction

- Part 1 validate before Next (email, password, confirm match).
- Part 2 validate before Sign Up (name, phone, DOB).
- Loading inside Sign Up button on Part 2.
- Google only on Part 1.
- Ignore duplicate Next/Back while step animation runs.

## Backend contract note

Registration still sends `full_name`, `email`, `phone`, `password`. DOB is collected in UI for Part 2; wire to API when backend supports it (do not block Sign Up on missing DOB API field).

## Architecture

```text
lib/modules/auth/
  login_screen.dart                # shell + Sign In / Sign Up forms
  auth_controller.dart             # registerStep, part form keys, next/back
  widgets/
    register_step_slider.dart      # clipped field slide + gap
    oauth_button.dart              # Google + AuthOutlineButton (Back)
```

## Navigation

| From | Action | To |
| --- | --- | --- |
| Sign In panel | Tap **Sign Up** | Sign Up Part 1 |
| Sign Up Part 1 | Tap **Next** (valid) | Sign Up Part 2 |
| Sign Up Part 2 | Tap **Back** | Sign Up Part 1 |
| Sign Up Part 2 | Tap **Sign Up** (valid) | Home / startup |
| Sign Up either part | Tap **Sign In** footer | Sign In panel (resets to Part 1) |

## Testing and acceptance criteria

- Part 1 = email / password / confirm; Next + Google.
- Part 2 = full name / phone / DOB; Sign Up + Back.
- Field-only clipped slide with gap; chrome stays put.
- Logo same size on both auth panels; stable across toggle.
- Validation, loading, tokens, Google (Part 1) still work.

## Dependencies

- `00-foundation-prompt.md`
- `02-onboarding-prompt-version-2.md`
- `03-auth-prompt-version-2.md`
- `Prompt Frontend/COMMON_CONTEXT.md`
- `Prompt Frontend/api-intergration/integration-contract.md`

## Output

Sign Up **Part 1** and **Part 2** inside the Auth shell, with clipped field slide and outline Back matching Google chrome.
