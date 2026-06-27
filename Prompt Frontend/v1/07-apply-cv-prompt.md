# 07 - Apply CV Screen Prompt

Build the **Apply CV** module for Vithey App.

## Goal
Let users upload a CV file (PDF, DOC, DOCX) and submit a job application.

## Depends On
- `06-post-detail-prompt.md`

## Reuse From Core
- `CustomButton`
- `AppAppBar`
- `LoadingWidget`
- `EmptyStateWidget`
- `file_picker_helper.dart`

## Module Files
```text
lib/modules/apply_cv/
  apply_cv_screen.dart
  apply_cv_controller.dart
  apply_cv_binding.dart
  widgets/
    big_upload_icon.dart
    cv_file_preview.dart      # Shows file name, size, type icon
    submit_cv_button.dart     # Wraps CustomButton with validation state

lib/data/models/cv_model.dart
lib/data/repositories/cv_repository.dart
```

## Screen Spec
| Item | Detail |
|------|--------|
| Open from | Job post (Home or Post Detail) |
| File types | PDF, DOC, DOCX |
| API | `POST /files/upload` + `POST /job-applications` |
| Success | Confirmation + back to post |

## Controller Logic
- Receive `jobPostId` from route arguments
- `pickCv()` — file_picker with allowed extensions
- `submitApplication()` — upload → apply
- Validate file size (e.g. max 10MB)
- States: no file, file selected, uploading, success, error

## UI Requirements
- Large dashed upload area with `big_upload_icon`
- After pick: `cv_file_preview` with remove option
- Job title summary at top (from arguments)
- `submit_cv_button` disabled until file selected
- Success dialog then `Get.back`

## Widget Rules
- `submit_cv_button` must delegate to `CustomButton` — no duplicate button styling
- `cv_file_preview` may be reused later in Profile CV tab — if so, move to `core/widgets/cv_file_preview.dart`

## Route Registration
Add `Routes.APPLY_CV`

## Output
Complete CV upload and job application submission UI.
