# User Profile Service — DB Schema

Database: `user_db`

Flyway migrations:

- `src/main/resources/db/migration/V1__init_profile_schema.sql`
- `src/main/resources/db/migration/V2__Enable_pg_trgm_and_full_name_gin_index.sql`

## Tables

### `profiles`

| Column | Type | Rules |
| --- | --- | --- |
| `user_id` | UUID | PK, same id as auth user |
| `full_name` | varchar(160) | not null |
| `bio` | text | nullable |
| `avatar_file_id` | UUID | nullable |
| `avatar_url` | text | nullable |
| `telegram_link` | text | nullable |
| `facebook_link` | text | nullable |
| `university` | varchar(160) | nullable |
| `major` | varchar(160) | nullable |
| `graduation_year` | integer | nullable |
| `created_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |

### `user_settings`

| Column | Type | Rules |
| --- | --- | --- |
| `user_id` | UUID | PK |
| `language` | varchar(8) | `km`, `en` |
| `theme` | varchar(16) | `light`, `dark`, `system` |
| `notification_prefs` | jsonb | default `{}` |
| `privacy_prefs` | jsonb | default `{}` |
| `fcm_token` | text | nullable |
| `updated_at` | timestamptz | not null |

## Indexes / constraints (current)

- `idx_profiles_full_name_trgm` — GIN on `LOWER(full_name)` using `gin_trgm_ops` (requires `pg_trgm`)
- Extension: `CREATE EXTENSION IF NOT EXISTS pg_trgm`

Search path uses escaped `LIKE` on `full_name` / `university` / `major` with `ORDER BY full_name` and column projections (`user_id`, `full_name`, `avatar_url`, `university`, `major`, `workplace`) so `bio` TEXT is not loaded for typeahead.

## V2 notes

- Replaced btree `idx_profiles_full_name` with trigram GIN for fuzzy/full-name search.
- Managed Postgres may need a one-time DBA grant to create `pg_trgm`.
