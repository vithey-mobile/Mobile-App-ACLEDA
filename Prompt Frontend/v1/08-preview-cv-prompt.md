# 08 - Preview CV Screen Prompt

Build the **Preview CV** module for Vithey App.

## Goal
Allow users to preview and download their CV document (PDF, DOC, DOCX).

## Depends On
- `09-profile-prompt.md` (can be built in parallel; opened from Profile)

## Reuse From Core
- `AppAppBar`
- `CustomButton`
- `LoadingWidget`
- `EmptyStateWidget`
- `AppErrorWidget`

## Module Files
```text
lib/modules/preview_cv/
  preview_cv_screen.dart
  preview_cv_controller.dart
  preview_cv_binding.dart
  widgets/
    cv_preview_view.dart      # PDF viewer or doc placeholder
    cv_download_button.dart
    no_cv_widget.dart         # "No CV uploaded yet"

lib/data/repositories/cv_repository.dart  # extend if exists
```

## Screen Spec
| Item | Detail |
|------|--------|
| Open from | Profile → View CV icon |
| File types | PDF, DOC, DOCX |
| If CV exists | Show preview + download |
| If no CV | Message: "No CV uploaded yet" |
| API | `GET /users/me/cv` or file URL from profile |

## Controller Logic
- Load CV metadata and file URL for current user (or `userId` from arguments)
- `downloadCv()` — save to device / open with `open_filex`
- PDF: render with `flutter_pdfview` or syncfusion viewer
- DOC/DOCX: show file info + "Open in app" via `open_filex`

## UI Requirements
- `no_cv_widget` uses `EmptyStateWidget` with upload CTA → optional link to Apply CV or profile edit
- `cv_preview_view` full remaining height
- `cv_download_button` uses `CustomButton` icon variant
- Show file name in app bar subtitle

## Widget Rules
- `no_cv_widget` composes `EmptyStateWidget` — do not rebuild empty state layout
- If `cv_file_preview` was promoted to core in prompt 07, reuse it here for metadata row

## Route Registration
Add `Routes.PREVIEW_CV`

## Output
CV preview screen with PDF support and empty state.
