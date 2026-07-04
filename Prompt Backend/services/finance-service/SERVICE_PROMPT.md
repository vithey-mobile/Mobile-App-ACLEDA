# Finance Service — Complete API Design

> Read `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`.  
> **Scope:** Backend REST API only — student payments, fees, alerts. **STUDENT role required.**

## Identity

| Item | Value |
|------|-------|
| Path | `vithey-backend/services/finance-service/` |
| Port | 8086 |
| Eureka | `finance-service` |
| Database | `finance_db` |
| Package | `com.vithey.finance` |

## Spring Cloud + tools

Eureka, Config, OpenFeign (optional auth verify), RabbitMQ, JPA, Flyway, `@Scheduled` for alerts.

## Folder structure

```text
services/finance-service/
└── src/main/java/com/vithey/finance/
    ├── FinanceServiceApplication.java
    ├── controller/PaymentController.java, FeeController.java
    ├── service/PaymentService.java, FeeService.java
    ├── scheduler/PaymentAlertScheduler.java
    ├── repository/PaymentRepository.java, FeeRepository.java, StudentFinanceAccountRepository.java
    ├── entity/Payment.java, Fee.java, FeeCategory.java, StudentFinanceAccount.java
    ├── dto/response/PaymentResponse.java, FeeResponse.java, PaymentAlertsResponse.java
    ├── event/listener/StudentVerifiedEventListener.java
    ├── event/publisher/PaymentEventPublisher.java
    ├── security/StudentRoleRequiredAspect.java
    └── exception/GlobalExceptionHandler.java
```

## Database

**StudentFinanceAccount:** `user_id` PK, `student_id`, `linked_at`

**FeeCategory:** `id`, `name`, `description`

**Fee:** `id`, `category_id`, `name`, `amount`, `currency` KHR|USD

**Payment:** `id`, `user_id`, `fee_id`, `amount`, `currency`, `status` UNPAID|PAID|OVERDUE, `due_date`, `paid_at`, `created_at`

## Complete API (all JWT + `@PreAuthorize("hasRole('STUDENT')")`)

| Method | Path | Description | HTTP |
|--------|------|-------------|------|
| GET | `/api/v1/payments` | Payment history, paginated | 200 |
| GET | `/api/v1/payments/{id}` | Detail (own only) | 200 |
| GET | `/api/v1/fees` | Fees assigned to student | 200 |
| GET | `/api/v1/fees/categories` | Fee categories | 200 |
| GET | `/api/v1/payments/alerts` | Due within 7 days + overdue | 200 |

**Payment list item:**
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

**Alerts:**
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

## Business logic

| Rule | Logic |
|------|-------|
| Access | Reject non-STUDENT with 403 |
| OVERDUE | `due_date < today` AND status != PAID |
| Scheduler daily | Publish `payment.due` (within 7 days), `payment.overdue` (past due) |
| student.verified | Create StudentFinanceAccount + seed dev sample payments |

## Events

**Consumed:** `student.verified`  
**Published:** `payment.due`, `payment.overdue`

## Errors

| Case | HTTP |
|------|------|
| Non-student | 403 |
| Payment not owned | 404 |

## Output

Runnable finance-service on **8086**.
