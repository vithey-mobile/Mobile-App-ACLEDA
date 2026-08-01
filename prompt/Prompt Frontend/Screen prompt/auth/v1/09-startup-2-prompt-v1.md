# 09 - Start Up 2 / Interests Selection Prompt (Version 2)

Build **Start Up 2**, the second post-registration profile-setup screen for the Vithey App in Flutter.

> **Do not modify** `08-startup-2-prompt.md`. This version-2 file is the new direction.  
> **Pair with** `v1/08-startup-1-prompt-v1.md` and `v1/10-startup-3-prompt-v1.md`.  
> **Update source:** `update.md`.  
> **This page’s selection interaction is the behavioral reference** for steps 1 and 3 — keep this page’s **card UI** unique; other pages must not clone its look.

## Visual reference

- Reference image: `Prompt Frontend/screen image/Start Up 2.png`
- Logo: same Vithey `AppLogo` in shared AppBar
- Layout, card proportions, two-column grid, and hierarchy follow the reference.
- Production copy fixes grammar from the mockup (see below).

## Quick info

| Field | Value |
| --- | --- |
| Screen ID | `09` (v1) / legacy `03F` / Start Up step 2 of 3 |
| Suggested route | `AppRoutes.startupInterests` / `Routes.STARTUP_INTERESTS` |
| Previous | Start Up 1 |
| Next | Start Up 3 |
| Flutter module | `lib/modules/startup/` |
| Backend | profile / preferences once documented |
| Auth required | Yes |
| Primary feature | Select feed-personalization interests |

## Goal

Choose topics for feed personalization. Preserve Start Up 1 skills. Allow Back / Next / Skip in the shared three-step flow.

## Shared Startup shell (v2)

Same as `07-startup-1-prompt-version-2.md`:

- Fixed **AppBar** with **logo** + **Skip** (not “Vithey StartUp” text)
- Fixed **bottom** Back · dots · Next
- **Content-only slide** on Next/Back
- Full **light/dark** via theme tokens
- Shared selection **behavior** (this screen is the interaction model)

## Screen composition — Startup 2 content (keep unique UI)

1. **Question** — **What are you interested in?**
2. **Supporting** — **Choose your favorite topics to personalize your feed.**  
   (Do not ship mockup typos: “favorate”, duplicated “to your”.)
3. **Interest grid** — two equal columns of cards (Startup 2 look):
   - Light fill, thin border, ~6–8 radius; icon above/near label; upper-left alignment
   - Allow two-line labels
   - Spacing ~15–16 page padding, ~14–16 column gap, ~12 row gap
4. **Flexible space**
5. **Bottom nav** (fixed) — dots: step 2 active; step 1 completed/teal as in system

## Categories

Production catalog (unique IDs). Do not ship duplicate Sports / ambiguous Interested except in screenshot fixtures.

| ID | Display label | Icon direction |
| --- | --- | --- |
| `academic_news` | Academic News | graduation cap |
| `campus_events` | Campus Events | calendar |
| `student_life` | Student Life | people |
| `workshops` | Workshops | tools |
| `career_opportunities` | Career Opportunities | briefcase |
| `digital_technology` | Digital and Technology | device |
| `sports` | Sports | sports |
| `arts_culture` | Arts and Cultures | arts/culture |

Catalog must be configurable for approved replacements of fixture tiles.

## Selection states & rules (behavioral source of truth)

When user taps a card:

- Card goes active immediately (fill, border, icon, text).
- Non-color cue (check / semantic selected).
- Other cards stay as their own state (multi-select); tapping again deselects.
- No card resize / grid jump.

Rules:

- `Set<String>` of interest IDs
- Configurable min/max (temp default ≥1, ≤5 if no product rule)
- At max: removable selected; accessible limit message
- **Skip** to continue without interests
- Do not auto-select from skills

## Visual style (Startup 2 — keep unique)

| Token | Direction |
| --- | --- |
| Surface / AppBar | Theme surface |
| Heading / muted | Theme heading / muted |
| Accent / Next / active | Theme primary |
| Card fill / border | Theme inputFill / border (or Startup-2 specific tokens that adapt to dark) |
| Selected card | Primary-tinted fill + primary border |

No wave header, search, free-text interest field, or app bottom tabs.

## Responsive

- Two columns when readable; one column on very narrow / large text.
- Tablet: max content width.
- Scroll content if needed; fixed chrome stays reachable.

## Navigation

| Action | Behavior |
| --- | --- |
| Back | Slide to Start Up 1; preserve skills + interests draft |
| Next | Validate → slide to Start Up 3 |
| Skip | Coordinator rules; confirm if discarding |

- Restore interests when returning from step 3.
- No duplicate routes/saves.
- Do not complete full startup on Next from step 2.

## Persistence

Extend draft:

```dart
class StartupProfileDraft {
  final Set<String> skillIds;
  final Set<String> interestIds;
}
```

`saveInterests` only when backend is documented. Canonical IDs, not display strings.

## Accessibility

- Semantics for logo AppBar, Skip, cards, Back, **Step 2 of 3**, Next.
- Announce selection count / max; ≥44×44; light/dark contrast; not color-only.

## Architecture

Same shared module as step 1 v2. This page owns `selectable_interest_card.dart` visuals; selection controller APIs are shared (`toggleInterest`, draft restore).

## Testing and acceptance criteria

- Matches Start Up 2 **visual** (cards, grid, production copy).
- Logo AppBar; content-only slide; theme light/dark.
- Interaction remains the reference for other Startup pages.
- Draft preserve/restore; min/max; Skip; no overflow.

## Dependencies

- `00-foundation-prompt.md`
- `update.md`
- `07-startup-1-prompt-version-2.md`
- `09-startup-3-prompt-version-2.md`
- Integration + user-profile service prompts

## Output

Deliver Startup step 2 with its card UI, shared v2 shell, and the canonical selection interaction other steps must follow.
