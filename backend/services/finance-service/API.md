# Finance Service API

Base path: `/api/v1`

All endpoints require JWT with `STUDENT` role.

## Payments

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/payments?page=&limit=` | Student payment history |
| GET | `/payments/{paymentId}` | Payment/invoice detail |
| GET | `/payments/alerts` | Due soon and overdue alerts |

## Fees

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/fees` | Fees catalog |
| GET | `/fees/categories` | Fee category list |

## Events

**Consumed:** `student.verified`  
**Published:** `payment.due`, `payment.overdue`
