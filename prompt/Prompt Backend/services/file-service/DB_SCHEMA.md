# File Service — DB Schema

Database: `file_db`

Use Flyway migration: `src/main/resources/db/migration/V1__init_file_schema.sql`

## Tables

### `file_metadata`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `owner_user_id` | UUID | indexed, not null |
| `file_name` | varchar(255) | original file name |
| `file_type` | varchar(32) | `AVATAR`, `CV`, `POSTER`, `VIDEO` |
| `mime_type` | varchar(160) | not null |
| `size_bytes` | bigint | not null |
| `bucket` | varchar(64) | not null |
| `object_key` | text | unique, not null |
| `created_at` | timestamptz | not null |
| `deleted_at` | timestamptz | nullable |

## Indexes

- `file_metadata.owner_user_id`
- `file_metadata.file_type`
- `file_metadata.object_key` unique
- Optional partial index where `deleted_at IS NULL`

## Storage mapping

MinIO object key pattern:

```text
<bucket>/<owner_user_id>/<file_id>/<safe_file_name>
```

