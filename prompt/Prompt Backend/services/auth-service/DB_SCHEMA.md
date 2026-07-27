# Auth Service — DB Schema

Database: `auth_db`

Flyway migrations:

- `src/main/resources/db/migration/V1__init_auth_schema.sql`
- `src/main/resources/db/migration/V2__Soft_delete_unique_email_phone_and_cascade_tokens.sql`

## Tables

### `users`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `email` | varchar(255) | not null; unique among active rows (`deleted_at IS NULL`) via `uq_users_email_active` on `LOWER(email)` |
| `phone` | varchar(32) | not null; unique among active rows via `uq_users_phone_active` |
| `password_hash` | varchar(255) | not null |
| `full_name` | varchar(160) | not null |
| `role` | varchar(32) | `USER`, `STUDENT`, `COMPANY`, `ADMIN` |
| `is_active` | boolean | default true |
| `is_student_verified` | boolean | default false |
| `is_email_verified` | boolean | default false |
| `created_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |
| `deleted_at` | timestamptz | nullable (soft delete) |

### `refresh_tokens`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | FK `users.id` **ON DELETE CASCADE**, indexed |
| `token_hash` | varchar(255) | unique, not null |
| `expires_at` | timestamptz | not null |
| `revoked_at` | timestamptz | nullable |
| `created_at` | timestamptz | not null |

### `password_reset_tokens`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | FK `users.id` **ON DELETE CASCADE**, indexed |
| `token_hash` | varchar(255) | unique, not null |
| `expires_at` | timestamptz | not null |
| `used_at` | timestamptz | nullable |
| `created_at` | timestamptz | not null |

### `email_verification_tokens`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | FK `users.id` **ON DELETE CASCADE**, indexed |
| `token_hash` | varchar(255) | unique, not null |
| `expires_at` | timestamptz | not null |
| `used_at` | timestamptz | nullable |
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

## Indexes / constraints (current)

- Partial unique: `uq_users_email_active` (`LOWER(email)` WHERE `deleted_at IS NULL`)
- Partial unique: `uq_users_phone_active` (`phone` WHERE `deleted_at IS NULL`)
- Unique: `refresh_tokens.token_hash`, `password_reset_tokens.token_hash`, `email_verification_tokens.token_hash`
- Index: `refresh_tokens.user_id`, `refresh_tokens.expires_at`
- Index: `password_reset_tokens.user_id`, `password_reset_tokens.expires_at`
- Index: `email_verification_tokens.user_id`, `email_verification_tokens.expires_at`
- Index: `student_verifications.status`

## V2 notes

- Plain `UNIQUE` on `users.email` / `users.phone` was replaced so soft-deleted accounts can re-register the same email/phone.
- Token FKs cascade on hard delete of a user row.
