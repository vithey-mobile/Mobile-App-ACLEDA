# 03G - Start Up 3 / Discovery Source Prompt

Build **Start Up 3**, the final post-registration profile-setup screen for the Vithey App in Flutter, matching the supplied reference image as closely as possible.

## Visual reference

- Reference image: `Prompt Frontend/screen image/Start Up 3.png`
- Reference canvas: approximately `302 × 656 px` (portrait mobile)
- Treat the image as the source of truth for layout, option-row styling, spacing, and navigation hierarchy.
- Recreate the screen responsively; do not hard-code the whole page to the reference dimensions.

## Quick info

| Field | Value |
|---|---|
| Screen ID | `03G` / Start Up step 3 of 3 |
| Suggested route | `Routes.STARTUP_DISCOVERY` |
| Previous route | `Routes.STARTUP_INTERESTS` |
| Success route | `Routes.HOME` |
| Flutter module | `lib/modules/startup/` |
| Backend owner | Profile/analytics service once the startup contract is documented |
| Auth required | Yes |
| Primary feature | Single-choice “How did you find us?” survey and startup completion |

## Goal

Ask how the user discovered Vithey, preserve the skills and interests selected in steps 1–2, then submit or skip the complete startup flow and navigate safely to Home.

This survey is optional profile/analytics data. It must never block access to the app permanently, alter authentication status, or be used for sensitive profiling.

## Screen composition

Build the screen from top to bottom in this order:

1. **System status-bar area**
   - White or very light background with dark system status-bar icons.
   - Respect `SafeArea`.
   - Do not manually draw time, signal, Wi-Fi, or battery indicators.

2. **Top navigation bar**
   - White background with a subtle bottom divider.
   - Left-aligned bold title: **Vithey StartUp**.
   - Right-aligned teal text action: **Skip**.
   - Use approximately `16 px` horizontal padding and keep both actions vertically centered.
   - Do not add a leading arrow; Back remains in the bottom navigation.

3. **Question heading**
   - Left-aligned text: **How did you find us?**
   - Bold dark charcoal, approximately `17–18 px`.
   - Keep approximately `13–16 px` horizontal page padding.

4. **Supporting text**
   - Production copy: **Select one option to help us improve your experience.**
   - Use small muted-gray text, approximately `11 px` in the reference.
   - The reference uses “experiences.” Treat that as a copy-edit issue unless the product team explicitly approves it.

5. **Single-choice option list**
   - Render five full-width rounded selection rows with consistent vertical spacing.
   - Each row contains:
     - A small leading icon.
     - A bold/medium option label.
     - A trailing radio indicator.
   - Use a very light gray row fill, thin cool-gray border, and approximately `7–8 px` corner radius.
   - Row height is approximately `45–46 px` in the reference with `13–16 px` inner horizontal padding.
   - The entire row is tappable, not only the radio circle.

   Display options in this exact order:

   | ID | Label | Icon direction |
   |---|---|---|
   | `facebook` | `Facebook` | approved Facebook brand mark |
   | `telegram` | `Telegram` | approved Telegram brand mark/paper-plane icon |
   | `teacher` | `Teacher` | graduation cap/educator icon |
   | `friend` | `Friend` | user/person icon |
   | `other` | `Other` | neutral more/options icon |

   The reference's Telegram mark resembles a generic video/play icon. Use the correct licensed Telegram icon in production rather than reproducing an incorrect provider mark.

6. **Flexible empty space**
   - Preserve the generous clean area between the options and bottom navigation.
   - Use `Spacer` or flexible constraints instead of fixed vertical coordinates.

7. **Bottom step navigation**
   - Anchor controls above the bottom safe area.
   - Left: dark-gray text button **Back**.
   - Center: three small teal dots, indicating step 3 of 3 and all steps reached/completed.
   - Right: teal pill button **Next** with white text, matching the reference wording even though this is the final step.
   - Preserve a minimum `44 px` logical tap target despite the compact visible control.
   - While final submission runs, keep the button size stable and show a compact loading indicator.

## Selection behavior

