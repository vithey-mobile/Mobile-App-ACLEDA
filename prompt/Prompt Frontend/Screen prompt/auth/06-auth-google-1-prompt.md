# 06 — Google Auth Screen 1 (Account Chooser)

Build / refine **Select Google Account** from:

- `Auth Google Screen 1.png`
- Root `update.md` (**Google Auth0 - Screen 1 UI Update**)


## Quick info

| Field | Value |
|-------|-------|
| Route | `AppRoutes.googleAccountChooser` |
| Module | `lib/modules/auth/google_auth_screen.dart` |
| Entry | Continue with Google |
| Next | Screen 2 after fade + slide up |
| Prompt | `06-auth-google-1-prompt.md` |

## Layout

- **Center** content vertically and horizontally (no start-aligned column).
- Account list card unchanged in structure (rows + Add another account).
- Darker secondary grey for descriptions / emails / footer (not near-black).

## Bottom actions

1. **One primary button:** **Sign In** (app primary style) → fade → Screen 2  
2. Row under it: **Back** (normal text, tappable) + **Sign In** (`TextButton`, teal) → return to auth  
3. **Remove** the old **New Sign In** button  

## Footer

Pinned bottom, centered:

`Privacy Policy and Term of Services`

Secondary text style; UI-only unless links already exist.

## Transition to Screen 2

`text
Tap account / primary Sign In
        → fade out Screen 1 content (background stays)
        → slide up to Screen 2
`

Return from Screen 2: slide down. Do not use left/right auth transitions.

## Out of scope

Email/password, Auth0 token logic, Screen 2 layout (except shared navigation).
