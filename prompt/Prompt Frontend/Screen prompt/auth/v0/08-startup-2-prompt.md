# 03F - Start Up 2 / Interests Selection Prompt

Build **Start Up 2**, the second post-registration profile-setup screen for the Vithey App in Flutter, matching the supplied reference image while correcting clearly accidental content issues for production.

## Visual reference

- Reference image: `Prompt Frontend/screen image/Start Up 2.png`
- Reference canvas: approximately `302 × 656 px` (portrait mobile)
- Treat the image as the source of truth for layout, spacing, card proportions, two-column composition, and navigation hierarchy.
- Recreate the page responsively; do not hard-code the entire screen to the reference dimensions.

## Quick info

| Field | Value |
|---|---|
| Screen ID | `03F` / Start Up step 2 of 3 |
| Suggested route | `Routes.STARTUP_INTERESTS` |
| Previous route | `Routes.STARTUP_SKILLS` |
| Next route | `Routes.STARTUP_3` |
| Flutter module | `lib/modules/startup/` |
| Backend service | `user-profile-service` or recommendation/preferences service once documented |
| Auth required | Yes |
| Primary feature | Select feed-personalization interests |

## Goal

Allow a newly authenticated user to choose topics they care about so Vithey can personalize their feed and recommendations. Preserve the selections from Start Up 1 while allowing Back, Next, and Skip across the shared three-step setup flow.

## Screen composition

Build the screen from top to bottom in this order:

1. **System status-bar area**
   - Use a white or very light background with dark system status-bar icons.
   - Respect `SafeArea`; never draw fake time, signal, Wi-Fi, or battery indicators.

2. **Top navigation bar**
   - White background with a subtle bottom divider.
   - Left-aligned bold title: **Vithey StartUp**.
   - Right-aligned teal text action: **Skip**.
   - Keep both vertically centered with approximately `16 px` horizontal padding.
   - Do not add a leading arrow; the shared Back action remains in the bottom navigation.

3. **Question heading**
   - Left-aligned text: **What are you interested in?**
   - Bold dark charcoal, approximately `17–18 px`.
   - Use approximately `16 px` side padding.

4. **Supporting text**
   - Production copy: **Choose your favorite topics to personalize your feed.**
   - Use small muted-gray text, approximately `11 px` in the reference.
   - The reference reads “Choose your favorate topics to your personalize your feed.” Treat those spelling/grammar errors as mockup mistakes; do not reproduce them in production.

5. **Interest selection grid**
   - Display cards in two equal-width columns.
   - Use approximately `15–16 px` horizontal page padding, `14–16 px` column spacing, and `12 px` row spacing at the reference size.
   - Each card is approximately `127 × 68 px` in the reference, with a very light gray fill, thin cool-gray border, and `6–8 px` corner radius.
   - Card contents align toward the upper-left rather than being centered.
   - Show a small category icon above or slightly separated from the label.
   - Use dark-gray icons and medium-weight dark text.
   - Allow two-line labels such as **Career Opportunities** and **Digital and Technology**.

6. **Flexible spacing**
   - Preserve the breathing room between the final grid row and bottom controls.
   - Use flexible layout constraints rather than a hard-coded empty block.

7. **Bottom step navigation**
   - Place controls above the device bottom safe area.
   - Left: text button **Back**.
   - Center: three small progress dots; dot 2 is active teal, dot 1 is completed teal, and dot 3 is inactive light gray. If the visual system does not distinguish completed from active, both first and second dots may be teal as shown.
   - Right: teal pill button **Next** with white text.
   - Preserve a minimum `44 px` logical tap target even though the visible Next pill is more compact.

## Reference category fixtures

The image shows these ten tiles in row order:

| Row | Left | Right |
|---|---|---|
| 1 | `Academic News` | `Campus Events` |
| 2 | `Student Life` | `Workshops` |
| 3 | `Career Opportunities` | `Digital and Technology` |
| 4 | `Sports` | `Arts and Cultures` |
| 5 | `Sports` | `Interested` |