- This is a radio group: exactly zero or one option may be selected.
- Tapping a row selects it and clears any previous selection.
- Unselected row: light neutral fill/border, dark label, empty radio outline.
- Selected row: teal radio center, teal border or pale-teal background, and a non-color semantic selected state.
- Selection must not resize the row or shift the list.
- The selected value is stored as a canonical ID rather than the display label.
- **Other** remains a simple selectable option because no free-text field appears in the reference. Do not reveal a text input unless product requirements explicitly add one.

## Completion rules

- Because the survey is optional and **Skip** is visible, the user must be able to complete setup without choosing a discovery source.
- If a source is selected, **Next** submits the full startup draft once and navigates to Home after success.
- If no source is selected, either enable Next as “prefer not to answer” behavior or require the user to use Skip; choose one behavior consistently through a named product setting. Recommended default: allow Next with a null source because the question is optional.
- **Skip** completes/skips the remaining setup without discarding already chosen skills/interests unless the product explicitly defines Skip as discarding the whole draft.
- Never keep the user trapped on this analytics question due to save failure; provide Retry and **Continue without saving** where appropriate.

## Visual style

| Token | Direction |
|---|---|
| Page/top bar | White / very light cool gray |
| Main text | Dark charcoal, approximately `#303236` |
| Supporting text | Muted gray |
| Accent/radio/progress/Next | Vithey teal, approximately `#08B9B3` |
| Option background | Very light gray, approximately `#F7F8F8` |
| Option border/radio outline | Light cool gray |
| Selected option | Pale teal or teal accent with accessible contrast |
| Divider | Very light neutral gray |
| Font | App theme font with a clean sans-serif appearance |

Do not add a wave header, logo, multi-select checkboxes, free-text field, explanatory modal, bottom app-navigation bar, or extra discovery sources not shown in the reference.

## Responsive behavior

- Use `SafeArea`, `LayoutBuilder`, and flexible constraints instead of fixed coordinates.
- Keep approximately `13–16 px` side margins on phones.
- Constrain content to a sensible maximum width on tablets.
- Allow the main content to scroll on short screens, landscape, localization, and increased text scale.
- Keep bottom controls reachable and clear of gesture/navigation insets.
- Let long localized option labels wrap or scale within a row without colliding with the radio indicator.
- Prevent layout jumps when selecting, validating, or submitting.

## Shared startup draft and final submission

Extend the draft created by steps 1–2:

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
3. Submit the snapshot through one idempotent repository operation where possible.
4. Mark startup setup as completed only after the server accepts the request, or after the user explicitly chooses to continue without saving under an approved offline/failure policy.
5. Clear temporary local draft data.
6. Navigate with `Get.offAllNamed(Routes.HOME)` so startup screens are removed from the back stack.

Use an idempotency key/request ID so a retry cannot create duplicate analytics or profile records.

## Backend contract note

The current backend prompts do not define fields/endpoints for skills, interests, discovery source, or atomic startup completion. Do not silently write these values into an unrelated profile/settings property, and do not invent a production URL.

Define a typed boundary such as:

```dart
Future<StartupCompletionResult> completeStartupProfile(
  StartupProfileDraft draft, {
  required String idempotencyKey,
});
```

Before production wiring, document:

- The owning service and endpoint.
- Canonical skill, interest, and discovery-source IDs.
- Whether omitted/null discovery source is accepted.
- Atomicity and retry/idempotency behavior.
- Response envelope and startup-completed field.
- Analytics retention, consent, and deletion rules.

If no backend exists yet, allow a clearly flagged mock/dev implementation. Production must not silently claim personalization was saved when the draft was discarded.

## Skip behavior

- Skip is always available because the survey is optional.
- If step-1/2 choices exist, the recommended behavior is to submit those choices with `discoverySourceId: null` rather than erase them.
- If Skip means bypass all startup personalization, show a confirmation only when it would discard existing selections.
- Persist a startup completion/skipped state through the documented backend contract. Use local storage only as a routing cache, not the source of truth across devices.
- Skip navigation must be idempotent and use `Get.offAllNamed(Routes.HOME)` after completion is recorded.

## Back behavior

- **Back** returns to `Routes.STARTUP_INTERESTS`.
- Preserve the discovery-source selection in the shared draft so returning to step 3 restores it.
- Do not submit the startup draft when navigating Back.
- Do not lose skill or interest selections.

## Loading and errors

