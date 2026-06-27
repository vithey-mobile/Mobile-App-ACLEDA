# 17 - Applicant CV Preview Screen Prompt

Build the **Applicant CV Preview** module for Vithey App.

## Goal
Allow job posters to view CV files submitted by applicants for their job posts.

## Depends On
- `07-apply-cv-prompt.md`, `09-profile-prompt.md`

## Reuse From Core
- `AppAppBar`
- `UserAvatar`
- `CustomButton`
- `LoadingWidget`
- `EmptyStateWidget`
- `StatusBadge` (application status: pending, reviewed, accepted, rejected)

## Module Files
```text
lib/modules/applicant_cv_preview/
  applicant_cv_preview_screen.dart
  applicant_cv_preview_controller.dart
  applicant_cv_preview_binding.dart
  widgets/
    applicant_cv_card.dart      # Applicant name, date, status, preview btn
    applicant_cv_viewer.dart    # Full CV preview (reuse cv_preview_view pattern)

lib/data/repositories/job_application_repository.dart
```

## Screen Spec
| Item | Detail |
|------|--------|
| Open from | Profile (job poster) or job post management |
| Main UI | List of applicants + CV preview |
| API | `GET /job-applications?job_post_id=`, download CV file |
| Actions | View CV, optional accept/reject status update |

## Controller Logic
- `jobPostId` from arguments
- `fetchApplicants()` — list applications with user info
- `previewCv(applicationId)` — load file → navigate or bottom sheet with `applicant_cv_viewer`
- `updateStatus(id, status)` optional

## UI Requirements
- List of `applicant_cv_card` items
- Each card: `UserAvatar`, applicant name, applied date, status badge, **View CV** button
- Tap View → full screen viewer (reuse logic from `preview_cv` module)
- Empty state if no applicants yet

## Widget Reuse
- Extract shared PDF viewer from `preview_cv/widgets/cv_preview_view.dart` to `lib/core/widgets/cv_document_viewer.dart` if not already done — both Preview CV and Applicant CV must use the same viewer

## Route Registration
Add `Routes.APPLICANT_CV_PREVIEW`

## Output
Applicant list and CV viewer for job posters.
