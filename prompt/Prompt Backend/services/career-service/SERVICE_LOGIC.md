# Career Service — Service Logic

## Ownership

Owns saved CV references, job applications, application statuses, and applicant review.

Does not own post creation, physical CV files, or user profile details.

## Core flows

| Flow | Logic |
| --- | --- |
| Set saved CV | Validate file exists and type is `CV` through file-service, then upsert `UserCv`. |
| Apply to job | Verify job post exists through content-service, validate CV file, enforce unique application, save, publish event. |
| List my applications | Return applications where `applicant_id = X-User-Id`. |
| List applicants | Verify caller owns the job post through content-service, then return applications for `job_post_id`. |
| Status update | Poster only; update status and publish `job.application.status_changed`. |

## Events published

- `job.application.submitted`
- `job.application.status_changed`

## Frontend alignment

- Upload CV flow calls file-service first, then career-service.
- Profile owner CV preview calls `/users/me/cv`.
- Applicant list uses `/job-applications?job_post_id=...`.

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Duplicate application | `CONFLICT` | 409 |
| Caller is not job poster | `FORBIDDEN` | 403 |
| CV file invalid | `INVALID_FILE` | 400 |
| Job/application not found | `NOT_FOUND` | 404 |
| Upstream service failure | `UPSTREAM_ERROR` | 502 |

