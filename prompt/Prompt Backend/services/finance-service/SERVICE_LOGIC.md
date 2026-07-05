# Finance Service — Service Logic

## Ownership

Owns verified-student finance account, fee categories, assigned fees, payment records, invoices, and payment alerts.

Does not own student verification; it consumes `student.verified` from auth-service.

## Core flows

| Flow | Logic |
| --- | --- |
| Access check | Require `STUDENT` role from `X-User-Roles`; otherwise return `403`. |
| Student verified | Consume event, create `StudentFinanceAccount`, optionally seed local demo payments. |
| Payments | Return only payments where `user_id = X-User-Id`. |
| Overdue status | Treat unpaid payment as overdue when `due_date < today`. |
| Alerts | Return due within 7 days and overdue payments. |
| Scheduler | Daily job publishes `payment.due` and `payment.overdue` events. |

## Events

Consumed:

- `student.verified`

Published:

- `payment.due`
- `payment.overdue`

## Frontend alignment

- Verification screens unlock finance after auth-service verification.
- Finance Home calls `/payments`, `/payments/alerts`, and `/fees`.
- Invoice detail calls `/payments/{payment_id}`.

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Non-student | `FORBIDDEN` | 403 |
| Payment not owned | `NOT_FOUND` | 404 |
| Finance account missing | `NOT_FOUND` | 404 |

