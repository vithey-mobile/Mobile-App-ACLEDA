# Career Service — DB Schema

Database: `career_db`

Flyway migrations:

- `src/main/resources/db/migration/V1__init_career_schema.sql`
- `src/main/resources/db/migration/V2__Job_application_composite_indexes_and_status_check.sql`

## Tables

### `job_applications`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `job_post_id` | UUID | content-service post id |
| `applicant_id` | UUID | not null |
| `cv_file_id` | UUID | file-service id |
| `cover_note` | text | nullable |
| `status` | varchar(32) | CHECK: `PENDING`, `REVIEWED`, `ACCEPTED`, `REJECTED` |
| `applied_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |

Unique: `(job_post_id, applicant_id)`.

### `user_cvs`

| Column | Type | Rules |
| --- | --- | --- |
| `user_id` | UUID | PK |
| `cv_file_id` | UUID | not null |
| `file_name` | varchar(255) | cached display name |
| `updated_at` | timestamptz | not null |

## Indexes / constraints (current)

- `idx_job_applications_applicant_applied` on `(applicant_id, applied_at DESC)`
- `idx_job_applications_post_applied` on `(job_post_id, applied_at DESC)`
- Unique: `uq_job_applications_post_applicant` on `(job_post_id, applicant_id)`
- CHECK: `chk_job_applications_status`

## V2 notes

- Single-column indexes on `applicant_id`, `job_post_id`, and `status` were replaced by the composites above.
