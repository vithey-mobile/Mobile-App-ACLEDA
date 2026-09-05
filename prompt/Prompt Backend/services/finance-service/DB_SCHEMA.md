# Finance Service — DB Schema

Database: `finance_db`

Flyway migrations:

- `src/main/resources/db/migration/V1__init_finance_schema.sql`
- `src/main/resources/db/migration/V2__Payment_indexes_and_status_check.sql`

## Tables

### `student_finance_accounts`

`user_id` UUID PK, `student_id` varchar(64), `linked_at` timestamptz.

### `fee_categories`

`id` UUID PK, `name` varchar(120), `description` text, `created_at` timestamptz.

### `fees`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `category_id` | UUID | FK `fee_categories.id`, indexed |
| `name` | varchar(180) | not null |
| `amount` | numeric(14,2) | not null |
| `currency` | varchar(8) | `KHR`, `USD` |
| `created_at` | timestamptz | not null |

### `payments`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | not null |
| `fee_id` | UUID | FK `fees.id` |
| `amount` | numeric(14,2) | not null |
| `currency` | varchar(8) | `KHR`, `USD` |
| `status` | varchar(32) | CHECK: `UNPAID`, `PAID`, `OVERDUE` |
| `due_date` | date | nullable |
| `paid_at` | timestamptz | nullable |
| `created_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |

## Indexes / constraints (current)

- `idx_payments_user_due_created` on `(user_id, due_date ASC, created_at DESC)`
- `idx_payments_unpaid_due_date` on `(due_date)` WHERE `status <> 'PAID'`
- `idx_fees_category_id` on `(category_id)`
- CHECK: `chk_payments_status`

## V2 notes

- Replaced single-column `payments.user_id` / `status` / `due_date` indexes with the composites/partial index above.
