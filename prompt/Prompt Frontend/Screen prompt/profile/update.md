# Profile About Screen - Edit Profile UI Update

> **Status: applied (v1 UI complete).**  
> Canonical spec: [`v1/07.profile_edit_info-v1.md`](v1/07.profile_edit_info-v1.md). Bottom-sheet Add / tap-to-edit behavior is implemented in the app.

## Objective

Update the **Edit Profile Info** screen based on the new UI design.

### Requirements

- Preserve all existing business logic.
- Update only the UI and interaction.
- Follow the provided UI design as closely as possible.
- Support both Light Mode and Dark Mode.

---

# Overall Interaction

Replace the current editing behavior with a new editing flow.

## Bottom Sheet Dialog

All **Edit** and **Add** actions should open a **Bottom Sheet Dialog**.

### Bottom Sheet Requirements

- Slide up from the bottom.
- Full width.
- Horizontal padding: **20px**.
- Margin: **0**.
- Height should automatically adjust to its content.
- Follow the application's design system.
- Support both Light Mode and Dark Mode.

---

# Section Header

Update every editable section header.

Current:

```text
Personal Detail                      Edit
```

New:

```text
Personal Detail                      Add
```

### Requirements

- Replace the **Edit** button with an **Add** button.
- The **Add** button is used only for creating a new item.
- Existing content should no longer be edited through the header button.

This applies to every editable section.

---

# Editable Sections

The following sections should support the new interaction:

- Skills
- Bio
- Personal Detail
- Work
- Education
- Links
- Contact Info

---

# Edit Interaction

Editing should happen by tapping the **content**, not the section header.

## Requirements

- Each content item is individually editable.
- Tapping one item should edit **only that item**.
- No other items or sections should enter edit mode.

### Example

Skills contains 10 items:

```text
Flutter
Dart
Java
Spring Boot
Docker
Git
Kubernetes
REST API
PostgreSQL
Firebase
```

If the user taps **Docker**, only the **Docker** item should open the Edit dialog.

The remaining skills stay unchanged.

This behavior applies to every editable section.

---

# Edit Dialog

When a content item is tapped:

- Open the Bottom Sheet dialog.
- Display only the selected item's information.
- Do not display information from other items.

Each section should have its own dialog content.

---

## Dialog Layout

Every Edit dialog should contain:

- Section Header
- Title input
- Content input(s)
- Save button
- Cancel button (if already implemented)

Use the existing design system.

---

# Section Fields

Each section displays different fields.

## Skills

Display:

- Skill Name
- Skill Percentage

---

## Bio

Display:

- Bio

---

## Personal Detail

Display:

- Location
- Gender
- Date of Birth

---

## Work

Display:

- Company / Workplace
- Position
- Description (if available)

---

## Education

Display:

- School / University
- Major
- Certificate
- Description (if available)

---

## Links

Display:

- Platform Name (e.g. Facebook)
- URL

---

## Contact Info

Display:

- Phone Number
- Email Address

---

# Add Button

The **Add** button in the section header should open the same Bottom Sheet UI.

## Behavior

The layout is identical to Edit.

Difference:

### Edit

- Existing values are pre-filled.
- Saving updates the selected item.

### Add

- Fields are empty.
- Saving creates a new item.
- Existing items remain unchanged.

---

# Behavior Summary

| Action               | Result                               |
| -------------------- | ------------------------------------ |
| Tap existing content | Edit only the selected item          |
| Tap Add button       | Create a new item                    |
| Edit one item        | Other items remain unchanged         |
| Open dialog          | Show only the selected item's fields |
| Save                 | Update or create only that item      |

---

# Design Requirements

- Match the provided UI as closely as possible.
- Improve spacing and typography.
- Use consistent section spacing.
- Follow the project's design system.
- Maintain responsive layouts.
- Support both Light Mode and Dark Mode.

---

# Implementation Notes

- Preserve all existing business logic.
- Do not modify unrelated sections.
- Reuse existing widgets whenever possible.
- Avoid duplicate implementations.
- Keep the code modular, reusable, and maintainable.
- Each section should manage its own add/edit state independently.
- Ensure only one Bottom Sheet dialog can be open at a time.
