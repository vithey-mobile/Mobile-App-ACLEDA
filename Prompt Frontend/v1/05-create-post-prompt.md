# 05 - Create Post Screen Prompt

Build the **Create Post** module for Vithey App.

## Goal
Let users create video, poster, or job posts with upload and submit.

## Depends On
- `04-home-prompt.md`

## Reuse From Core
- `CustomButton`
- `CustomTextField`
- `AppAppBar`
- `LoadingWidget`
- `file_picker_helper.dart`, `permission_helper.dart`

## Module Files
```text
lib/modules/create_post/
  create_post_screen.dart
  create_post_controller.dart
  create_post_binding.dart
  widgets/
    post_type_selector.dart   # Chips: Video | Poster | Job
    video_upload_box.dart
    poster_upload_box.dart
    job_form.dart             # title, description, requirement, deadline

lib/data/services/upload_service.dart
```

## Screen Spec
| Item | Detail |
|------|--------|
| Video | Pick video from device (`image_picker` / file_picker) |
| Poster | Pick image |
| Job | Title, description, requirement, deadline fields |
| API | `POST /files/upload` then `POST /posts` |
| Success | Navigate back to Home, refresh feed |

## Controller Logic
- `selectedType` enum: video, poster, job
- `pickVideo()`, `pickImage()` with permission checks
- `submit()` — upload file if needed → create post → snackbar success → `Get.back(result: true)`
- Validate required fields per type
- Show upload progress (`RxDouble uploadProgress`)

## UI Requirements
- `post_type_selector` at top — horizontal chips
- Conditional body based on selected type
- Preview thumbnail for selected video/image
- `job_form` uses only `CustomTextField`
- Sticky bottom **Publish** `CustomButton` with loading state
- Date picker for job deadline

## Widget Rules
- Each upload box is a self-contained module widget
- Share dashed-border upload UI pattern between video/poster via optional `upload_drop_zone.dart` in module widgets

## Route Registration
Add `Routes.CREATE_POST`

## Output
Complete create-post flow with multipart upload service stub.
