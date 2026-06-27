# 10 - Finance Screen Prompt

Build the **Finance** module for Vithey App.

## Goal
Show university payment history, status badges, and deadline alerts — **verified AUB students only**.

## Depends On
- `11-student-verification-prompt.md` (gate logic)

## Reuse From Core
- `AppAppBar`
- `StatusBadge`
- `SectionHeader`
- `ShimmerListTile`
- `EmptyStateWidget`
- `CustomButton`
- `date_formatter.dart` (currency + dates)

## Module Files
```text
lib/modules/finance/
  finance_screen.dart
  finance_controller.dart
  finance_binding.dart
  widgets/
    payment_history_card.dart
    payment_status_badge.dart   # Thin wrapper over StatusBadge if needed
    payment_alert_card.dart
    verification_gate.dart    # Shown if not verified → CTA to verification

lib/data/models/payment_model.dart
lib/data/repositories/finance_repository.dart
```

## Screen Spec
| Item | Detail |
|------|--------|
| Access | Verified AUB students only |
| UI | Payment cards, history list, alert box |
| Status | Paid, unpaid, pending, overdue |
| Alerts | Notify before deadline |
| API | `GET /fees`, `GET /payments` |

## Controller Logic
- Check `user.isStudentVerified` from profile/auth state
- If not verified: show `verification_gate` widget with button → Student Verification
- If verified: `fetchPayments()`, `fetchAlerts()`
- Sort by due date; highlight overdue in red via `StatusBadge`

## UI Requirements
- Top **alert card** for upcoming deadlines (within 7 days)
- List of `payment_history_card` items
- Each card: fee name, amount (KHR formatted), due date, `payment_status_badge`
- Pull-to-refresh
- Shimmer while loading

## Widget Rules
- `payment_status_badge` should use core `StatusBadge` — map enum to colors
- `verification_gate` composes `EmptyStateWidget` + `CustomButton`

## Route Registration
Add `Routes.FINANCE`

## Output
Finance screen with verification gate and payment list UI.
