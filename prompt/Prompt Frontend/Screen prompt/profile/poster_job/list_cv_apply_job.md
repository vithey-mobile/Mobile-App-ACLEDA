# Applicants for One Job Prompt

Build the owner-only applicant list shown in `Prompt Frontend/screen image/profile/list_job_poster.png`.

## Route

`Routes.JOB_APPLICANTS` with typed `JobApplicantsArgs(jobPostId)`.

## Authorization

- Only the job author or approved hiring collaborator/admin may list applicants.
- Career-service verifies job ownership through content-service.
- Unauthorized users receive safe forbidden/not-found behavior and no cached applicant data.

## Layout

- App bar: Back, dynamic job title, optional filter/sort icon.
- Paginated applicant cards:
  - Avatar.
  - Full name.
  - Current headline/major when contractually available.
  - Location when permitted.
  - Applied date.
  - Status pill: Pending, Reviewed, Accepted, Rejected.
  - Teal **View CV**.
- Card tap opens application detail; View CV opens `preview_cv.md`.

## API

`GET /api/v1/job-applications?job_post_id={jobPostId}` with pagination and optional status filter.

Response must include application ID, applicant summary, CV metadata, status, and applied time to avoid N+1 profile calls.

## State

- Initial skeleton, empty **No applicants yet**, refresh, pagination/footer retry, filter state.
- De-duplicate by `applicationId`.
- Status changes from detail reconcile into this list.
- Preserve job context and scroll when returning from CV/detail.

## Privacy

- Applicant identity/contact/CV are hiring-purpose data.
- Never expose public CV URLs or data to non-owners.
- Avoid logging applicant details.

## Testing

- Matches applicant-list reference.
- Exact job/application IDs are used.
- Owner authorization and pagination/filtering work.
- View CV never triggers row detail simultaneously.
- Empty/error/long-name/large-text states do not overflow.

## Output

Deliver a secure owner-only applicant list for one selected job post.
