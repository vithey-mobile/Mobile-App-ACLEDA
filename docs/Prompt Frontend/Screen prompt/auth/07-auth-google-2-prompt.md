# 07 — Google Auth Screen 2 (Account Confirmation)

Build the **Google Account Confirmation** screen from:

- `Auth Google Screen 2.png` — visual source of truth
- Root `update.md` — flow, Back behavior, vertical transitions, Profile avatar reuse


## Quick info

| Field | Value |
|-------|-------|
| Route | `AppRoutes.googleAuthConfirmation` (`/auth/google/confirm`) |
| Module | `lib/modules/auth/google_auth_screen.dart` (`GoogleAuthConfirmationScreen`) |
| Previous | Screen 1 — account chooser |
| Success | Existing Auth0 / mock `completeGoogleAuth` → post-auth navigation |
| Prompt | `Screen prompt/auth/07-auth-google-2-prompt.md` |
| Visual | `screen image/auth/Auth Google Screen 2.png` |

## Goal

Confirm the account chosen (or added) on Screen 1. **Continue** resumes the existing Auth0 / repository Google completion path. UI-only confirmation card — no Google password field.

## Transition

| Action | Animation |
|--------|-----------|
| Present from Screen 1 | Vertical **slide up** |
| Cancel / Back to Screen 1 | Vertical **slide down** |

## Layout (match `Auth Google Screen 2.png`)

`
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚         [ Google G ]          â”‚  â”‚
â”‚  â”‚      Continue to Vithey       â”‚  â”‚  Bold ~18sp
â”‚  â”‚  To continue, Google will     â”‚  â”‚  Muted, centered
â”‚  â”‚  share your name, email...      â”‚  â”‚
â”‚  â”‚                               â”‚  â”‚
â”‚  â”‚         ( large avatar )      â”‚  â”‚  ~96–100px; Profile UserAvatar
â”‚  â”‚         Full Name             â”‚  â”‚
â”‚  â”‚         email@domain          â”‚  â”‚
â”‚  â”‚                               â”‚  â”‚
â”‚  â”‚    [ Continue as {First} ]    â”‚  â”‚  Teal fill, white text
â”‚  â”‚    [       Cancel        ]    â”‚  â”‚  Grey border / light fill
â”‚  â”‚                               â”‚  â”‚
â”‚  â”‚  Already have an account.     â”‚  â”‚
â”‚  â”‚            Sign In            â”‚  â”‚  “Sign In” teal link
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
`

| Spec | Value |
|------|-------|
| Card | Centered; thin grey stroke; ~8px radius; ~24px inner pad; ~20–24px page margin |
| Google mark | Official multicolor `G` asset (`AppAssets.googleIcon`) — do not recolor |
| Heading | **Continue to Vithey** |
| Disclosure | **To continue, Google will share your name, email address, and profile picture with Vithey.** |
| Avatar | Same `UserAvatar` styling as Profile home (radius ~48–50) |
| Name / email | From selected `GoogleAccountSummary` only (one identity) |
| Primary | **Continue as {firstName}** — first token of `displayName` |
| Secondary | **Cancel** — return to Screen 1 (slide down) |
| Footer | **Already have an account.** + teal **Sign In** → cancel OAuth → Login |

Light / dark via theme + `appColors`.

## Data consistency

Avatar, full name, email, Continue label, and semantics must all come from the **same** selected account. Fix design inconsistency if mock name and button disagree (never “Continue as Heng” when name is Khorn Molika).

## Actions

| Control | Result |
|---------|--------|
| **Continue as ...** | Existing `completeGoogleAuth` / Auth0 path; show loading on button |
| **Cancel** | Pop to Screen 1 (keep chooser); clear confirmation-only state if needed |
| **Sign In** | Exit Google flow → Sign In (`cancelGoogleAuth` / until login) |

## Out of scope

- Email/password changes
- Collecting Google passwords
- Pixel-claiming this is Google’s official consent UI in production docs — this is app UI before / around Auth0 handoff
