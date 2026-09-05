# 03E - Start Up 1 / Skills Selection Prompt

Build **Start Up 1**, the first post-registration profile-setup screen for the Vithey App in Flutter, matching the supplied reference image as closely as possible.

## Visual reference

- Reference image: `Prompt Frontend/screen image/Start Up 1.png`
- Reference canvas: approximately `302 × 656 px` (portrait mobile)
- Treat the image as the source of truth for visible content, spacing, chip wrapping, navigation, and hierarchy.
- Recreate the layout responsively; do not hard-code the entire page to the reference dimensions.

## Quick info

| Field | Value |
|---|---|
| Screen ID | `03E` / Start Up step 1 of 3 |
| Suggested route | `Routes.STARTUP_SKILLS` |
| Previous flow | Successful registration or first social sign-in |
| Next route | `Routes.STARTUP_2` |
| Flutter module | `lib/modules/startup/` |
| Backend service | `user-profile-service` once the skills contract exists |
| Auth required | Yes |
| Primary feature | Select top professional skills |

## Goal

Let a newly authenticated user select the professional skills that best represent them so Vithey can personalize their profile, career content, and employer-facing information. The user may continue, go back, or skip profile setup.

This is distinct from the pre-auth marketing onboarding flow in `02-onboarding-prompt.md`; it is an authenticated profile-personalization flow shown after account creation or first social login.

## Screen composition

Build the screen from top to bottom in this order:

1. **System status-bar area**
   - White or very light background with dark system status-bar icons.
   - Respect `SafeArea`.
   - Do not manually draw the time, signal, Wi-Fi, or battery icons.

2. **Top navigation bar**
   - White background with a subtle bottom divider.
   - Left-aligned title: **Vithey StartUp**.
   - Use bold dark-charcoal text, approximately `14–15 px` in the reference.
   - Right-aligned teal text action: **Skip**.
   - Keep both items vertically centered and provide at least `16 px` horizontal padding.
   - Do not add a leading back arrow; Back is located in the bottom navigation.

3. **Question heading**
   - Left-aligned text: **What are your skills?**
   - Bold dark charcoal, approximately `17–18 px`.
   - Start approximately `16 px` from the left edge and leave comfortable space below the top bar.

4. **Supporting text**
   - Left-aligned text: **Select your top skills to stand out to employers.**
   - Small muted-gray text, approximately `11 px` in the reference.
   - Keep it close to the heading while maintaining readable line spacing.

5. **Skills chip group**
   - Render rounded outlined selection chips in a responsive `Wrap`.
   - Align the chip group to the left with consistent horizontal and vertical gaps.
   - Each chip contains a small muted-gray category icon followed by its label.
   - Use a white/near-white default fill, thin cool-gray border, pill-shaped radius, and medium dark-gray text.
   - Match the visual density and wrapping shown in the reference rather than stretching chips to equal widths.

   Include these skills in this display order:

   | Order | Label | Icon direction |
   |---|---|---|
   | 1 | `Graphic Design` | design/tools icon |
   | 2 | `Management` | organization/hierarchy icon |
   | 3 | `Coding` | code/window icon |
   | 4 | `Social Media Influence` | social/analytics icon |
   | 5 | `Sale` | person/commerce icon; keep the singular reference label |
   | 6 | `Content Video` | video/play icon; keep the reference word order |
   | 7 | `AI` | globe/technology icon |
   | 8 | `Marketing` | campaign/product icon |
   | 9 | `Data Analysis` | report/data icon |

   On the reference width, the chips approximately wrap as:

   - `Graphic Design` + `Management`
   - `Coding` + `Social Media Influence`
   - `Sale` + `Content Video` + `AI`
   - `Marketing` + `Data Analysis`

   Allow natural reflow on other screen widths and text scales.

6. **Flexible empty space**
   - Preserve the large clean area between the skill choices and bottom controls.
   - Use `Spacer`/flexible constraints rather than a hard-coded vertical gap.

