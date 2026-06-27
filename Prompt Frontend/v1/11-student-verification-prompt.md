# 11 - Student Verification Screen Prompt

Build the **Student Verification** module for Vithey App.

## Goal
Verify real AUB students via student ID and university email/phone — unlock Finance on success.

## Depends On
- `03-auth-prompt.md`, `10-finance-prompt.md`

## Reuse From Core
- `CustomTextField`
- `CustomButton`
- `AppAppBar`
- `LoadingWidget`
- `AppErrorWidget`

## Module Files
```text
lib/modules/student_verification/
  student_verification_screen.dart
  student_verification_controller.dart
  student_verification_binding.dart
  widgets/
    student_verification_form.dart

lib/data/repositories/student_repository.dart
```

## Screen Spec
| Item | Detail |
|------|--------|
| Fields | Student ID, university email or phone |
| API | `POST /students/verify` |
| Success | Unlock Finance → navigate or snackbar + back |
| Failure | Show error message |

## Controller Logic
- Validate student ID format and email domain (e.g. `@aub.edu.kh` optional check)
- `submitVerification()` → API
- On success: update local user `isStudentVerified` flag
- `Get.offNamed(Routes.FINANCE)` or `Get.back(result: true)`

## UI Requirements
- Illustration at top (university / ID card Lottie)
- `student_verification_form` with 2–3 `CustomTextField`s
- Info text explaining why verification is needed
- Submit button with loading state
- Error banner using `AppErrorWidget` inline

## Widget Rules
- Form widget only composes core inputs — no custom TextField styling

## Route Registration
Add `Routes.STUDENT_VERIFICATION`

## Output
Verification form with success/failure handling and finance unlock.
