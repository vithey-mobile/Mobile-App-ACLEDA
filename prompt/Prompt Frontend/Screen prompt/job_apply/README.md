# Job Apply — CV Upload & Application Status Prompt Index

Complete specification for the **Apply Job** wizard and **Apply Status** tracking in Vithey App.

## Product goal

Deliver a guided, trustworthy job-application experience:

1. **Step 1 — Upload CV** — pick position (when multi-role), attach a private CV document
2. **Step 2 — Review** — confirm file, read what happens next, submit once
3. **Success** — clear confirmation with CTA to track status
4. **Apply Status** — vertical timeline for Submitted → Under Preview → Decision (pending / accepted / rejected)

## Visual references

| Screen | Asset |
|--------|-------|
| Step 1 — Upload CV | `Prompt Frontend/screen image/job_apply/Apply CV Screen.png` |
| Step 2 — Review CV | `Prompt Frontend/screen image/job_apply/Apply CV Screen 01.png` |
| Success | `Prompt Frontend/screen image/job_apply/Apply CV Screen 02.png` |
| Status — just submitted | `Prompt Frontend/screen image/job_apply/Application Status.png` |
| Status — under review | `Prompt Frontend/screen image/job_apply/Application Status 01.png` |
| Status — accepted | `Prompt Frontend/screen image/job_apply/Application Status 02.png` |
| Status — not selected | `Prompt Frontend/screen image/job_apply/Application Status 03.png` |

## Flow diagram

```text
Home / Post Detail / Profile Jobs
        │
        ▼ Tap Apply (eligible job)
┌───────────────────┐
│ Step 1: Upload CV │  Apply CV Screen.png
│ Position + file   │
└─────────┬─────────┘
          │ Continue
          ▼
┌───────────────────┐
│ Step 2: Review CV │  Apply CV Screen 01.png
│ What happens next │
└─────────┬─────────┘
          │ Submit Application
          ▼
┌───────────────────┐
│ Success           │  Apply CV Screen 02.png
└─────────┬─────────┘
          │ View Application Status
          ▼
┌───────────────────┐
│ Apply Status      │  Application Status *.png
│ (4 state variants)│
└───────────────────┘
```

## Reading order

| # | Prompt | Delivers |
|---|--------|----------|
| 1 | [`01.apply_cv_upload.md`](01.apply_cv_upload.md) | Wizard step 1 — position, CV picker, Continue |
| 2 | [`02.apply_cv_review.md`](02.apply_cv_review.md) | Wizard step 2 — file review, next steps, Submit |
| 3 | [`03.apply_success.md`](03.apply_success.md) | Post-submit confirmation screen |
| 4 | [`04.application_status.md`](04.application_status.md) | Timeline + accepted / rejected / pending states |
| 5 | [`05.apply_cv_api.md`](05.apply_cv_api.md) | REST contracts, eligibility, privacy, Home sync |

## Module architecture (target)

```text
lib/modules/apply_cv/
  apply_cv_flow_screen.dart       # hosts stepper + steps 1–2
  apply_cv_controller.dart        # wizard state machine
  apply_cv_binding.dart
  apply_success_screen.dart
  application_status_screen.dart
  application_status_controller.dart
  models/
    apply_cv_args.dart
    apply_cv_result.dart
    application_status_args.dart
    application_timeline_step.dart
  widgets/
    apply_job_stepper.dart        # 3-dot header progress
    position_selector.dart
    cv_upload_zone.dart
    selected_cv_card.dart
    what_happens_next_list.dart
    application_submitted_hero.dart
    application_status_hero.dart
    application_timeline.dart
    status_message_card.dart
    privacy_footer_note.dart

lib/data/models/
  cv_file_model.dart
  job_application_model.dart

lib/data/repositories/
  cv_repository.dart
  job_application_repository.dart
```

## Routes

| Route | Screen | Args |
|-------|--------|------|
| `Routes.APPLY_CV` | `ApplyCvFlowScreen` | `ApplyCvArgs(jobPostId, positionId?)` |
| `Routes.APPLY_SUCCESS` | `ApplySuccessScreen` | `ApplySuccessArgs(applicationId, jobTitle)` |
| `Routes.APPLICATION_STATUS` | `ApplicationStatusScreen` | `ApplicationStatusArgs(applicationId)` |

Entry from job cards:

```dart
Get.toNamed(
  Routes.APPLY_CV,
  arguments: ApplyCvArgs(jobPostId: post.id),
);
```

After success, Home / Post Detail / Profile must update the matching card from **Apply** → **Applied** using `ApplyCvResult` (see `05.apply_cv_api.md`).

## Shared business rules (all steps)

- Pass canonical `jobPostId`; never use poster image, QR, caption, or list index as identity.
- CV files are **private** (`type=CV` upload). See `05.apply_cv_api.md`.
- Client eligibility checks improve UX; **career-service** is authoritative.
- Support saved default CV, update-default CV, and application-only upload (see `05.apply_cv_api.md`).
- Display file policy from backend (PDF/DOC/DOCX, max size). Reference images show **JPG, PNG, or PDF (Max 5MB)** — only show that copy when file-service enables image CVs.

## Acceptance checklist (release gate)

- [ ] Step 1 matches `Apply CV Screen.png` — stepper, position, dashed upload, Continue, privacy note
- [ ] Step 2 matches `Apply CV Screen 01.png` — review card, What happens next, Submit + Back
- [ ] Success matches `Apply CV Screen 02.png` — illustration, View Application Status CTA
- [ ] Status matches all four `Application Status` variants with correct colors/icons
- [ ] Apply from job card opens wizard with correct `jobPostId`; does not open Post Detail
- [ ] Submit is idempotent; `409` reconciles to Applied
- [ ] Dark mode readable for stepper, timeline, accepted/rejected banners
- [ ] `flutter analyze` zero errors on touched files

## Output

Implement the full Apply Job module by following prompts **01 → 05** in order. Compose UI from `core/widgets/`; keep upload/application logic in repositories.
