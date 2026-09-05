# Career Service — Complete API Design

> Read `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`.  
> **Scope:** Backend REST API only — job applications, CV metadata.

## Identity

| Item | Value |
|------|-------|
| Path | `backend/services/career-service/` |
| Port | 8085 |
| Eureka | `career-service` |
| Database | `career_db` |
| Package | `com.vithey.career` |

## Spring Cloud + tools

Eureka, Config, OpenFeign (content-service, file-service), RabbitMQ, JPA, Flyway, MapStruct.

## Folder structure

```text
services/career-service/
└── src/main/java/com/vithey/career/
    ├── CareerServiceApplication.java
    ├── controller/JobApplicationController.java, UserCvController.java
    ├── service/JobApplicationService.java, UserCvService.java
    ├── repository/JobApplicationRepository.java, UserCvRepository.java
    ├── entity/JobApplication.java, UserCv.java
    ├── dto/request/ApplyJobRequest.java, UpdateApplicationStatusRequest.java, SetCvRequest.java
    ├── dto/response/JobApplicationResponse.java, UserCvResponse.java
    ├── client/ContentServiceClient.java, FileServiceClient.java
    ├── event/publisher/JobApplicationEventPublisher.java
    └── exception/GlobalExceptionHandler.java
```

## Database

**JobApplication:** `id`, `job_post_id`, `applicant_id`, `cv_file_id`, `status` PENDING|REVIEWED|ACCEPTED|REJECTED, `applied_at`, `updated_at` — unique(job_post_id, applicant_id)

**UserCv:** `user_id` PK, `cv_file_id`, `file_name`, `updated_at`

## Complete API (all JWT)

| Method | Path | Request | HTTP |
|--------|------|---------|------|
| POST | `/api/v1/job-applications` | `{ "job_post_id", "cv_file_id" }` | 201 |
| GET | `/api/v1/job-applications` | my applications, paginated | 200 |
| GET | `/api/v1/job-applications?job_post_id={id}` | applicants — **poster only** | 200 |
| GET | `/api/v1/job-applications/{id}` | detail | 200 |
| GET | `/api/v1/job-applications/{id}/cv-preview` | `{ download_url }` — applicant or poster | 200 |
| PATCH | `/api/v1/job-applications/{id}/status` | `{ "status": "REVIEWED" }` — poster | 200 |
| GET | `/api/v1/users/me/cv` | current user CV metadata | 200 |
| PUT | `/api/v1/users/me/cv` | `{ "cv_file_id": "uuid" }` | 200 |

**Application response:**
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

## Business logic

| Flow | Steps |
|------|-------|
| Apply | Verify job via ContentServiceClient → verify CV via FileServiceClient → save → publish `job.application.submitted` |
| List applicants | ContentServiceClient confirms caller is job post author |
| Status update | Poster only → publish `job.application.status_changed` |
| CV preview | Ownership check (applicant or poster) → FileServiceClient resolves `download_url` + `cv_file_name` |
| Set CV | Validate file type CV → upsert UserCv |

## Events published

`job.application.submitted`, `job.application.status_changed`

## Errors

| Case | Code | HTTP |
|------|------|------|
| Duplicate application | CONFLICT | 409 |
| Not poster | FORBIDDEN | 403 |
| Not found | NOT_FOUND | 404 |
| Upstream down | UPSTREAM_ERROR | 502 |

## Output

Runnable career-service on **8085**.
