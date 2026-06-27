# Finance Service — Service Prompt

Authoritative API contract and build checklist for the Vithey Finance microservice.
Read `KICKOFF_PROMPT.md` and both `COMMON_CONTEXT.md` files first.

## Conventions (avoid drift)

- **JSON fields:** `snake_case`. **Java fields:** `camelCase`. Map via MapStruct/Jackson.
- **All responses** use the root envelope (`{ "data": ... }` / `{ "error": ... }`).
- **All IDs** are UUID strings. Lists are paginated per root pagination rules.
- **Amounts** are raw integers with a separate `currency` code — no formatting server-side.
- **Current student** comes from the JWT (`sub` → `studentId`), never from the request.

## API Endpoints (all require `STUDENT` role)

| Method | Path                      | Description                                     | Success |
| ------ | ------------------------- | ----------------------------------------------- | ------- |
| GET    | `/api/v1/payments`        | Payment history for current student (paginated) | 200     |
| GET    | `/api/v1/payments/{id}`   | Payment detail (must belong to caller)          | 200     |
| GET    | `/api/v1/fees`            | All fees assigned to current student            | 200     |
| GET    | `/api/v1/fees/categories` | Fee categories                                  | 200     |
| GET    | `/api/v1/payments/alerts` | Upcoming due payments (next 7 days)             | 200     |

## Response Shapes

### Payment list — response

```json
{
  "data": [
    {
      "payment_id": "uuid",
      "fee_name": "Tuition Semester 1",
      "amount": 1500000,
      "currency": "KHR",
      "status": "UNPAID",
      "due_date": "2026-03-15",
      "paid_at": null
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 5, "total_pages": 1 }
}
```

### Alerts — response

```json
{
  "data": {
    "alerts": [
      {
        "payment_id": "uuid",
        "fee_name": "Tuition Semester 1",
        "due_date": "2026-03-15",
        "days_remaining": 5,
        "amount": 1500000,
        "currency": "KHR"
      }
    ]
  }
}
```

## Business Rules

- A payment is `OVERDUE` when `due_date < today` and status is not `PAID`.
- Daily scheduled job scans unpaid fees and:
  - publishes `payment.due` when a fee is due within 7 days,
  - publishes `payment.overdue` when `due_date` has passed and it is unpaid.
- Amounts are raw integers (intl-compatible); never format currency in the API.

## Student-Verified Listener

On `student.verified`, create or link the `studentId` in finance records.
In the `dev` profile, seed sample fees for that student.

## Error Behavior (use root envelope + codes)

| Case                                         | Code               | HTTP |
| -------------------------------------------- | ------------------ | ---- |
| Non-student / unverified caller              | `FORBIDDEN`        | 403  |
| Payment/fee not found or not owned by caller | `NOT_FOUND`        | 404  |
| Validation failure (bad query params)        | `VALIDATION_ERROR` | 400  |

## Required Modules

- Controllers: `PaymentController`, `FeeController`
- Services: `PaymentService`, `FeeService`, `PaymentAlertScheduler`
- Events: `StudentVerifiedEventListener`, `PaymentEventPublisher`
- Client: `AuthServiceClient` (verify `STUDENT` role when needed)
- Config: `GlobalExceptionHandler`
- Migration: `V1__init_finance_schema.sql` (+ dev seed data)

## Testing

- Access-control test: non-student gets `403`.
- Ownership test: student cannot read another student's payment (`404`).
- Overdue-status calculation test.
- Scheduler publishes `payment.due` / `payment.overdue` (mocked RabbitMQ) test.
- `student.verified` listener links/seeds records test.

## Docs

`README.md` (run, env vars, port), `API.md` (endpoint summary), `ARCHITECTURE.md` (boundaries, DB, events, scheduler).

## Output

Complete, runnable finance-service on port 8086.
