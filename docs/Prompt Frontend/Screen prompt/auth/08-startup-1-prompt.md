# 08 - Start Up 1 / Skills Selection Prompt (Version 2)

Build **Start Up 1**, the first post-registration profile-setup screen for the Vithey App in Flutter.

> **Pair with** `09-startup-2-prompt.md` and `10-startup-3-prompt.md`.  
> **Update source:** `update.md` (shared Startup shell / motion / theme / AppBar rules).  
> **Interaction reference:** Startup 2 selection behavior is the behavioral source of truth — **do not** copy Startup 2’s UI look onto this screen.

## Visual reference

- Reference image: `Prompt Frontend/screen image/Start Up 1.png`
- Logo asset: same Vithey `AppLogo` / `logo_app.png` as Auth (`AppAssets.logoApp`)
- Treat the image as the source of truth for **this page’s** layout, chips, copy, and hierarchy.
- Recreate responsively; do not hard-code the entire page to reference pixels.

## Quick info

| Field | Value |
| --- | --- |
| Screen ID | `08` / legacy `03E` / Start Up step 1 of 3 |
| Suggested route | `AppRoutes.startupSkills` / `Routes.STARTUP_SKILLS` |
| Previous flow | Successful registration or first social sign-in |
| Next route | Start Up 2 |
| Flutter module | `lib/modules/startup/` |
| Backend service | `user-profile-service` once the skills contract exists |
| Auth required | Yes |
| Primary feature | Select top professional skills |

## Goal

Let a newly authenticated user select professional skills for personalization. User may continue, go back, or skip.

This is **not** pre-auth marketing onboarding (`03-onboarding-prompt.md`); it is authenticated profile setup after account creation / first social login.

## Shared Startup shell (v2 — from `update.md`)

All three Startup pages share this shell. **Only the middle content** changes / animates.

`text
Scaffold
â””â”€â”€ Column
    â”œâ”€â”€ StartupAppBar                    // FIXED — logo + Skip
    â”œâ”€â”€ Expanded
    â”‚   â””â”€â”€ StartupContentSwitcher       // ANIMATES (slide) — page body only
    â””â”€â”€ StartupBottomNavigation          // FIXED — Back + dots + Next
`

### 1. Content transition animation

- Smooth **slide** when moving between Startup pages via **Next** and **Back**.
- Animate **content only** (question, supporting text, options).
- **Do not** animate AppBar or bottom actions.
- Both directions must feel natural (Next → content slides left / next in from right; Back → reverse). Prefer the same clipped-lane pattern used for Auth register Part 1 â†” Part 2 (slide stays inside content padding, not full-bleed phone edge).

### 2. AppBar

| Current | Version 2 |
| --- | --- |
| Title text **Vithey StartUp** | **Application logo** (`AppLogo`) |

- Logo fits naturally in the AppBar; keep aspect ratio; vertically center.
- Not too large or too small (rough guide ~28–32 logical px height).
- Keep right-aligned teal **Skip**.
- Theme-aware bar background + divider (no hardcoded white-only bar).
- No leading back arrow; Back stays in the bottom nav.

### 3. Interaction behavior (shared — match Startup 2)

**Behavior only — keep Startup 1’s chip UI design.**

When the user taps/selects an option:

- Selected option updates to active state immediately.
- Icon, text, and border all reflect selected/active.
- Previously selected options return to inactive (for multi-select: only the tapped chip toggles; others stay as-is unless max rules apply).
- Selection feedback must match Startup 2’s **interaction timing/feel**, not its card chrome.

Reuse Startup 2 interaction logic / shared selectable widgets where practical; avoid copy-paste.

### 4. Light & dark mode

- Icons, text, buttons, borders, fills follow app theme (`AppSemanticColors` / `ColorScheme`).
- Avoid hardcoded light-only colors.
- Selected/unselected states must remain clear in both modes.

## Screen composition — Startup 1 content (keep unique UI)

Middle content (inside the animated region), top → bottom:

1. **Question heading** — **What are your skills?** (bold heading token, ~17–18)
2. **Supporting text** — **Select your top skills to stand out to employers.** (muted, ~11–12)
3. **Skills chip group** — responsive `Wrap` of outlined selection chips (preserve Startup 1 look):
   - Icon + label; pill radius; theme fill/border/text
   - Order:

   | Order | Label | Icon direction |
   | --- | --- | --- |
   | 1 | `Graphic Design` | design/tools |
   | 2 | `Management` | organization |
   | 3 | `Coding` | code |
   | 4 | `Social Media Influence` | social/analytics |
   | 5 | `Sale` | commerce (keep singular) |
   | 6 | `Content Video` | video |
   | 7 | `AI` | technology |
   | 8 | `Marketing` | campaign |
   | 9 | `Data Analysis` | data |

