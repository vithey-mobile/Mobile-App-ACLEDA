# Application Feedback — Success Screen

Build the confirmation screen from `Feed back submitted.png`.

## Route

| Field | Value |
|-------|-------|
| Presentation | Full-screen or dialog after Accept/Reject + optional feedback |
| Entry | Applicant detail or Application list after decision submitted |

## Layout

```
┌─────────────────────────────────────┐
│                                     │
│         [document + ✓ icon]         │  Centered illustration
│                                     │
│      Feedback Submitted!            │  Bold headline
│                                     │
│  Your feedback already submitted    │  Muted body
│  successfully to the candidate.     │
│                                     │
│         [ Done ]                    │  Optional primary button
└─────────────────────────────────────┘
```

## Copy (reference)

- Title: **Feedback Submitted!**
- Body: **Your feedback already submitted successfully to the candidate.**

Adjust copy for Accept-only flow without feedback form if feedback is optional.

## Behavior

| Action | Result |
|--------|--------|
| Auto | Show 2s then pop to Application list with updated status |
| Done button | `Get.back()` to list — list reflects new status |
| System back | Same as Done |

## Illustration

- Blue document stack + green checkmark badge
- Use Lottie or static asset `assets/images/illustrations/feedback_submitted.png`
- Fallback: `Icons.task_alt` large teal icon

## Widget

```text
lib/modules/profile/widgets/application_feedback_success.dart
```

Or dedicated route `AppRoutes.applicationFeedbackSuccess` if preferred.

## Acceptance criteria

- [ ] Matches `Feed back submitted.png` centered layout
- [ ] Shown after successful Accept/Reject API call
- [ ] Returns to applicant list with reconciled status
- [ ] Does not block on missing illustration asset

## Dependencies

- `list_cv_apply_job.md`
- `applicant_detail.md`
