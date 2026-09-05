# Finance Service — Common Context

> Service-specific context. **Extends** the root `../../COMMON_CONTEXT.md` — all
> global rules (tech stack, package layout, response envelope, HTTP codes, auth,
> DB rules) still apply. This file only adds or overrides what is specific to the
> finance-service. On conflict, the **more specific** file wins:
> `SERVICE_PROMPT.md` > this file > root `COMMON_CONTEXT.md`.

## Service Role

University payment history, payment-status tracking, and due-date alerts for
**verified AUB students**. Read-only to students — fees are seeded/managed
upstream, not created via the public API.

## Identity

| Item         | Value                        |
| ------------ | ---------------------------- |
| Eureka name  | `finance-service`            |
| Port         | 8086                         |
| Database     | `finance_db` (PostgreSQL 16) |
| Base package | `com.vithey.finance`         |

## Entities

Use UUID primary keys and `created_at` / `updated_at` on every entity (root DB rules).
Money is stored as integer **minor units** (or `BIGINT`) — never floating point.

### `TuitionFee`

| Field        | Type   | Notes                     |
| ------------ | ------ | ------------------------- |
| `id`         | UUID   | PK                        |
| `studentId`  | String | AUB student id            |
| `feeName`    | String | e.g. `Tuition Semester 1` |
| `amount`     | BIGINT | raw amount, no formatting |
| `currency`   | String | ISO 4217, e.g. `KHR`      |
| `dueDate`    | date   |                           |
| `categoryId` | UUID   | FK → `FeeCategory.id`     |

### `Payment`

| Field       | Type      | Notes                                        |
| ----------- | --------- | -------------------------------------------- |
| `id`        | UUID      | PK                                           |
| `feeId`     | UUID      | FK → `TuitionFee.id`                         |
| `studentId` | String    | owner                                        |
| `amount`    | BIGINT    |                                              |
| `status`    | enum      | `PAID` \| `UNPAID` \| `PENDING` \| `OVERDUE` |
| `paidAt`    | timestamp | nullable until paid                          |

### `FeeCategory`

| Field         | Type   | Notes    |
| ------------- | ------ | -------- |
| `id`          | UUID   | PK       |
| `name`        | String | unique   |
| `description` | String | nullable |

## Events

Use the root `<domain>.<action>` naming.

| Direction | Event              | Payload                                               | Counterparty                                  |
| --------- | ------------------ | ----------------------------------------------------- | --------------------------------------------- |
| Consumes  | `student.verified` | `{ userId, studentId }`                               | from Auth — link/seed student finance records |
| Publishes | `payment.due`      | `{ paymentId, studentId, dueDate, amount, currency }` | Notification                                  |
| Publishes | `payment.overdue`  | `{ paymentId, studentId, dueDate, amount, currency }` | Notification                                  |

## API Prefix (owned by this service)

`/api/v1/fees/**`, `/api/v1/payments/**`

## Access Control

- `@PreAuthorize("hasRole('STUDENT')")` on **all** endpoints.
- Non-students / unverified users get `403`.
- A student may only read **their own** records (filter by `studentId` from JWT).

## Does NOT Own

- Student identity / verification → **Auth Service** (finance only reacts to `student.verified`)
- Notification delivery → **Notification Service** (finance only publishes events)
