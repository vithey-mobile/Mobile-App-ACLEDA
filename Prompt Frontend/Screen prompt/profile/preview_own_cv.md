# Preview Own CV Prompt

Build the **Preview CV** module for Vithey App.


## Product spec

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `08` |
| Route | `Routes.PREVIEW_CV` |
| Flutter module | `lib/modules/preview_cv/` |
| Backend service(s) | `career-service`, `file-service` |
| Auth required | Yes |

## Purpose

Preview and download the user's **CV document**.

## Open from

- Profile → View CV icon

## Main UI

| Element | Description |
|---------|-------------|
| CV preview area | PDF viewer or doc placeholder |
| File name | In app bar or header |
| Download button | Save / open with device app |
| Empty state | "No CV uploaded yet" |

## File types

PDF, DOC, DOCX

## User actions

| Action | Result |
|--------|--------|
| Download | `open_filex` or save to device |
| Back | Return to Profile |

## Logic & behavior

- Load CV metadata for current user (or `userId` arg)
- PDF: `flutter_pdfview` / syncfusion viewer
- DOC/DOCX: show info + open externally
- Empty: link to upload CV if own profile

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v1/users/me/cv` | CV metadata + URL |
| GET | `/api/v1/files/{id}/download` | File stream |

## Status checklist

- [ ] UX/UI designed
- [ ] PDF preview works
- [ ] Empty state handled

## Goal
Allow users to preview and download their CV document (PDF, DOC, DOCX).

## Depends On
- `01.profile_home.md` (opened from the owner's Profile)

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
- `no_cv_widget` uses `EmptyStateWidget` with a profile/CV-update CTA; do not open job application without a canonical job ID.
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
