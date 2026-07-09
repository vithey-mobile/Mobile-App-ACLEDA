# Career Service — DB Schema

Database: `career_db`

Flyway migrations:

- `V1__init_career_schema.sql`
- `V2__application_timeline_and_idempotency.sql`

## Tables

### `job_applications`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `job_post_id` | UUID | indexed, content-service post id |
| `applicant_id` | UUID | indexed |
| `cv_file_id` | UUID | file-service id |
| `cover_note` | text | nullable |
| `status` | varchar(32) | `PENDING`, `REVIEWED`, `ACCEPTED`, `REJECTED` |
| `applied_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |
| `review_started_at` | timestamptz | nullable, set when status → `REVIEWED` |
| `decided_at` | timestamptz | nullable, set when status → `ACCEPTED` / `REJECTED` |
| `reviewer_note` | text | nullable, poster message to applicant |
| `idempotency_key` | varchar(128) | nullable, unique per applicant when set |

Unique constraints:

- `(job_post_id, applicant_id)`
- `(applicant_id, idempotency_key)` where `idempotency_key IS NOT NULL`

### `user_cvs`

| Column | Type | Rules |
| --- | --- | --- |
| `user_id` | UUID | PK |
| `cv_file_id` | UUID | not null |
| `file_name` | varchar(255) | cached display name |
| `updated_at` | timestamptz | not null |

## Indexes

- `job_applications.applicant_id`
- `job_applications.job_post_id`
- `job_applications.status`
- `job_applications (applicant_id, idempotency_key)` partial unique
