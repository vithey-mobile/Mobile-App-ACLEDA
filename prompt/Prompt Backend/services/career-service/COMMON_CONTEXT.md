# Career Service — Common Context

> Service-specific context. **Extends** the root `../../COMMON_CONTEXT.md` — all
> global rules (tech stack, package layout, response envelope, HTTP codes, auth,
> DB rules) still apply. This file only adds or overrides what is specific to the
> career-service. On conflict, the **more specific** file wins:
> `SERVICE_PROMPT.md` > this file > root `COMMON_CONTEXT.md`.

## Service Role

Job applications, CV file references, application-status tracking, and applicant
review for job posters. Owns applications and CV references only — job posts live
in Content Service and CV binaries live in File Service.

## Identity

| Item         | Value                       |
| ------------ | --------------------------- |
| Eureka name  | `career-service`            |
| Port         | 8085                        |
| Database     | `career_db` (PostgreSQL 16) |
| Base package | `com.vithey.career`         |

## Entities

Use UUID primary keys and `created_at` / `updated_at` on every entity (root DB rules).

### `JobApplication`

| Field         | Type      | Notes                                               |
| ------------- | --------- | --------------------------------------------------- |
| `id`          | UUID      | PK                                                  |
| `postId`      | UUID      | job post id (lives in Content Service)              |
| `applicantId` | UUID      | applicant user id                                   |
| `cvFileId`    | UUID      | reference into File Service                         |
| `status`      | enum      | `PENDING` \| `REVIEWED` \| `ACCEPTED` \| `REJECTED` |
| `appliedAt`   | timestamp |                                                     |

> Unique constraint on (`postId`, `applicantId`) — one application per user per post.

### `ApplicantCv`

| Field       | Type    | Notes                       |
| ----------- | ------- | --------------------------- |
| `id`        | UUID    | PK                          |
| `userId`    | UUID    | owner                       |
| `cvFileId`  | UUID    | reference into File Service |
| `fileName`  | String  | e.g. `resume.pdf`           |
| `isDefault` | boolean | one default per user        |

## Events Published

Use the root `<domain>.<action>` naming.

| Event                            | Payload                                          | Consumers    |
| -------------------------------- | ------------------------------------------------ | ------------ |
| `job.application.submitted`      | `{ applicationId, postId, applicantId }`         | Notification |
| `job.application.status_changed` | `{ applicationId, postId, applicantId, status }` | Notification |

## Inter-Service Dependencies

| Client                 | Used for                                                           |
| ---------------------- | ------------------------------------------------------------------ |
| `ContentServiceClient` | confirm a job post exists and resolve its `authorId` (poster auth) |
| `FileServiceClient`    | confirm a `cvFileId` exists                                        |

## API Prefix (owned by this service)

`/api/v1/job-applications/**`, `/api/v1/users/me/cv/**`

## Authorization

- **Applicant:** submit an application, view their own applications.
- **Job poster** (post owner, typically `COMPANY`): view applicants for their own posts.
- **Status update:** post owner only — confirm `authorId == current user` via Content Service.

## Does NOT Own

- Job posts → **Content Service** (career references them by `postId`)
- CV / file binaries → **File Service** (career stores only `cvFileId` references)
- Notification delivery → **Notification Service** (career only publishes events)
