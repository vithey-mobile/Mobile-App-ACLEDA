# Applicant CV Preview and Application Review Prompt

Build the secure CV preview and applicant-detail/review flow shown in:

- `Prompt Frontend/screen image/profile/list_apply_job_one_poster.png`.
- `Prompt Frontend/screen image/profile/detail_cv.png`.

## Routes

- `Routes.APPLICANT_CV_PREVIEW` with `applicationId`.
- `Routes.JOB_APPLICATION_DETAIL` with `applicationId`.

Never authorize by raw `cvFileId` alone.

## CV preview

- App bar **View CV** with Back/Close.
- Scrollable PDF pages or safe DOC/DOCX fallback.
- Filename, page loading/count, zoom, retry, unsupported-file handling.
- Use authenticated stream or short-lived signed URL granted through the owner-authorized application.
- Reference button **End submission** is ambiguous; use **Done/Close Preview** unless a real workflow is documented. Viewing a CV never ends/deletes an application.
- Hide download/share/print unless policy explicitly permits them.

## Applicant detail

Match `detail_cv.png`:

- Applicant summary with avatar/name and permitted contact/headline/location.
- Experience and Education only from approved structured profile/CV data; do not present OCR guesses as verified facts.
- Application status card with applied date/current stage.
- Bottom **Decline** and **Accept Application** for valid Pending/Reviewed states.

## Decision behavior

- Accept confirmation: **Accept this application?** Cancel / Accept.
- Decline confirmation: **Decline this application?** Cancel / destructive Decline.
- PATCH `/api/v1/job-applications/{applicationId}/status`.
- Backend enforces owner authorization and valid transitions.
- Prevent duplicate requests; reconcile list/detail and notify applicant through events.
- Terminal Accepted/Rejected states hide invalid actions.

## Security

- Career/file services verify current user owns the job before CV access.
- CV remains private; no public URL/gallery caching/logging.
- Clear temporary previews on close/logout/account switch.
- Applicant contact is shown only when application policy permits it.

## Contract gaps

- Secure reviewer CV delivery beyond generic file ownership.
- Structured experience/education/headline/location.
- Explicit status transition rules/idempotency.
- Safe filename/page/preview metadata.

## States and testing

- Detail/preview skeleton, download progress, unsupported/corrupt, expired URL retry, forbidden, missing application.
- Verify unauthorized users cannot enumerate/download.
- Verify View/Done does not change status.
- Verify Accept/Decline always confirm and update exact application once.
- Large documents/text and orientation changes remain usable.

## Reuse

Use the shared secure `CvDocumentViewer` also used by `../preview_own_cv.md`, with different authorization/download policies.

## Output

Deliver a private applicant CV viewer and confirmed owner-only application review flow.
