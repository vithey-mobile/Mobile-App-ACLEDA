# 05 - Register / Sign Up Screen Prompt (Version 2)

Build the **Sign Up / Register panel** for the Vithey App in Flutter.

> **Pair with** `04-auth-prompt.md` — Sign Up is **not** a separate background system; it is a **panel inside the same Auth screen** that morphs (grow/shrink) with Sign In.  
> **Background:** shared Language / Onboarding mixed waves (`OnboardingBackground`) — **no** white overlay sheet.  
> **Do not** change Language or Onboarding modules.

## Design reference

![Register Screen](../../screen%20image/auth/Register%20Screen.png)

*(If the file lives at `Prompt Frontend/screen image/Register Screen.png` or under `auth/`, use the repo path that exists.)*

## Visual reference

- Reference image for **form fields / two-part flow** (not for old white-sheet chrome)
- Logo: same Vithey `AppLogo` as Sign In (fixed size — subtle opacity ease only on panel toggle)
- Shell / background follow `04-auth-prompt.md` + `update.md`

## Quick info

| Field | Value |
| --- | --- |
| Screen ID | `05` / legacy `03B` |
| Host screen | Auth shell (`04-auth-prompt.md` / `login_screen.dart`) |
| Route | Prefer panel on `AppRoutes.auth` / `login`; legacy `AppRoutes.register` may alias into the same shell |
| Sign-in panel | Same Auth screen |
| Flutter module | `lib/modules/auth/` |
| Backend service | `auth-service` |
| Auth required | No (public) |
| Primary feature | Create account in **two parts** (credentials → profile) + Google on Part 1 |

## Goal

Let a new user create an account inside the **shared Auth shell** (same background as Language / Onboarding). Sign Up is **two parts**. Existing users tap footer **Sign In** (panel shrinks).

Preserve all Sign Up content (fields, buttons, texts). Background/chrome only follows Auth shell v2 alignment.

### Register parts

| Part | Fields | Primary CTA | Secondary CTA |
| --- | --- | --- | --- |
| **Part 1** | Email, Password, Confirm Password | **Next** (teal primary) | **Continue with Google** (outline) |
| **Part 2** | Full Name, Phone Number, Date of Birth | **Sign Up** (teal primary) | **Back** (same outline chrome as Google) |

- Heading **Create Account** and footer **Already have an account.** + **Sign In** stay fixed (do not slide).
- Only **labels + text fields** slide between parts.

## Hosted inside Auth shell

See `04-auth-prompt.md`:

- Full-page `OnboardingBackground` (mixed teal + white)
- **No** `AuthMovingWaveSheet` / white overlay container around Sign Up
- `AuthPanelSwitcher` height morph Sign In ↔ Sign Up
- Intro morph Onboarding ↔ Auth on shared waves

### Content — Part 1 (preserve)

1. **Heading** — **Create Account** (fixed, does not slide)
2. **Email Address** — placeholder **Email**
3. **Password** — placeholder **Password**, visibility toggle
4. **Confirm Password** — placeholder **Confirm Password**, visibility toggle
5. **Next** — teal primary
6. Divider **Sign in with** + **Continue with Google**
7. Footer → Sign In panel

### Content — Part 2 (preserve)

1. Same fixed heading / footer chrome
2. **Full Name** — placeholder **Username**
3. **Phone Number** — placeholder e.g. **012345678**
4. **Date of Birth** — read-only field + date picker
5. **Sign Up** — teal primary (submits registration)
6. **Back** — outline button (same size/font/chrome as Google; icon + Back) → Part 1

### Part 1 ↔ Part 2 animation

- **Next:** Part 1 fields slide **left** out; Part 2 fields slide **in from the right**.
- **Back:** reverse.
- **Only** the field block slides — not heading, buttons, divider, or footer.
- Clip inside the form’s horizontal padding (~24).
- Keep a **gap (~24)** between Part 1 and Part 2 while they travel.

## Visual style

Same tokens as Auth shell / Onboarding wave family (no separate white sheet chrome).

| Token | Direction |
| --- | --- |
| Page background | Shared Onboarding waves |
| Primary / links | Theme primary |
| Heading | Semantic heading |
| Input fill | `#F5F5F5` |

## Responsive behavior

- Forms sit on the shared background; prefer fitting without a page white sheet.
- **No** horizontal swipe for Sign In ↔ Sign Up; panel change only via footer.
- Part change only via **Next** / **Back**.
- Logo size identical on Sign In and Sign Up.

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
    auth_panel_switcher.dart       # panel height morph (no white sheet)
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

- [ ] Sign Up uses the same Auth shell background as Sign In / Language / Onboarding (no white overlay).
- [ ] Part 1 = email / password / confirm; Next + Google.
- [ ] Part 2 = full name / phone / DOB; Sign Up + Back.
- [ ] Field-only clipped slide with gap; chrome stays put.
- [ ] Logo same size on both auth panels.
- [ ] Validation, loading, tokens, Google (Part 1) still work.
- [ ] Language / Onboarding unchanged.

## Dependencies

- `04-auth-prompt.md`
- `update.md`
- Onboarding / Select Language (background reference only)
- `Prompt Frontend/COMMON_CONTEXT.md` if present

## Output

Sign Up **Part 1** and **Part 2** inside the Auth shell on shared Onboarding waves, with clipped field slide and outline Back matching Google chrome.