The first eight labels establish the intended category style. The final row contains likely mockup placeholders: **Sports** is duplicated, and **Interested** with an Apple-like icon is not a meaningful topic category. Keep those values only in screenshot fixtures if exact visual comparison requires them. Before production, replace the final two entries with approved, unique categories and appropriate licensed icons. Do not ship duplicate IDs, an Apple trademark used as a generic category icon, or an ambiguous `Interested` category.

Use stable category IDs independent of display labels. A production catalog might begin with:

| ID | Display label | Icon direction |
|---|---|---|
| `academic_news` | Academic News | graduation cap |
| `campus_events` | Campus Events | calendar/event |
| `student_life` | Student Life | people/community |
| `workshops` | Workshops | folder/tools |
| `career_opportunities` | Career Opportunities | briefcase |
| `digital_technology` | Digital and Technology | laptop/device |
| `sports` | Sports | ball/sports |
| `arts_culture` | Arts and Cultures | globe/arts/culture |

Keep the catalog configurable so approved categories can replace the two unresolved fixture tiles without rewriting the screen.

## Selection states

The reference shows the default/unselected card state. Add complete interaction states:

- Unselected: near-white/light-gray fill, thin gray border, dark-gray icon and label.
- Selected: pale teal or teal fill, teal border, accessible text/icon contrast, and a check indicator or equivalent non-color cue.
- Pressed, focused, disabled, and loading states must be distinguishable.
- Tapping anywhere within a card toggles its category.
- Selection must not resize the card or cause grid movement.
- Announce selected/unselected state to assistive technology.

## Selection rules

- Store selected category IDs in a `Set<String>` to prevent duplicates.
- The exact minimum/maximum is not defined by the current product/backend prompts. Use configurable constants such as `minSelectedInterests` and `maxSelectedInterests`.
- If no product rule exists, use a temporary default of at least `1` and at most `5`, clearly isolated in configuration.
- Keep selected cards removable after the maximum is reached and show a concise limit message when another card cannot be added.
- Use **Skip** as the explicit way to continue without interest selections.
- Do not silently auto-select categories based on the user's skills.

## Visual style

| Token | Direction |
|---|---|
| Page/top bar | White / very light cool gray |
| Main text | Dark charcoal, approximately `#303236` |
| Supporting text | Muted gray |
| Accent/progress/Next | Vithey teal, approximately `#08B9B3` |
| Inactive dot | Light cool gray |
| Card background | Very light gray, approximately `#F7F8F8` |
| Card border | Light cool gray |
| Selected card | Teal or pale teal with accessible contrast |
| Divider | Very light neutral gray |
| Font | App theme font with a clean sans-serif appearance |

Do not add a logo, wave header, search field, free-text interest input, images, descriptions inside cards, bottom app-navigation bar, or extra actions not visible in the reference.

## Responsive behavior

- Use `SafeArea`, `LayoutBuilder`, and flexible constraints instead of fixed screen coordinates.
- Keep two columns on ordinary phone widths when labels remain readable.
- On very narrow widths or large text scales, allow a one-column layout rather than clipping content.
- On tablets, constrain the content to a sensible maximum width; do not stretch cards across the full display.
- Make the main content scrollable if the grid and navigation cannot fit vertically.
- Keep bottom controls reachable above system insets and avoid overlap with the final row.
- Ensure long/localized category labels wrap within their cards without overflow.

## Interaction and navigation

- **Select interest:** toggle the canonical category ID in the shared startup draft.
- **Back:** save the current draft in memory/local recovery storage and navigate to `Routes.STARTUP_SKILLS` with step-1 selections intact.
- **Next:** validate the selection, preserve both skills and interests, and navigate once to `Routes.STARTUP_3`.
- **Skip:** if the user has made selections that would be discarded, confirm before clearing them. Then follow the startup coordinator's defined skip behavior.
- Returning from step 3 must restore the selected interest cards.
- Prevent rapid Back/Next/Skip taps from creating duplicate routes or save requests.

Do not mark the full startup flow complete on Next from step 2. The last step or flow coordinator owns final submission and Home navigation. If Skip means skip all remaining steps, persist that completion decision once and use `Get.offAllNamed(Routes.HOME)`.

