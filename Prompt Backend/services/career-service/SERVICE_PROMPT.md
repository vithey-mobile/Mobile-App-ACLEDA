# Career Service — Service Prompt

Build the Career microservice.

## API Endpoints
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/job-applications` | JWT | Apply to job post with CV |
| GET | `/api/v1/job-applications` | JWT | My applications |
| GET | `/api/v1/job-applications?job_post_id={id}` | JWT | Applicants for job (poster only) |
| GET | `/api/v1/job-applications/{id}` | JWT | Application detail |
| PATCH | `/api/v1/job-applications/{id}/status` | JWT | Update status (poster) |
| GET | `/api/v1/users/me/cv` | JWT | Current user's CV metadata |
| PUT | `/api/v1/users/me/cv` | JWT | Set default CV file reference |

## Apply Request
```json
{
  "job_post_id": "uuid",
  "cv_file_id": "uuid-from-file-service"
}
```

## Application Response
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

## Status Update
```json
{ "status": "REVIEWED" }
```

## Business Rules
- One application per user per job post (409 on duplicate)
- Verify `cv_file_id` exists via FileServiceClient
- Verify job post exists via ContentServiceClient
- Poster authorization: call Content Service to confirm `authorId == currentUser`

## Required Modules
- `JobApplicationController`, `UserCvController`
- `JobApplicationService`, `ApplicantCvService`
- `ContentServiceClient`, `FileServiceClient`
- `JobApplicationEventPublisher`
- Flyway, OpenAPI, tests

## Output
Runnable career-service on port 8085.
