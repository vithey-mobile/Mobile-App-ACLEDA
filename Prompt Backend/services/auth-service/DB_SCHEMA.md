# Auth Service — DB Schema

Database: `auth_db`

Use Flyway migration: `src/main/resources/db/migration/V1__init_auth_schema.sql`

## Tables

### `users`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `email` | varchar(255) | unique, not null |
| `phone` | varchar(32) | unique, not null |
| `password_hash` | varchar(255) | not null |
| `full_name` | varchar(160) | not null |
| `role` | varchar(32) | `USER`, `STUDENT`, `COMPANY`, `ADMIN` |
| `is_student_verified` | boolean | default false |
| `is_email_verified` | boolean | default false |
| `created_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |
| `deleted_at` | timestamptz | nullable |

### `refresh_tokens`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | FK `users.id`, indexed |
| `token_hash` | varchar(255) | unique, not null |
| `expires_at` | timestamptz | not null |
| `revoked_at` | timestamptz | nullable |
| `created_at` | timestamptz | not null |

### `student_verifications`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | FK `users.id`, unique |
| `student_id` | varchar(64) | not null |
| `university_email` | varchar(255) | not null |
| `status` | varchar(32) | `PENDING`, `VERIFIED`, `REJECTED` |
| `verified_at` | timestamptz | nullable |
| `created_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |

## Indexes

- Unique: `users.email`, `users.phone`, `refresh_tokens.token_hash`
- Index: `refresh_tokens.user_id`, `refresh_tokens.expires_at`
- Index: `student_verifications.status`

