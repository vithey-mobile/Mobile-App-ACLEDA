# Finance Service — Service Prompt

Build the Finance microservice.

## API Endpoints
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/payments` | STUDENT | Payment history for current student |
| GET | `/api/v1/payments/{id}` | STUDENT | Payment detail |
| GET | `/api/v1/fees` | STUDENT | All assigned fees |
| GET | `/api/v1/fees/categories` | STUDENT | Fee categories |
| GET | `/api/v1/payments/alerts` | STUDENT | Upcoming due payments (7 days) |

## Payment Response
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

## Alert Response
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
- Status `OVERDUE` when `due_date < today` and not PAID
- Scheduled job (daily): scan unpaid fees → publish `payment.due` (7 days before) and `payment.overdue`
- Amounts formatted with `intl` compatible numbers (no formatting in API — raw numbers)

## Student Verified Listener
On `student.verified`, create or link `studentId` in finance records (seed sample fees for dev).

## Required Modules
- `PaymentController`, `FeeController`
- `PaymentService`, `FeeService`, `PaymentAlertScheduler`
- `StudentVerifiedEventListener`, `PaymentEventPublisher`
- `AuthServiceClient` — verify STUDENT role
- Flyway with seed data for dev, OpenAPI, tests

## Output
Runnable finance-service on port 8086.
