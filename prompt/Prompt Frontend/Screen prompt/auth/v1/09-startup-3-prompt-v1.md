# 09 - Start Up 3 / Discovery Source Prompt (Version 2)

Build **Start Up 3**, the final post-registration profile-setup screen for the Vithey App in Flutter.

> **Do not modify** `09-startup-3-prompt.md`. This version-2 file is the new direction.  
> **Pair with** `07-startup-1-prompt-version-2.md` and `08-startup-2-prompt-version-2.md`.  
> **Update source:** `update.md`.  
> **Selection behavior** matches Startup 2 (immediate active chrome). **UI** stays this page’s full-width option rows + radios — do not copy Startup 2 cards.

## Visual reference

- Reference image: `Prompt Frontend/screen image/Start Up 3.png`
- Logo: shared AppBar `AppLogo`
- Layout, option rows, spacing, and hierarchy follow the reference.
- Production subtitle / Telegram icon corrections still apply (see below).

## Quick info

| Field | Value |
| --- | --- |
| Screen ID | `09` (v2) / legacy `03G` / Start Up step 3 of 3 |
| Suggested route | `AppRoutes.startupDiscovery` / `Routes.STARTUP_DISCOVERY` |
| Previous | Start Up 2 |
| Success | Home |
| Flutter module | `lib/modules/startup/` |
| Backend | Profile/analytics once documented |
| Auth required | Yes |
| Primary feature | Single-choice “How did you find us?” + startup completion |

## Goal

Capture optional discovery source, preserve skills/interests, submit or skip, navigate safely to Home. Must never permanently block the app or change auth status.

## Shared Startup shell (v2)

Same as steps 1–2 v2:

- Fixed AppBar: **logo** + **Skip** (replace “Vithey StartUp” text)
- Fixed bottom: Back · dots (all teal / step 3) · Next
- **Content-only slide** on Next/Back
- Theme-driven light/dark
- Startup-2-equivalent selection **behavior** (immediate active state on icon/text/border)

## Screen composition — Startup 3 content (keep unique UI)

1. **Question** — **How did you find us?**
2. **Supporting** — **Select one option to help us improve your experience.**  
   (Prefer “experience” over reference “experiences” unless product says otherwise.)
3. **Single-choice option list** — five full-width rows (Startup 3 look):
   - Leading icon · bold/medium label · trailing radio
   - Light fill, thin border, ~7–8 radius; entire row tappable
   - Order:

   | ID | Label | Icon |
   | --- | --- | --- |
   | `facebook` | Facebook | licensed Facebook mark |
   | `telegram` | Telegram | correct Telegram mark (not video/play) |
   | `teacher` | Teacher | educator |
   | `friend` | Friend | person |
   | `other` | Other | more/options |

4. **Flexible space**
5. **Bottom nav** (fixed) — Next may show loading spinner without size jump on final submit

## Selection behavior

- Radio group: zero or one selection.
- Tap row → select; clear previous; active fill/border/radio/icon/text immediately (Startup 2 interaction feel).
- No row resize / list jump.
- Store canonical ID; **Other** does not open free-text unless product adds it.

## Completion rules

- Survey optional; Skip available.
- Next with selection → submit full draft once → Home on success.
- Next with null source: allow as “prefer not to answer” (recommended) **or** require Skip — one named setting, consistent.
- Skip: prefer submit skills/interests with `discoverySourceId: null` rather than erase them (unless product says discard all — then confirm).
- On save failure: Retry + approved continue-without-saving; never trap the user.
- Final nav: `Get.offAllNamed(Home)` after completion recorded; idempotent.

## Visual style (Startup 3 — keep unique)

| Token | Direction |
| --- | --- |
| Surface / AppBar | Theme surface |
| Heading / muted | Theme heading / muted |
| Accent / radio / Next / dots | Theme primary |
| Row fill / border | Theme inputFill / border (dark-adapting) |
| Selected row | Primary-tinted + primary border / filled radio |

No wave header, multi-select checkboxes, free-text (unless product), or app tabs.

## Responsive

- Side margins ~13–16; tablet max width; scroll content if needed.
- Fixed chrome clear of system insets; no jump on select/submit.

## Shared draft & submission

```dart
class StartupProfileDraft {
  final Set<String> skillIds;
  final Set<String> interestIds;
  final String? discoverySourceId;
}
```

Final completion: snapshot draft → prevent duplicate Next/Skip → idempotent repository call → mark complete → clear draft → `offAll` Home.

Do not invent production endpoints; mock/dev flagged until contract exists.

## Back

- Slide back to Start Up 2; keep discovery selection in draft; do not submit on Back.

## Loading / errors / privacy

Same as v1: stable Next loading, retryable errors, optional analytics only, no raw API dumps, consent-aware.

## Accessibility

- Logo AppBar, Skip, radio group rows, Back, **Step 3 of 3**, Next.
- Announce selection / loading / errors; ≥44×44; light/dark contrast; not color-only.

## Architecture

Shared startup module from steps 1–2 v2. This page owns `discovery_source_row.dart` visuals; controller owns `selectDiscoverySource`, `completeStartup`, `skipStartup`, idempotency key.

## Navigation

| From | Action | To |
| --- | --- | --- |
| Start Up 2 | Next | Start Up 3 (content slide) |
| Start Up 3 | Back | Start Up 2 (content slide) |
| Start Up 3 | Next success / Skip recorded | Home (`offAll`) |

## Testing and acceptance criteria

- Matches Start Up 3 **visual** (rows, radios, copy, Telegram icon fix).
- Logo AppBar; content-only slide; theme light/dark.
- Selection behavior aligned with Startup 2; UI stays row+radio.
- Idempotent complete/Skip; draft clear; restore after Back; no overflow; failure fallback.

## Dependencies

- `00-foundation-prompt.md`
- `update.md`
- `07-startup-1-prompt-version-2.md`
- `08-startup-2-prompt-version-2.md`
- Integration + user-profile service prompts

## Output

Deliver Startup step 3 with its option-row UI, shared v2 shell (logo AppBar, content slide, theme), Startup-2-equivalent selection behavior, and safe Home completion.
