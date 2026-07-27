# Confirm Dialog — Global Widget Prompt

Build the reusable **Confirm Dialog** for Vithey App in Flutter, matching:

- `Prompt Frontend/screen image/global_widget/confirm_dialog.png`

## Quick info

| Field | Value |
|---|---|
| Flutter module | `lib/core/widgets/confirm_dialog.dart` |
| Type | Global reusable widget (not a route) |
| Auth required | No |
| Used by | Settings logout, search clear recents, security sign-out, delete flows |

## Goal

Provide a single, theme-aware confirmation modal that callers can open from any screen to ask the user to confirm or cancel a destructive or important action.

## Visual requirements

Match `confirm_dialog.png`:

### Container

- Centered modal over a dimmed scrim (`barrierColor` ~ black at 40–50% opacity).
- White/light surface card with **large rounded corners** (~24px radius).
- Soft drop shadow so the dialog feels elevated above the page.
- Generous internal padding (~24px horizontal, ~24px top, ~20px bottom).
- Max width ~420px on tablets/large screens; full width minus horizontal margin on phones.

### Typography

- **Title**
  - Center-aligned.
  - Bold sans-serif.
  - Dark heading color (`context.appColors.heading`).
  - Single line when possible; wrap gracefully when longer.
- **Description**
  - Center-aligned, directly below title (~8–12px gap).
  - Regular weight, smaller than title (~14–15px).
  - Muted gray (`context.appColors.muted`).
  - Supports multi-line body copy.

### Buttons (side by side)

Two equal-width pill buttons in a horizontal row at the bottom (~16px below description):

| Button | Style | Default colors |
|---|---|---|
| **Cancel** | Outlined | Transparent/white fill, light gray border (`context.appColors.border`), dark text |
| **Confirm / Action** | Filled | Background and text colors are **dynamic** (see below) |

Shared button rules:

- Height ~44–48px.
- Corner radius ~16px (pill-like).
- Equal width with a small gap (~12px) between buttons.
- Label text centered inside each button.

### Dynamic button colors

Do **not** hard-code the confirm button to red. Colors must be configurable per call site while keeping sensible defaults:

| Parameter | Purpose | Default |
|---|---|---|
| `confirmColor` | Confirm button background | `Theme.of(context).colorScheme.primary` |
| `confirmForegroundColor` | Confirm button text/icon | `Theme.of(context).colorScheme.onPrimary` |
| `cancelColor` | Cancel button border (optional) | `context.appColors.border` |
| `cancelForegroundColor` | Cancel button text | `context.appColors.heading` |

Recommended presets (helper enum or factory, optional):

| Variant | `confirmColor` | Use case |
|---|---|---|
| `neutral` | `AppColors.primary` | Generic confirmations (save, continue, clear) |
| `destructive` | `AppColors.error` | Logout, delete, sign out everywhere, irreversible actions |

Callers choose the variant or pass explicit colors. Example:

```dart
await showConfirmDialog(
  context: context,
  title: 'Log out',
  message: 'Are you sure you want to log out of Vithey?',
  confirmLabel: 'Log out',
  variant: ConfirmDialogVariant.destructive,
);
```

## Public API

Expose a helper function (no route registration):

```dart
Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = AppStrings.confirm,
  String cancelLabel = AppStrings.cancel,
  ConfirmDialogVariant variant = ConfirmDialogVariant.neutral,
  Color? confirmColor,
  Color? confirmForegroundColor,
  Color? cancelColor,
  Color? cancelForegroundColor,
  bool barrierDismissible = true,
});
```

Return values:

- `true` — user tapped confirm/action.
- `false` — user tapped cancel.
- `null` — dismissed via scrim/back (when `barrierDismissible` is true).

## Architecture

```text
lib/core/widgets/
  confirm_dialog.dart   # showConfirmDialog + ConfirmDialog widget
```

Optional (only if needed for clarity):

```text
lib/core/widgets/
  confirm_dialog_variant.dart
```

## Behavior

- Use Flutter `showDialog` (or existing app dialog wrapper if present).
- Tapping **Cancel** pops with `false`.
- Tapping **Confirm** pops with `true`.
- Respect light/dark theme via semantic colors and `ColorScheme`.
- Do not use screen-specific copy inside the widget — all strings come from parameters.
- Keep the widget stateless; no GetX controller required.

## Current usages to preserve

| Screen / flow | Title example | Suggested variant |
|---|---|---|
| Settings logout | Log out | `destructive` |
| Search clear recents | Clear recent searches? | `neutral` |
| Security sign out everywhere | Sign Out Everywhere | `destructive` |

## Testing

- Dialog matches reference layout: centered title/description, two pill buttons.
- Cancel returns `false`; confirm returns `true`.
- `variant: destructive` renders red confirm button; `neutral` renders primary teal.
- Explicit `confirmColor` overrides variant default.
- Readable in light and dark mode.
- Long title/message wrap without overflow.

## Output

Complete `confirm_dialog.dart` matching `confirm_dialog.png` with dynamic confirm/cancel button colors and a simple `showConfirmDialog` API used across the app.
