# Owner Job Post List and Management Prompt

Build the owner's job-post list/management entry from Profile Jobs.

## Visual reference

- Base cards: `Prompt Frontend/screen image/profile/profile_job.png`.

## Behavior

- Only authenticated owner view exposes management.
- List own `JOB` posts with title, thumbnail, location/type, created time, lifecycle, applicant count.
- Tap card → Job Post Detail.
- **View Applicants** → `list_cv_apply_job.md` with canonical job ID.
- Optional Edit, Close/Reopen, Delete only when contracts exist.
- Delete/Close are confirmed and update Home/Profile state by ID.

## Authorization

- UI owner check is not authorization.
- Backend confirms current user owns the job for applicant counts and management.
- Never show applicant count/identities to other profile visitors.

## States

- Open, Closed, Expired, Full, Draft/Scheduled when supported.
- Skeleton, empty, refresh, pagination, management mutation/error.
- Empty owner state links to `../../media/03.create_poster.md` Job mode.

## Testing

- Only owned JOB posts appear.
- Exact job ID routes to applicants.
- Visitor cannot reach management by deep link.
- Delete/Close confirmation and rollback work.

## Output

Deliver an owner-only job management list connected to applicants for each specific job.
