# AI Service — DB Schema

Database: `ai_db`

Owned by the Java `ai-service` Flyway migrations:

- `src/main/resources/db/migration/V1__init_ai_schema.sql`
- `src/main/resources/db/migration/V2__Ai_composite_indexes_checks_and_rename_cv_file_id.sql`

## Tables

### `ai_chat_sessions`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | not null |
| `topic` | varchar(32) | CHECK: `CV`, `JOB`, `INTERVIEW`, `STUDENT`, `FINANCE` |
| `title` | varchar(255) | not null |
| `created_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |

### `ai_chat_messages`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `session_id` | UUID | FK `ai_chat_sessions.id` ON DELETE CASCADE |
| `role` | varchar(16) | CHECK: `USER`, `ASSISTANT` |
| `content` | text | not null |
| `created_at` | timestamptz | not null |

### `ai_cv_interactions`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | not null, indexed |
| `section` | varchar(64) | not null |
| `original_text` | text | not null |
| `suggested_text` | text | not null |
| `cv_file_id` | UUID | nullable; aligns naming with `career_db.user_cvs.cv_file_id` (no cross-DB FK) |
| `created_at` | timestamptz | not null |

## Indexes / constraints (current)

- `idx_ai_chat_sessions_user_updated` on `(user_id, updated_at DESC)`
- `idx_ai_chat_sessions_updated_at` on `(updated_at DESC)`
- `idx_ai_chat_messages_session_created` on `(session_id, created_at)`
- `idx_ai_chat_messages_created_at` on `(created_at)`
- `idx_ai_cv_interactions_user_id` on `(user_id)`
- `idx_ai_cv_interactions_cv_file_id` on `(cv_file_id)`
- CHECK: `chk_ai_chat_sessions_topic`, `chk_ai_chat_messages_role`

## V2 notes

- Single-column `user_id` / `session_id` indexes were dropped in favor of composites.
- Column rename: `ai_cv_interactions.cv_id` → `cv_file_id`.
