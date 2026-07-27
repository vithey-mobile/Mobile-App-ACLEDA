# 09 - Start Up 3 / Discovery Source Prompt (v1)

Build **Start Up 3**, the final post-registration profile-setup screen for the Vithey App in Flutter, matching the supplied reference and the shared Startup shell from `update.md`.

> **Do not modify** `v0/09-startup-3-prompt.md` or `update.md`.  
> This file is the complete v1 prompt for Startup 3 (shell, content, draft completion, API notes, a11y, acceptance).  
> Pair with `v1/07-startup-1-prompt-v1.md` and `v1/08-startup-2-prompt-v1.md`.  
> **Selection behavior** matches Startup 2 (immediate active chrome). **UI** stays this page’s full-width option rows + radios — do not copy Startup 2 cards.

## Visual reference

- Reference image: `Prompt Frontend/screen image/Start Up 3.png` (or `auth/Start Up 3.png` if colocated)
- Logo: shared AppBar `AppLogo` / `AppAssets.logoApp`
- Reference canvas: approximately `302 × 656 px` (portrait mobile) — recreate responsively; do not hard-code the whole page to reference dimensions.
- Treat the image as the source of truth for option-row styling, spacing, and hierarchy.
- Production subtitle / Telegram icon corrections still apply (see below).

## Quick info

| Field | Value |
|---|---|
| Screen ID | `09` (v1) / legacy `03G` / Start Up step 3 of 3 |
| Suggested route | `AppRoutes.startupDiscovery` / `Routes.STARTUP_DISCOVERY` |
| Previous route | Start Up 2 / `Routes.STARTUP_INTERESTS` |
| Success route | Home / `Routes.HOME` |
| Flutter module | `lib/modules/startup/` |
| Backend owner | Profile/analytics service once the startup contract is documented |
| Auth required | Yes |
| Primary feature | Single-choice “How did you find us?” survey and startup completion |

## Goal

Ask how the user discovered Vithey, preserve the skills and interests selected in steps 1–2, then submit or skip the complete startup flow and navigate safely to Home.

This survey is optional profile/analytics data. It must never block access to the app permanently, alter authentication status, or be used for sensitive profiling.

## Shared Startup shell (v1 — from `update.md`)

All three Startup pages share this shell. **Only the middle content** changes / animates.

```text
Scaffold
└── Column
    ├── StartupAppBar                    // FIXED — logo + Skip
    ├── Expanded
    │   └── StartupContentSwitcher       // ANIMATES (slide) — page body only
    └── StartupBottomNavigation          // FIXED — Back + dots + Next
```

### 1. Content transition animation

- Smooth **slide** when moving between Startup pages via **Next** and **Back**.
- Animate **content only** (question, supporting text, options).
- **Do not** animate AppBar or bottom actions.
- Both directions must feel natural. Prefer the same clipped-lane pattern used for Auth register Part 1 ↔ Part 2.

### 2. AppBar

| Spec | Value |
|---|---|
| Leading title | **Application logo** (`AppLogo`) — replace text **Vithey StartUp** |
| Logo size | ~28–32 logical px height; keep aspect ratio; vertically center |
| Trailing | Teal **Skip** |
| Background | Theme surface + subtle bottom divider (not hardcoded white-only) |
| Back | No leading arrow; Back stays in bottom nav |

### 3. Interaction behavior (shared — match Startup 2)

**Behavior only — keep Startup 3’s row + radio UI.**

When the user taps/selects an option:

- Selected option updates to active state immediately.
- Icon, text, and border all reflect selected/active.
- Previous selection clears (radio group).
- Selection feedback must match Startup 2’s **interaction timing/feel**, not its card chrome.

### 4. Light & dark mode

- Icons, text, buttons, borders, fills follow app theme (`AppSemanticColors` / `ColorScheme`).
- Avoid hardcoded light-only colors.
- Selected/unselected states must remain clear in both modes.

## Screen composition — Startup 3 content

Middle content (inside the animated region), top → bottom:

1. **Question heading** — **How did you find us?**  
   Bold dark charcoal / theme heading, approximately `17–18 px`. Horizontal padding ~13–16 px.

2. **Supporting text** — **Select one option to help us improve your experience.**  
   Small muted text (~11 px). Prefer “experience” over reference “experiences” unless product approves the plural.

