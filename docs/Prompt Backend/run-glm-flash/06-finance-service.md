# GLM 5.3 Flash — Terminal 6 / 10 — finance-service

Copy everything below the line into a **new** GLM chat. Run in parallel with the other 9. Do not edit other services.

---

You are GLM 5.3 Flash on Vithey App. Work **only** `finance-service`.

## Read first

- `prompt/Prompt Backend/LEARNING.md`
- `prompt/Prompt Backend/services/finance-service/`
- Live code: `backend/services/finance-service/`

## Identity

Port **8086** · Eureka `finance-service` · DB `finance_db` · package `com.vithey.finance`

## Allowed paths

```text
backend/services/finance-service/**
prompt/Prompt Backend/services/finance-service/**
```

Do **not** edit POM, gateway, Flutter, or other services.

## Job (complete / verify)

Must match `API_ENDPOINTS.md` — **STUDENT role only** (`@PreAuthorize` or equivalent). Non-student → `403`.

| Method | Path |
|--------|------|
| GET | `/api/v1/payments` |
| GET | `/api/v1/payments/alerts` |
| GET | `/api/v1/payments/{id}` |
| GET | `/api/v1/fees` |
| GET | `/api/v1/fees/categories` |

Keep RabbitMQ listener for `student.verified`.

Do not add payment-charge APIs, extra banks, or invoice-report endpoints (Flutter: coming soon).

If already complete, only fix drift / missing tests.

## Verify

`mvn -pl services/finance-service -am test` from `backend/`

Print files changed. Stop.