- Show a spinner within Next while final submission is pending and retain the button's dimensions.
- Disable duplicate navigation and selection changes during the final commit.
- Show concise, user-friendly retryable errors; never expose raw response bodies or stack traces.
- For an offline or unavailable backend, preserve the draft securely for retry and offer the product-approved continue-without-saving path.
- If the session expires, preserve non-sensitive draft data, route through reauthentication, and resume safely if supported.

## Privacy and analytics

- Treat discovery source as optional analytics data.
- Collect only the selected canonical category, not unrelated account/device information.
- Do not send the value to third-party analytics until the project's consent and privacy policy permit it.
- Avoid logging the user's complete startup draft in production.
- Support later correction/deletion if the backend associates this data with the user's profile.

## Accessibility

- Add semantic labels for the page title, Skip, each option row, Back, step indicator, and Next.
- Group the options as a radio group and announce selected/unselected state.
- Announce **Step 3 of 3** for the progress indicator.
- Ensure all rows and controls are at least `44 × 44 logical pixels`.
- Do not rely only on color to indicate selection; use the radio state and semantics.
- Maintain sufficient text, icon, border, and focus contrast.
- Support logical keyboard/focus order from header through options to bottom controls.
- Announce final loading, success, and error states.

## Architecture

Use the shared startup module established in steps 1–2:

```text
lib/modules/startup/
  startup_binding.dart
  startup_controller.dart
  startup_skills_screen.dart
  startup_interests_screen.dart
  startup_discovery_screen.dart
  widgets/
    startup_header.dart
    startup_step_indicator.dart
    startup_bottom_navigation.dart
    discovery_source_row.dart

lib/data/models/
  discovery_source_option.dart
  startup_profile_draft.dart
  startup_completion_result.dart

lib/data/repositories/
  profile_repository.dart
```

- Keep discovery options as ordered typed data rather than repeated widget literals.
- Reuse the header, step indicator, and bottom navigation from steps 1–2.
- Keep radio state, draft restoration, submission, Skip, and navigation in `StartupController`.
- Keep repository/API work out of the option-row widget.
- Reuse theme and core buttons where they reproduce the reference.

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
- Restore the selection from the shared draft.
- Implement `selectDiscoverySource(String id)`.
- Implement `backFromDiscovery()`, `completeStartup()`, and `skipStartup()`.
- Generate/reuse an idempotency key across retries.
- Expose saving/error state and prevent duplicate finalization.
- Clear the draft only after the defined terminal outcome.

## Navigation

| From | Action | To |
|---|---|---|
| Start Up 2 | Tap **Next** | Start Up 3 |
| Start Up 3 | Tap **Back** | Start Up 2 |
| Start Up 3 | Tap **Next**, save succeeds | Home |
| Start Up 3 | Tap **Skip**, completion recorded | Home |

## Testing and acceptance criteria

- The screen visually matches `Start Up 3.png`: shared top bar, exact heading, five full-width option rows, trailing radio circles, flexible whitespace, three teal progress dots, Back, and teal Next.
- Production subtitle uses grammatically correct **experience** copy.
- Telegram uses an appropriate Telegram icon rather than the reference's video-like mark.
- Options behave as one radio group and restore correctly after Back navigation.
- Other does not reveal an unrequested text input.
- Skills, interests, and discovery source are finalized from one consistent draft snapshot.
- Next and Skip are idempotent and never create duplicate submissions or routes.
- A save failure offers Retry and the approved non-blocking fallback.
- Successful completion clears the draft and replaces the route stack with Home.
- Widget/controller tests cover selection, switching choices, null source, Back, restore, Next success/error/retry, Skip, and duplicate-tap protection.
- No overflow occurs on small phones, tablets, landscape, localization, or increased text scale.

## Dependencies

- `00-foundation-prompt.md`
- `03-startup-1-prompt.md`
- `03-startup-2-prompt.md`
- `Prompt Frontend/api-intergration/integration-contract.md`
- `Prompt Backend/services/user-profile-service/SERVICE_PROMPT.md`

## Output

Deliver a polished, responsive Start Up step 3 screen that closely reproduces the supplied discovery-source survey, safely finalizes the shared three-step startup draft, treats referral data as optional, and navigates idempotently to Home.
