# Update Request: Startup Screen

## Overview

Update the existing Startup Screen while preserving the current architecture and navigation flow. Only implement the changes described below. Do not modify unrelated screens or features.

---

## 1. Add Content Transition Animation

### Requirements

- Add a smooth slide animation when navigating between Startup pages.
- The animation should work for both:
  - **Next**
  - **Back**
- Only the **content section** should animate.
- The following components must remain fixed:
  - AppBar
  - Bottom action buttons
- Do not animate the entire screen.
- The transition should be smooth and feel natural in both directions.

---

## 2. Standardize Startup Page Interaction

Currently, **startup-2** has the correct interaction behavior.

Update all other Startup pages so they follow the same interaction logic.

### Important

This update is **only about behavior**, **not** the UI design.

Do **not** copy the appearance of `startup-2`.

Each Startup page should keep its own:

- Layout
- Design
- Colors
- Icons
- Typography
- Shapes
- Spacing
- Overall visual style

Only make the interaction behave consistently across all Startup pages.

### Interaction Requirements

When a user taps or selects an option:

- The selected option should immediately update to its active state.
- The icon should change to its selected/active state.
- The text should change to its selected/active state.
- The border should change to its selected/active state.
- Previously selected options should return to their inactive state.
- The interaction should behave exactly like `startup-2`.

The visual styling of each page should remain unique. Only the selection behavior should be shared.

### Implementation Notes

- Reuse the existing interaction logic from `startup-2` where possible.
- Avoid duplicating code.
- Create reusable components if appropriate.
- Preserve the existing UI design of every Startup page.

---

## 3. Improve Dark & Light Mode Support

Update all Startup pages to fully support both Light Mode and Dark Mode.

### Requirements

- Icons should adapt correctly.
- Text colors should follow the current theme.
- Buttons should use the app's theme.
- Borders and backgrounds should adapt correctly.
- Avoid hardcoded colors whenever possible.
- Use the existing theme system throughout the Startup feature.

---

## 4. Update the AppBar

Replace the current AppBar title.

### Current

```
Vithey StartUp
```

### New

- Replace the text with the application logo.
- The logo should fit naturally within the AppBar.
- Maintain the logo's aspect ratio.
- Vertically center the logo.
- Do not make the logo appear too large or too small.

---

## Constraints

- Only modify the Startup feature.
- Do not change the Startup flow.
- Do not modify unrelated screens.
- Preserve the existing project architecture.
- Keep the implementation clean and reusable.
- Avoid introducing breaking changes.
- Follow the existing coding style and project conventions.

---

## Expected Result

- Smooth slide animation when navigating between Startup pages.
- Only the content area animates while the AppBar and bottom buttons remain fixed.
- All Startup pages have consistent interaction behavior.
- Each Startup page keeps its own unique UI design.
- Full support for both Light Mode and Dark Mode.
- The AppBar displays the application logo instead of the text "Vithey StartUp".
