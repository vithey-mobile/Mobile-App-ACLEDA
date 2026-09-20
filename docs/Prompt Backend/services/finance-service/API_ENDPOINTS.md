# Finance Service — API Endpoints

Base path: `/api/v1`

All endpoints require JWT and `STUDENT` role.

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/payments?page=&limit=` | Student payment history |
| GET | `/payments/{payment_id}` | Payment/invoice detail |
| GET | `/payments/alerts` | Due soon and overdue alerts |
| GET | `/fees` | Fees assigned to current student |
| GET | `/fees/categories` | Fee category list |

## Payment list item

```json
{
  "payment_id": "uuid",
  "fee_name": "Tuition Semester 1",
  "amount": 1500000,
  "currency": "KHR",
  "status": "UNPAID",
  "due_date": "2026-03-15",
  "paid_at": null
}
```

## Access rules

- Non-verified users receive `403`.
- Caller can only read their own payments.
- Finance is unlocked by `student.verified` event from auth-service.