## Persistence and backend contract note

The current backend prompts do not define an interests/topics field or recommendation-preferences endpoint. Do not invent a production URL or hide these values in an unrelated settings property.

Extend the shared draft from Start Up 1:

```dart
class StartupProfileDraft {
  final Set<String> skillIds;
  final Set<String> interestIds;
  // Step 3 fields are added by the next screen.
}
```

Define a typed repository boundary, for example:

```dart
Future<void> saveInterests(Set<String> interestIds);
```

Wire it only when the owning backend service, canonical category catalog, endpoint, request envelope, and recommendation behavior are documented. Store canonical IDs rather than display strings. Local draft persistence is for route/crash recovery and must be cleared after successful final submission or confirmed Skip.

## Accessibility

- Add semantic labels for the page title, Skip, every interest card, Back, progress indicator, and Next.
- Announce **Step 2 of 3** and each card's selected/unselected state.
- Announce current selection count and maximum where configured.
- Ensure every card and action has at least a `44 × 44 logical-pixel` interactive target.
- Do not rely only on teal color to indicate selection; include a check or clear semantic state.
- Maintain sufficient contrast for card outlines, icons, labels, and progress dots.
- Support logical keyboard/focus order from header through the row-major grid to bottom navigation.

## Architecture

Use the shared startup module established by Start Up 1:

```text
lib/modules/startup/
  startup_binding.dart
  startup_controller.dart
  startup_skills_screen.dart
  startup_interests_screen.dart
  startup_step_3_screen.dart
  widgets/
    startup_header.dart
    startup_step_indicator.dart
    startup_bottom_navigation.dart
    selectable_interest_card.dart

lib/data/models/
  interest_option.dart
  startup_profile_draft.dart

lib/data/repositories/
  profile_repository.dart
```

- Keep the interest catalog as ordered typed data, not duplicated widget literals.
- Share header, step indicator, and bottom navigation with steps 1 and 3.
- Keep selection, draft restoration, validation, and navigation in `StartupController`.
- Keep API/local persistence out of the card widget.
- Reuse app theme and core interaction components where they can reproduce the reference.

Suggested model:

```dart
class InterestOption {
  final String id;
  final String label;
  final IconData icon;
}
```

Controller responsibilities:

- Expose the ordered, unique interest catalog.
- Maintain observable `Set<String> selectedInterestIds`.
- Implement `toggleInterest(String id)` with minimum/maximum safeguards.
- Restore both skill and interest selections from the shared draft.
- Implement `backFromInterests()`, `nextFromInterests()`, and shared `skipStartup()`.
- Prevent duplicate navigation and surface validation/recovery errors.

## Testing and acceptance criteria

- The screen visually matches `Start Up 2.png`: shared top bar, heading/copy hierarchy, two-column card grid, flexible spacing, Back, two teal progress dots, one inactive dot, and teal Next button.
- Production copy uses **favorite** and removes the duplicated “to your” grammar error.
- Production category IDs are unique; duplicate Sports and ambiguous Interested remain fixture-only until replaced by approved categories.
- Interest cards toggle visually and semantically without layout shifts.
- Configured minimum/maximum selection behavior works.
- Back preserves step-1 and step-2 draft values.
- Next validates, preserves the draft, and opens step 3 exactly once.
- Returning from step 3 restores selections.
- Skip follows the startup coordinator's confirmed behavior.
- Widget/controller tests cover catalog rendering, selection, limit, validation, restoration, Back, Next, and Skip.
- No overflow occurs on small screens, tablets, localization, or increased text scale.

## Dependencies

- `00-foundation-prompt.md`
- `03-startup-1-prompt.md`
- `Prompt Frontend/api-intergration/integration-contract.md`
- `Prompt Backend/services/user-profile-service/SERVICE_PROMPT.md`

## Output

Deliver a polished, responsive Start Up step 2 screen that closely reproduces the supplied interest-selection layout, corrects obvious fixture-content errors for production, preserves the shared startup draft, and is ready for a documented feed-preferences backend contract.
