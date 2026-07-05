# Finance Service Architecture

## Responsibility

Owns verified-student finance accounts, fee categories, fees, payment records, invoices, and payment alerts.

Does not own student verification; it consumes `student.verified` from auth-service.

## Dependencies

| Component | Usage |
| --- | --- |
| `rabbitmq` | Consume `student.verified`, publish payment alerts |
| `eureka-server` | Service discovery |
| `config-server` | Externalized configuration |

## Data store

PostgreSQL database `finance_db` with tables: `student_finance_accounts`, `fee_categories`, `fees`, `payments`.

## Key flows

1. **Student verified** — create finance account and seed demo payments.
2. **Payments** — return only the caller's own payments with computed `OVERDUE` status.
3. **Alerts** — due within 7 days and overdue unpaid payments.
4. **Scheduler** — daily job publishes `payment.due` and `payment.overdue`.

## Port

`8086` (Eureka name: `finance-service`)