3. **Single-choice option list** — five full-width rounded selection rows:
   - Leading icon · bold/medium label · trailing radio
   - Very light gray / theme input fill, thin border, ~7–8 px radius
   - Row height ~45–46 px with ~13–16 px inner horizontal padding
   - Entire row tappable, not only the radio

   | ID | Label | Icon direction |
   |---|---|---|
   | `facebook` | `Facebook` | approved Facebook brand mark |
   | `telegram` | `Telegram` | correct Telegram mark (not video/play) |
   | `teacher` | `Teacher` | graduation cap/educator icon |
   | `friend` | `Friend` | user/person icon |
   | `other` | `Other` | neutral more/options icon |

4. **Flexible empty space** — `Spacer` or flexible constraints (not fixed Y coordinates).

5. **Bottom step navigation** (fixed shell) — Back · three teal dots (step 3 of 3) · teal **Next**  
   Preserve minimum `44 px` tap targets. While final submission runs, keep button size stable and show a compact loading indicator.

Do not add a wave header, logo in the content body, multi-select checkboxes, free-text field, explanatory modal, bottom app-navigation bar, or extra discovery sources not shown in the reference.

## Selection behavior

- Radio group: exactly zero or one option may be selected.
- Tapping a row selects it and clears any previous selection; active fill/border/radio/icon/text update immediately.
- Unselected: light/theme fill and border, dark/muted label, empty radio outline.
- Selected: teal radio center, teal border or pale-teal background, plus non-color semantic selected state.
- Selection must not resize the row or shift the list.
- Store canonical ID rather than display label.
- **Other** remains a simple selectable option — no free-text unless product adds one.

## Completion rules

- Survey is optional; **Skip** is always available.
- If a source is selected, **Next** submits the full startup draft once and navigates to Home after success.
- If no source is selected, either enable Next as “prefer not to answer” or require Skip; choose one behavior via a named product setting. Recommended default: allow Next with a null source.
- **Skip** should prefer submitting skills/interests with `discoverySourceId: null` rather than erasing them, unless product defines Skip as discarding the whole draft (then confirm when discarding).
- Never trap the user on save failure; provide Retry and **Continue without saving** where approved.
- Final navigation: `Get.offAllNamed(Routes.HOME)` after completion is recorded; idempotent.

## Visual style (Startup 3 — keep unique)

| Token | Direction |
|---|---|
| Page / AppBar | Theme surface |
| Main text | Theme heading / dark charcoal |
| Supporting text | Theme muted |
| Accent / radio / progress / Next | Theme primary (Vithey teal) |
| Option background | Theme inputFill / very light gray |
| Option border | Theme border |
| Selected option | Primary-tinted + primary border / filled radio |
| Font | App theme sans |

## Responsive behavior

- Use `SafeArea`, `LayoutBuilder`, and flexible constraints.
- Keep ~13–16 px side margins on phones; constrain max width on tablets.
- Allow main content to scroll on short screens, landscape, localization, and large text.
- Keep bottom controls clear of gesture insets.
- Let long localized labels wrap without colliding with the radio.
- Prevent layout jumps when selecting, validating, or submitting.

## Shared startup draft and final submission

```dart
class StartupProfileDraft {
  final Set<String> skillIds;
  final Set<String> interestIds;
  final String? discoverySourceId;
}
```

On final completion:

1. Freeze a snapshot of the current draft.
2. Prevent duplicate Next/Skip submissions.
3. Submit through one idempotent repository operation where possible.
4. Mark startup setup completed only after the server accepts the request, or after the user chooses continue-without-saving under an approved policy.
5. Clear temporary local draft data.
6. Navigate with `Get.offAllNamed(Routes.HOME)` so startup screens leave the back stack.

Use an idempotency key/request ID so a retry cannot create duplicate analytics or profile records.

## Backend contract note

The current backend prompts may not define fields/endpoints for skills, interests, discovery source, or atomic startup completion. Do not silently write these into an unrelated profile property, and do not invent a production URL.

Define a typed boundary such as:

```dart
Future<StartupCompletionResult> completeStartupProfile(
  StartupProfileDraft draft, {
  required String idempotencyKey,
});
```

Before production wiring, document owning service, canonical IDs, null discovery acceptance, atomicity/idempotency, response envelope, and retention/consent rules.

If no backend exists yet, allow a clearly flagged mock/dev implementation. Production must not claim personalization was saved when the draft was discarded.

## Skip behavior

- Skip is always available because the survey is optional.
- If step-1/2 choices exist, preferred behavior is submit those with `discoverySourceId: null`.
- If Skip means bypass all startup personalization, confirm only when it would discard existing selections.
- Persist startup completion/skipped state through the documented backend contract. Local storage is a routing cache only.
- Skip navigation must be idempotent and use `Get.offAllNamed(Routes.HOME)` after completion is recorded.

