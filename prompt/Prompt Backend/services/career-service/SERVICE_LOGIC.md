# Career Service — Service Logic

## Ownership

Owns saved CV references, job applications, application statuses, and applicant review.

Does not own post creation, physical CV files, or user profile details.

## Core flows

| Flow | Logic |
| --- | --- |
| Set saved CV | Validate file exists and type is `CV` through file-service, then upsert `UserCv`. |
| Apply to job | Verify job post exists through content-service, validate CV file, enforce unique application, save, publish event. Optional `Idempotency-Key` header returns existing row on retry. |
| List my applications | Return applications where `applicant_id = X-User-Id`. |
| List by job post | If caller owns the job post → all applicants; else → caller's own application for that job (supports `hasApplied` without 403). |
| Status update | Poster only; update status, set timeline timestamps, optional `reviewer_note`, publish `job.application.status_changed`. |

## Timeline rules

| Status transition | Side effect |
| --- | --- |
| → `REVIEWED` | Set `review_started_at` if null |
| → `ACCEPTED` / `REJECTED` | Set `decided_at` if null |
| Any with `reviewer_note` in request | Persist poster message for applicant UI |

## Events published

- `job.application.submitted`
- `job.application.status_changed`

## Frontend alignment

- Apply wizard sends `application_note` (alias of `cover_note`).
- Status screen reads `review_started_at`, `decided_at`, `reviewer_note`, `job_title`, `organization`.
- Home feed applied-state: client enriches until content-service adds `has_applied`.

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Duplicate application | `CONFLICT` | 409 |
| Caller is not job poster | `FORBIDDEN` | 403 |
| CV file invalid | `INVALID_FILE` | 400 |
| Job/application not found | `NOT_FOUND` | 404 |
| Upstream service failure | `UPSTREAM_ERROR` | 502 |

## Deferred integrations

- **`position_id`**: blocked on content-service job positions model.
- **Feed `has_applied`**: blocked on content-service feed DTO enrichment.
- **Status push deep link**: notification-service consumer of `job.application.status_changed`.
