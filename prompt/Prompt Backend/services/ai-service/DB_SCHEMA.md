# AI / Chatbot — DB Schema (Python — your choice)

> Vithey Java repo does not own `ai_db`.  
> If your Python service needs persistence, define schema in **your Python project**.

## Suggested tables (if you implement Vithey session API)

### `ai_chat_sessions`

| Column | Type |
| --- | --- |
| `id` | UUID PK |
| `user_id` | UUID |
| `topic` | varchar — `CV`, `JOB`, `INTERVIEW`, `STUDENT`, `FINANCE` |
| `title` | varchar nullable |
| `created_at` | timestamptz |
| `updated_at` | timestamptz |
| `deleted_at` | timestamptz nullable |

### `ai_chat_messages`

| Column | Type |
| --- | --- |
| `id` | UUID PK |
| `session_id` | UUID FK |
| `role` | `USER` or `ASSISTANT` |
| `content` | text |
| `created_at` | timestamptz |

Use Alembic, SQLAlchemy, or your ORM in Python.

If you reuse GDCE stack with in-memory history, you may still add Vithey session tables in your adapter for `GET /sessions` API compliance.
