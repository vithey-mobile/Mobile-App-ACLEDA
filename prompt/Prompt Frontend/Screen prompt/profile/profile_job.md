# Profile Jobs Tab Prompt

Build the Jobs tab shown in `Prompt Frontend/screen image/profile/profile_job.png`.

## Data and layout

- Fetch `GET /api/v1/users/{userId}/posts?type=JOB`.
- Compact cards: thumbnail, structured job title, organization, employment type, location, created time, lifecycle state.
- Use typed job metadata; never OCR the image to drive behavior.

## Visitor actions

- Open/eligible/not applied → **Apply**.
- Applied → **Applied** or View Application.
- Closed/expired/full → **Closed**.
- Apply opens `../upload_cv/01.upload_cv.md` with canonical job ID.
- View Detail opens Post Detail.

## Owner actions

- Never show Apply on own jobs.
- Show **View Applicants** and authorized applicant count, or **No applicants**.
- Open `poster_job/list_cv_apply_job.md` with stable job ID.
- Owner management/list behavior is detailed in `poster_job/list_poster_job.md`.

## Contract/state

Feed response needs lifecycle, current-user application state, location/type, and owner-only applicant count. Avoid one request per card.

Support skeleton, empty, refresh, pagination/error, stale/race reconciliation, and unavailable jobs. Preserve tab scroll.

## Reuse/testing

- Reuse `../media/card_poster/03.poster_job.md` typed job state.
- Verify owner never Apply; visitor never View Applicants.
- Verify exact IDs route to Apply/applicants/detail.
- Closed/duplicate/race states reconcile without invalid submission.

## Output

Deliver a typed Profile Jobs tab with correct visitor application and owner applicant-management actions.
