# Startup Background Redesign

## Objective

Redesign the background for the startup screens to create a consistent and modern visual identity.

This update focuses **only on the background design**.

The business logic, navigation, and screen functionality must remain unchanged.

---

# Scope

Update the following screens:

- Language
- Onboarding
- Authentication
  - Sign In
  - Sign Up
  - Forgot Password
  - Reset Password
  - Verification
  - Other Auth-related screens

---

# Design Goal

All startup screens should share the same background design system.

The design consists of only two visual elements:

1. **Teal Background**
2. **White Sheet**

The White Sheet includes:

- White layer
- White 50% opacity layer

Treat both white layers as one single design element.

---

# Background Structure

Every startup screen should follow this hierarchy.

```text
┌──────────────────────────────────────────┐
│                                          │
│              TEAL BACKGROUND             │
│                                          │
│         App Logo / Decoration            │
│                                          │
│                                          │
│~~~~~~~~~~~~ Morphing White Sheet ~~~~~~~~│
│                                          │
│                                          │
│            Screen Content                │
│                                          │
│                                          │
└──────────────────────────────────────────┘
```

The teal background always fills the entire screen.

The White Sheet always rises from the bottom of the screen.

The White Sheet spans the full width of the screen.

There should be:

- No left margin
- No right margin
- No bottom margin

Only the top edge of the White Sheet changes shape.

---

# White Sheet Morphing

The White Sheet should morph based on the current screen.

Different screens have different:

- Content height
- Wave shape
- Curve angle
- Curve depth
- Sheet height

Although the shape changes, it should always feel like the same White Sheet evolving throughout the startup flow.

---

# Content Placement

The content belongs inside the White Sheet.

Depending on the current implementation, some content may need to be moved into the White Sheet.

Examples include:

- Titles
- Descriptions
- Form fields
- Buttons
- Language selector
- Onboarding information

Only move content when necessary to match the new background design.

Do not redesign or modify the content itself.

---

# What To Update

## Update

- Redesign the startup background.
- Introduce the new White Sheet design.
- Add the White 50% layer behind the White Sheet.
- Update the wave shape for each screen.
- Make the White Sheet morph naturally across different screens.
- Reposition content only if necessary so it sits inside the White Sheet.

---

## Do NOT Update

Do **not** change:

- Business logic
- Navigation
- Screen flow
- Authentication logic
- Form validation
- Controllers
- Services
- Models
- Existing functionality
- Content
- Text
- Icons
- Buttons
- User interactions

The only exception is moving existing content into the White Sheet if required by the new layout.

---

# Design Requirements

- Teal always fills the entire screen.
- White Sheet always comes from the bottom.
- White Sheet always spans the full width.
- White Sheet has no side or bottom margins.
- White Sheet contains the page content.
- White and White 50% behave as one design element.
- Each screen has a unique wave shape.
- The startup flow should feel like one continuous design system.
- Support both Light Mode and Dark Mode.

---

# Implementation Notes

- Preserve all existing business logic.
- Update only the UI background and layout.
- Reuse existing widgets whenever possible.
- Avoid duplicate implementations.
- Keep the code clean and maintainable.
- If the current content placement conflicts with the new background, move the existing content into the White Sheet without changing its functionality or behavior.

```

```
