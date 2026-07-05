# Finance Service — DB Schema

Database: `finance_db`

Use Flyway migration: `src/main/resources/db/migration/V1__init_finance_schema.sql`

## Tables

### `student_finance_accounts`

`user_id` UUID PK, `student_id` varchar(64), `linked_at` timestamptz.

### `fee_categories`

`id` UUID PK, `name` varchar(120), `description` text, `created_at` timestamptz.

### `fees`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `category_id` | UUID | FK `fee_categories.id` |
| `name` | varchar(180) | not null |
| `amount` | numeric(14,2) | not null |
| `currency` | varchar(8) | `KHR`, `USD` |
| `created_at` | timestamptz | not null |

### `payments`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | indexed |
| `fee_id` | UUID | FK `fees.id` |
| `amount` | numeric(14,2) | not null |
| `currency` | varchar(8) | `KHR`, `USD` |
| `status` | varchar(32) | `UNPAID`, `PAID`, `OVERDUE` |
| `due_date` | date | nullable |
| `paid_at` | timestamptz | nullable |
| `created_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |

## Indexes

- `payments.user_id`
- `payments.status`
- `payments.due_date`

