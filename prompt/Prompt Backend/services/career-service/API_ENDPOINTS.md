# Career Service — API Endpoints

Base path: `/api/v1`

All endpoints require JWT.

## Job applications

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/job-applications` | Apply to a job post |
| GET | `/job-applications` | Current user's applications (paginated) |
| GET | `/job-applications?job_post_id={id}` | Poster: all applicants; Applicant: own application for that job |
| GET | `/job-applications/{id}` | Application detail + timeline fields |
| PATCH | `/job-applications/{id}/status` | Poster updates applicant status |

### Apply request

```json
{
  "job_post_id": "uuid",
  "cv_file_id": "uuid",
  "application_note": "Optional cover message"
}
```

Aliases accepted: `application_note`, `cover_note` (stored as `cover_note`).

### Apply headers

| Header | Required | Purpose |
| --- | --- | --- |
| `Idempotency-Key` | No | Retry-safe submit; same key returns existing application |

### Apply response (`201`)

```json
{
  "application_id": "uuid",
  "job_post_id": "uuid",
  "job_title": "Web Developer",
  "organization": "Aeon Mall",
  "cv_file_id": "uuid",
  "cv_file_name": "resume.pdf",
  "status": "PENDING",
  "cover_note": "Optional message",
  "applied_at": "2026-07-07T09:14:00Z",
  "review_started_at": null,
  "decided_at": null,
  "reviewer_note": null
}
```

### Status update request

```json
{
  "status": "ACCEPTED",
  "reviewer_note": "Please check your email for interview details."
}
```

Allowed statuses: `PENDING`, `REVIEWED`, `ACCEPTED`, `REJECTED`.

When status becomes `REVIEWED`, `review_started_at` is set. When `ACCEPTED` or `REJECTED`, `decided_at` is set.

## User CV

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/users/me/cv` | Current user's saved CV metadata |
| PUT | `/users/me/cv` | Set/update saved default CV |

Gateway must route `/users/me/cv` here before generic `/users/**`.

## Error envelope

All errors return:

```json
{
  "error": {
    "code": "CONFLICT",
    "message": "Human-readable message"
  }
}
```

| Code | HTTP | When |
| --- | --- | --- |
| `CONFLICT` | 409 | Duplicate application (same job, no idempotency key) |
| `FORBIDDEN` | 403 | Caller is not job poster |
| `INVALID_FILE` | 400 | CV file invalid |
| `NOT_FOUND` | 404 | Job, application, or saved CV not found |
| `UPSTREAM_ERROR` | 502 | content-service / file-service / user-profile unavailable |

## Contract gaps (deferred)

| Gap | Owner | Notes |
| --- | --- | --- |
| `position_id` on multi-role jobs | content-service + career-service | Requires job positions in post metadata |
| `has_applied` on feed DTO | content-service | Avoid N+1 client enrichment |
| Push notification deep link | notification-service | `APPLICATION_STATUS` route on status change |
