# Career Service Architecture

## Responsibility

Owns saved CV references, job applications, application statuses, and applicant review.

Does not own post creation, physical CV files, or user profile details.

## Dependencies

| Service | Usage |
| --- | --- |
| `content-service` | Verify job posts exist and caller is the poster |
| `file-service` | Validate CV file type and resolve file metadata |
| `user-profile-service` | Applicant display names |
| `rabbitmq` | Publish application events |
| `eureka-server` | Service discovery |
| `config-server` | Externalized configuration |

## Data store

PostgreSQL database `career_db` with tables: `job_applications`, `user_cvs`.

Unique constraint on `(job_post_id, applicant_id)` prevents duplicate applications.

## Key flows

1. **Set CV** — validate file type `CV` via file-service, upsert `user_cvs`.
2. **Apply** — verify job post via content-service, validate CV, save application, publish `job.application.submitted`.
3. **List applicants** — poster-only via content-service author check.
4. **Status update** — poster-only, publish `job.application.status_changed`.

## Port

`8085` (Eureka name: `career-service`)
