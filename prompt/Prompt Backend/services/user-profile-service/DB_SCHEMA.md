# User Profile Service — DB Schema

Database: `user_db`

Use Flyway migration: `src/main/resources/db/migration/V1__init_profile_schema.sql`

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

## Indexes

- `profiles.full_name` — btree for sort
- `V2__search_indexes.sql` — `CREATE INDEX idx_profiles_full_name_trgm ON profiles USING gin (full_name gin_trgm_ops);` (requires `pg_trgm`)
- Optional: btree on `university`, `major` for ILIKE fallback
- `user_settings.fcm_token` if device token remains here; notification-service also owns device registration

**Search spec:** `Prompt Backend/_shared/SEARCH.md`