7. **Bottom step navigation**
   - Anchor controls above the device safe area without overlaying content.
   - Left: compact text button **Back** in dark gray.
   - Center: three small circular progress dots; dot 1 is active in teal and dots 2–3 are inactive light gray.
   - Right: teal pill button **Next** with white text.
   - The visible Next button is approximately `55 × 28 px` in the reference, but its semantic/tap target must be at least `44 px` high.
   - Maintain balanced alignment between Back, dots, and Next.

## Skill selection states

The reference shows the unselected state. Add a clear selected state consistent with the Vithey palette:

- Selected chip: pale teal fill or teal fill, teal border, and sufficiently contrasting icon/text.
- Unselected chip: near-white fill, cool-gray border, muted icon, dark-gray label.
- Pressed/focused/disabled states must be visually distinct and accessible.
- Tapping a chip toggles it without changing the chip's size enough to cause distracting reflow.
- Expose selection through `FilterChip`, `ChoiceChip` with multi-select logic, or an accessible custom reusable chip.

## Selection rules

- Use stable skill IDs separate from display labels.
- Do not infer selections merely from icon or chip position.
- The exact product maximum is not defined in the current contract. Implement a configurable constant such as `maxSelectedSkills`; use `5` as a temporary product default only if no existing rule is found.
- Require at least one selected skill before **Next**, unless product requirements explicitly allow an empty step.
- If the user reaches the maximum, keep selected chips removable and explain the limit accessibly rather than silently ignoring taps.
- **Skip** is the explicit path for continuing without selecting skills.

## Visual style

| Token | Direction |
|---|---|
| Page/top bar | White / very light cool gray |
| Main text | Dark charcoal, approximately `#303236` |
| Supporting text | Muted gray |
| Accent/active dot/Next | Vithey teal, approximately `#08B9B3` |
| Inactive dots | Light cool gray |
| Chip background | White / near-white |
| Chip outline | Light cool gray |
| Selected chip | Teal or pale teal with accessible contrast |
| Divider | Very light neutral gray |
| Font | App theme font with a clean sans-serif appearance |

Do not add a logo, wave header, illustration, search field, free-text custom skill field, app-bottom navigation bar, or extra categories not shown in the reference.

## Responsive behavior

- Use `SafeArea`, `LayoutBuilder`, and flexible constraints rather than absolute coordinates.
- Use `Wrap` for skills so chip rows adapt to device width, localization, and text scaling.
- Keep at least `16 px` side padding on narrow screens.
- If content grows beyond the viewport, make the main content scrollable while keeping the bottom navigation reachable.
- Prevent bottom controls from colliding with the system gesture/navigation area.
- Support `320 px` width, large phones, tablets with a sensible max content width, landscape, and increased text scale without overflow.
- Preserve logical reading order even when chips reflow.

## Interaction and navigation

- **Select a skill:** toggle the skill ID in the startup draft state.
- **Next:** validate selection, persist the draft, and navigate to `Routes.STARTUP_2` without discarding the current choices.
- **Back:** return to the previous startup/auth-success destination according to the navigation stack. If this is the first non-dismissible post-auth step, confirm the intended route instead of logging the user out.
- **Skip:** ask for confirmation only if the user has made selections that would be discarded; otherwise mark or record this step as skipped and route according to the startup-flow coordinator.
- Returning from step 2 must restore the selected skills.
- Rapid taps must not create duplicate routes or duplicate save requests.

Do not mark the entire three-step startup flow complete on **Next** from step 1. Final completion and the definitive Home navigation belong to the last step or the flow coordinator. If Skip is intended to skip all remaining steps, record completion once and route with `Get.offAllNamed(Routes.HOME)`.

## Persistence and backend contract note

The current `user-profile-service` prompt defines profile fields such as name, bio, avatar, university, major, and graduation year, but it does not define a `skills` field or skills endpoint. Do not silently store skills in an unrelated settings field or invent a production API URL.

