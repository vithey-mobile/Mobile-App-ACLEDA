# AI Service — DB Schema

Database: `ai_db`

Use Flyway migration: `src/main/resources/db/migration/V1__init_ai_schema.sql`

## Tables

### `ai_chat_sessions`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | indexed |
| `topic` | varchar(32) | `CV`, `JOB`, `INTERVIEW`, `STUDENT`, `FINANCE` |
| `title` | varchar(180) | nullable/generated |
| `created_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |
| `deleted_at` | timestamptz | nullable |

### `ai_chat_messages`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `session_id` | UUID | FK `ai_chat_sessions.id`, indexed |
| `role` | varchar(32) | `USER`, `ASSISTANT` |
| `content` | text | not null |
| `created_at` | timestamptz | not null |

## Indexes

- `ai_chat_sessions.user_id, updated_at`
- `ai_chat_messages.session_id, created_at`

## Redis keys

```text
ai:rate-limit:<user_id>
```

TTL: 1 hour.