4. **Flexible empty space** — `Spacer` / flexible constraints
5. **Bottom nav** (fixed shell) — Back Â· dots (step 1 active) Â· Next

## Skill selection states (visual — Startup 1 chip style)

- Selected: pale teal / teal fill, teal border, contrasting icon/text (+ semantic selected).
- Unselected: surface fill, border token, muted icon, heading/muted label.
- Toggle without large size jumps / distracting reflow.
- Prefer shared selectable chip that accepts Startup-1 styling params.

## Selection rules

- Stable skill IDs separate from labels.
- Configurable `maxSelectedSkills` (default `5` only if no existing rule).
- Require â‰¥1 skill before Next unless product allows empty.
- At max: selected remain removable; announce limit accessibly.
- **Skip** continues without selecting skills (coordinator rules).

## Visual style (Startup 1 — keep unique)

| Token | Direction |
| --- | --- |
| Page / AppBar | Theme surface |
| Heading | Theme heading |
| Supporting | Theme muted |
| Accent / active / Next | Theme primary |
| Inactive dots | Theme border / muted |
| Chip chrome | Startup 1 chip language (not Startup 2 cards) |
| Font | App theme sans |

Do **not** add wave header, search, free-text skill field, or bottom app tab bar.

## Responsive behavior

- `SafeArea`, `LayoutBuilder`, flexible constraints.
- `Wrap` for chips; â‰¥16 side padding on narrow screens.
- Content scrolls if needed; bottom nav stays reachable.
- Support small phones, tablets (max content width), large text — no overflow.

## Interaction and navigation

| Action | Behavior |
| --- | --- |
| Select skill | Toggle ID in shared draft; active chrome updates immediately |
| Next | Validate → persist draft → slide to Start Up 2 |
| Back | Per stack / coordinator (do not logout by accident) |
| Skip | Confirm if discarding selections; else mark skipped / complete per coordinator |

- Returning from step 2 restores skills.
- No duplicate routes / saves on rapid taps.
- Do **not** mark full startup complete on Next from step 1.

## Persistence and backend

Same draft / repository boundary (`StartupProfileDraft.skillIds`, `saveSkills`). Do not invent production URLs. Local draft for recovery only; clear after final submit / confirmed Skip.

## Accessibility

- Semantics for logo AppBar, Skip, chips, Back, dots (**Step 1 of 3**), Next.
- Announce selected state + count; â‰¥44×44 targets; contrast in light/dark; don’t rely on color alone.

## Architecture

`text
lib/modules/startup/
  startup_binding.dart
  startup_controller.dart
  startup_skills_screen.dart          # step 1 body
  startup_interests_screen.dart       # step 2 body
  startup_discovery_screen.dart       # step 3 body
  widgets/
    startup_app_bar.dart              # logo + Skip (FIXED)
    startup_content_switcher.dart     # slide content only
    startup_step_indicator.dart
    startup_bottom_navigation.dart    # FIXED
    selectable_skill_chip.dart        # Startup 1 look + shared select behavior
    selectable_interest_card.dart     # Startup 2 look + shared select behavior
    discovery_source_row.dart         # Startup 3 look + shared select behavior
`

- Shared controller owns draft, validation, navigation, skip.
- Content switcher owns Next/Back slide; AppBar + bottom stay outside it.

## Testing and acceptance criteria

- Matches Start Up 1 **visual** design (chips, copy, spacing).
- AppBar shows **logo**, not “Vithey StartUp”.
- Next/Back slide **content only**; chrome fixed.
- Selection behavior matches Startup 2 interaction rules; UI stays chip-style.
- Full light/dark support.
- Draft restore, limits, Skip, no overflow, no duplicate nav.

## Dependencies

- `00-foundation-prompt.md`
- `update.md`
- `09-startup-2-prompt.md`
- `10-startup-3-prompt.md`
- `04-auth-prompt.md` / register (entry into startup)
- `Prompt Frontend/COMMON_CONTEXT.md`
- Integration + user-profile service prompts

## Output

Deliver Startup step 1 with its own chip UI, shared v2 shell (logo AppBar, content slide, theme), and Startup-2-equivalent selection behavior.
