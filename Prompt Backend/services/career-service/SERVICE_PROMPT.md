# Career Service — Service Prompt

Authoritative API contract and build checklist for the Vithey Career microservice.
Read `KICKOFF_PROMPT.md` and both `COMMON_CONTEXT.md` files first.

## Conventions (avoid drift)

- **JSON fields:** `snake_case`. **Java fields:** `camelCase`. Map via MapStruct/Jackson.
- **All responses** use the root envelope (`{ "data": ... }` / `{ "error": ... }`).
- **All IDs** are UUID strings. Lists are paginated per root pagination rules.
- **Current user** comes from the JWT (`sub`), never from the request body.

## API Endpoints (all require JWT)

| Method | Path                                        | Description                              | Success |
| ------ | ------------------------------------------- | ---------------------------------------- | ------- |
| POST   | `/api/v1/job-applications`                  | Apply to a job post with a CV            | 201     |
| GET    | `/api/v1/job-applications`                  | Current user's applications (paginated)  | 200     |
| GET    | `/api/v1/job-applications?job_post_id={id}` | Applicants for a job — **poster only**   | 200     |
| GET    | `/api/v1/job-applications/{id}`             | Application detail (applicant or poster) | 200     |
| PATCH  | `/api/v1/job-applications/{id}/status`      | Update status — **poster only**          | 200     |
| GET    | `/api/v1/users/me/cv`                       | Current user's CV metadata               | 200     |
| PUT    | `/api/v1/users/me/cv`                       | Set the default CV file reference        | 200     |

## Request / Response Shapes

### Apply — request

```json
{ "job_post_id": "uuid", "cv_file_id": "uuid-from-file-service" }
```

### Application — response

```json
{
  "data": {
    "application_id": "uuid",
    "job_post_id": "uuid",
    "applicant": { "user_id": "uuid", "full_name": "Jane Doe" },
    "cv_file_id": "uuid",
    "cv_file_name": "resume.pdf",
    "status": "PENDING",
    "applied_at": "2026-01-01T00:00:00Z"
  }
}
```

### Status update — request

```json
{ "status": "REVIEWED" }
```

`status` ∈ {`PENDING`, `REVIEWED`, `ACCEPTED`, `REJECTED`}.

## Business Rules

- One application per user per job post — `409` on duplicate.
- Verify `cv_file_id` exists via `FileServiceClient` before saving.
- Verify the job post exists via `ContentServiceClient` before saving.
- Poster authorization: call Content Service to confirm `authorId == current user`
  for the applicants list and status-update endpoints.
- Publish `job.application.submitted` on create and `job.application.status_changed`
  on every status change.

## Error Behavior (use root envelope + codes)

| Case                                                           | Code               | HTTP |
| -------------------------------------------------------------- | ------------------ | ---- |
| Duplicate application                                          | `CONFLICT`         | 409  |
| Caller is not the post owner (applicants list / status update) | `FORBIDDEN`        | 403  |
| Job post / CV file / application not found                     | `NOT_FOUND`        | 404  |
| Validation failure                                             | `VALIDATION_ERROR` | 400  |
| Content/File service unavailable                               | `UPSTREAM_ERROR`   | 502  |

## Required Modules

- Controllers: `JobApplicationController`, `UserCvController`
- Services: `JobApplicationService`, `ApplicantCvService`
- Clients: `ContentServiceClient`, `FileServiceClient`
- Events: `JobApplicationEventPublisher`
- Config: `GlobalExceptionHandler`
- Migration: `V1__init_career_schema.sql`

## Testing

- Apply flow with mocked Content/File clients test.
- Duplicate application (`409`) test.
- Non-owner cannot view applicants / update status (`403`) test.
- Event-published assertions with mocked RabbitMQ.

## Docs

`README.md` (run, env vars, port), `API.md` (endpoint summary), `ARCHITECTURE.md` (boundaries, DB, events, clients).

## Output

Complete, runnable career-service on port 8085.
