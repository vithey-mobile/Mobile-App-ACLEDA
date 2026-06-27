# Finance Service — Common Context

## Service Role
University payment history, payment status tracking, due-date alerts for verified AUB students.

## Identity
| Item | Value |
|------|-------|
| Eureka name | `finance-service` |
| Port | 8086 |
| Database | `finance_db` |
| Package | `com.vithey.finance` |

## Entities
- `TuitionFee` — id, studentId, feeName, amount, currency, dueDate, categoryId
- `Payment` — id, feeId, studentId, amount, status (PAID/UNPAID/PENDING/OVERDUE), paidAt
- `FeeCategory` — id, name, description

## Events
- **Consumes:** `student.verified` → link student record
- **Publishes:** `payment.due`, `payment.overdue`

## API Prefix
`/api/v1/fees/**`, `/api/v1/payments/**`

## Access Control
`@PreAuthorize("hasRole('STUDENT')")` on all endpoints. Return 403 for unverified users.