Use a typed local draft during the multi-step flow, for example:

```dart
class StartupProfileDraft {
  final Set<String> skillIds;
  // Fields from steps 2 and 3 are added by those screens.
}
```

Define a repository boundary such as:

```dart
Future<void> saveSkills(Set<String> skillIds);
```

Wire it only after the backend schema and endpoint are agreed. The backend should store canonical skill IDs, validate allowed values, and return the normalized selection. Use local persistence only for crash/route recovery and clear the draft after successful final submission or explicit Skip.

## Accessibility

- Add semantic labels for the page title, Skip, each skill chip, Back, progress indicator, and Next.
- Announce each chip's selected/unselected state and the current selection count.
- Announce **Step 1 of 3** through the progress indicator semantics.
- Ensure all actions and chips have at least `44 × 44 logical-pixel` tap targets, even where their visible shape is more compact.
- Maintain sufficient contrast for chip borders, labels, selected states, and progress dots.
- Support keyboard/focus navigation in visual reading order.
- Do not rely on color alone to communicate selection; expose a check indicator or semantic state.

## Architecture

Suggested structure:

```text
lib/modules/startup/
  startup_binding.dart
  startup_controller.dart
  startup_skills_screen.dart
  startup_step_2_screen.dart
  startup_step_3_screen.dart
  widgets/
    startup_header.dart
    startup_step_indicator.dart
    startup_bottom_navigation.dart
    selectable_skill_chip.dart

lib/data/models/
  skill_option.dart
  startup_profile_draft.dart

lib/data/repositories/
  profile_repository.dart
```

- Keep the skills catalog as typed data, not repeated widget literals.
- Keep selection and navigation state in `StartupController`.
- Share the header, three-dot indicator, and bottom navigation across all startup steps.
- Parameterize current step, Back/Next behavior, and Next enabled/loading state.
- Keep API and local-draft persistence out of presentational widgets.
- Reuse app theme tokens and core buttons where they can match the reference.

## Suggested models and controller behavior

```dart
class SkillOption {
  final String id;
  final String label;
  final IconData icon;
}
```

Controller responsibilities:

- Expose the ordered skills catalog.
- Maintain an observable `Set<String> selectedSkillIds`.
- Implement `toggleSkill(String id)` with duplicate and maximum protection.
- Restore selections from the startup draft.
- Implement `nextFromSkills()`, `backFromSkills()`, and `skipStartup()`.
- Expose validation, saving, and navigation states.
- Prevent duplicate navigation and dispose owned resources correctly.

## Testing and acceptance criteria

- The implementation visually matches `Start Up 1.png`: top bar, exact question/copy, nine skills in the correct order, large flexible whitespace, Back action, first active progress dot, and teal Next button.
- Chips wrap naturally and approximately match the reference grouping at the reference width.
- Every skill can be selected and deselected; selection is visually and semantically clear.
- The configurable selection limit and minimum-selection rule behave correctly.
- Next preserves the draft and opens step 2 once.
- Returning to step 1 restores the previous choices.
- Skip follows the confirmed flow semantics and does not accidentally create an incomplete profile submission.
- Back, Skip, and Next remain usable with small screens and increased text scale.
- Widget/controller tests cover initial state, toggle, limit, validation, restore, Skip, Back, and Next.
- The screen has no horizontal or vertical overflow on common device sizes.

## Dependencies

- `00-foundation-prompt.md`
- `03-register-prompt.md`
- `03-auth-google-2-prompt.md`
- `Prompt Frontend/api-intergration/integration-contract.md`
- `Prompt Backend/services/user-profile-service/SERVICE_PROMPT.md`

## Output

Deliver a polished, responsive Start Up step 1 screen that closely reproduces the supplied skills-selection design, maintains a reusable three-step startup flow, preserves user choices, and is ready to connect to a documented profile-skills backend contract.
