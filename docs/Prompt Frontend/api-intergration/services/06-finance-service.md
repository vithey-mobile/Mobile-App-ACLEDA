# 06 — Finance Service Integration Contract

> **Target Service:** `finance-service`  
> **Direct Port:** `8086` | **Gateway Base URLs:** `http://localhost:8080/api/v1/fees`, `http://localhost:8080/api/v1/payments`  
> **Database:** `finance_db` | **Naming Convention:** `snake_case` (Jackson globally configured)  
> **Special Requirement:** Requires user account to have role **`STUDENT`** (verified student account). Returns `403 Forbidden` otherwise.

---

## 1. Student Fees

### 1.1 List Fees
- **Method / Path:** `GET /api/v1/fees`
- **Auth:** Bearer JWT required (Role: `STUDENT`)
- **Headers:** `Authorization: Bearer <access_token>`

#### Response Schema (`200 OK`)
```json
{
  "data": [
    {
      "fee_id": "8d3e91b4-1029-4ab2-8cf0-5ecf479a9301",
      "category_id": "1b9a24cf-4001-49e2-9da2-a4e93bb59141",
      "category_name": "Tuition",
      "name": "Semester 1 Tuition Fee - Year 4",
      "amount": 1850.00,
      "currency": "USD"
    },
    {
      "fee_id": "7a2f80c3-0918-3ba1-7be9-4dba368a8290",
      "category_id": "2c0b35df-5002-50f3-aeb3-b5f04cc60252",
      "category_name": "Lab & Technology",
      "name": "Cloud Computing & AI Lab Access Fee",
      "amount": 120.00,
      "currency": "USD"
    }
  ]
}
```

---

### 1.2 List Fee Categories
- **Method / Path:** `GET /api/v1/fees/categories`
- **Auth:** Bearer JWT required (Role: `STUDENT`)

#### Response Schema (`200 OK`)
```json
{
  "data": [
    {
      "category_id": "1b9a24cf-4001-49e2-9da2-a4e93bb59141",
      "name": "Tuition",
      "description": "Academic semester course fees"
    },
    {
      "category_id": "2c0b35df-5002-50f3-aeb3-b5f04cc60252",
      "name": "Lab & Technology",
      "description": "Hardware and specialized software lab fees"
    }
  ]
}
```

---

## 2. Student Payments & Billing Alerts

### 2.1 Get Upcoming Payment Alerts
Displays banner warnings on the dashboard for fees that are upcoming or overdue.

- **Method / Path:** `GET /api/v1/payments/alerts`
- **Auth:** Bearer JWT required (Role: `STUDENT`)

#### Response Schema (`200 OK`)
```json
{
  "data": {
    "alerts": [
      {
        "payment_id": "f5e4d3c2-b1a0-4987-9876-543210fedcba",
        "fee_name": "Semester 1 Tuition Fee - Year 4",
        "due_date": "2026-09-30",
        "days_remaining": 16,
        "amount": 1850.00,
        "currency": "USD"
      }
    ]
  }
}
```

---

### 2.2 List Payment History
- **Method / Path:** `GET /api/v1/payments?page=1&limit=20`
- **Auth:** Bearer JWT required (Role: `STUDENT`)

#### Response Schema (`200 OK`)
```json
{
  "data": [
    {
      "payment_id": "f5e4d3c2-b1a0-4987-9876-543210fedcba",
      "fee_name": "Semester 1 Tuition Fee - Year 4",
      "amount": 1850.00,
      "currency": "USD",
      "status": "PENDING",
      "due_date": "2026-09-30",
      "paid_at": null
    },
    {
      "payment_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "fee_name": "Semester 2 Tuition Fee - Year 3",
      "amount": 1800.00,
      "currency": "USD",
      "status": "PAID",
      "due_date": "2026-03-15",
      "paid_at": "2026-03-10T14:20:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 6,
    "total_pages": 1
  }
}
```

`status` Enum values:
- `"PENDING"`
- `"PAID"`
- `"OVERDUE"`
- `"CANCELLED"`

---

### 2.3 Get Payment Receipt / Detail
- **Method / Path:** `GET /api/v1/payments/{paymentId}`
- **Auth:** Bearer JWT required (Role: `STUDENT`)

#### Response Schema (`200 OK`)
Returns single `PaymentResponse` in `{ "data": { ... } }`.