## Back behavior

- **Back** returns to Start Up 2 with a content-only reverse slide.
- Preserve the discovery-source selection in the shared draft.
- Do not submit the startup draft when navigating Back.
- Do not lose skill or interest selections.

## Loading and errors

- Show a spinner within Next while final submission is pending; retain button dimensions.
- Disable duplicate navigation and selection changes during the final commit.
- Show concise, user-friendly retryable errors; never expose raw response bodies or stack traces.
- For offline/unavailable backend, preserve the draft securely for retry and offer the approved continue-without-saving path.
- If the session expires, preserve non-sensitive draft data, reauthenticate, and resume if supported.

## Privacy and analytics

- Treat discovery source as optional analytics data.
- Collect only the selected canonical category.
- Do not send to third-party analytics until consent/policy permit it.
- Avoid logging the complete startup draft in production.
- Support later correction/deletion if the backend associates this data with the user.

## Accessibility

- Semantic labels for logo AppBar, Skip, each option row, Back, step indicator (**Step 3 of 3**), and Next.
- Group options as a radio group; announce selected/unselected.
- Ensure controls are at least `44 × 44` logical pixels.
- Do not rely only on color for selection; use radio state and semantics.
- Maintain contrast in light and dark mode.
- Support logical focus order; announce loading, success, and error states.

## Architecture

```text
lib/modules/startup/
  startup_binding.dart
  startup_controller.dart
  startup_skills_screen.dart
  startup_interests_screen.dart
  startup_discovery_screen.dart
  widgets/
    startup_app_bar.dart              # logo + Skip (FIXED)
    startup_content_switcher.dart     # slide content only
    startup_step_indicator.dart
    startup_bottom_navigation.dart    # FIXED
    discovery_source_row.dart         # Startup 3 look + shared select behavior

lib/data/models/
  discovery_source_option.dart
  startup_profile_draft.dart
  startup_completion_result.dart

lib/data/repositories/
  profile_repository.dart
```

Suggested option model:

```dart
class DiscoverySourceOption {
  final String id;
  final String label;
  final IconData icon;
}
```

Controller responsibilities:

- Expose the five ordered discovery options.
- Maintain observable `String? selectedDiscoverySourceId`.
- Restore selection from the shared draft.
- Implement `selectDiscoverySource(String id)`.
- Implement `backFromDiscovery()`, `completeStartup()`, and `skipStartup()`.
- Generate/reuse an idempotency key across retries.
- Expose saving/error state and prevent duplicate finalization.
- Clear the draft only after the defined terminal outcome.

## Navigation

| From | Action | To |
|---|---|---|
| Start Up 2 | Tap **Next** | Start Up 3 (content slide) |
| Start Up 3 | Tap **Back** | Start Up 2 (content slide) |
| Start Up 3 | Tap **Next**, save succeeds | Home (`offAll`) |
| Start Up 3 | Tap **Skip**, completion recorded | Home (`offAll`) |

## Testing and acceptance criteria

- Screen matches `Start Up 3.png`: heading, five full-width option rows, trailing radios, flexible whitespace, three teal progress dots, Back, teal Next.
- AppBar shows **logo**, not “Vithey StartUp”.
- Next/Back slide **content only**; chrome fixed.
- Selection behavior matches Startup 2 interaction rules; UI stays row + radio.
- Full light/dark support.
- Production subtitle uses **experience**; Telegram uses an appropriate Telegram icon.
- Options restore correctly after Back; Other does not open free-text.
- Skills, interests, and discovery source finalize from one draft snapshot.
- Next and Skip are idempotent; no duplicate submissions or routes.
- Save failure offers Retry and approved non-blocking fallback.
- Successful completion clears the draft and replaces the stack with Home.
- No overflow on small phones, tablets, landscape, localization, or large text.

## Dependencies

- `00-foundation-prompt.md` / `Prompt Frontend/COMMON_CONTEXT.md`
- `update.md` (do not edit while implementing)
- `v1/07-startup-1-prompt-v1.md`
- `v1/08-startup-2-prompt-v1.md`
- `Prompt Frontend/api-intergration/integration-contract.md`
- `Prompt Backend/services/user-profile-service/SERVICE_PROMPT.md`

## Output

Deliver a polished, responsive Start Up step 3 screen that reproduces the discovery-source survey, uses the shared v1 Startup shell (logo AppBar, content-only slide, theme), applies Startup-2-equivalent selection behavior, safely finalizes the three-step draft, and navigates idempotently to Home.
