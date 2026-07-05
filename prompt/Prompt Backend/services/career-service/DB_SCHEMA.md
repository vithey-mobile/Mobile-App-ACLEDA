# Career Service — DB Schema

Database: `career_db`

Use Flyway migration: `src/main/resources/db/migration/V1__init_career_schema.sql`

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

Unique: `(job_post_id, applicant_id)`.

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

