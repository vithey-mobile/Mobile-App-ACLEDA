# GLM 5.3 Flash — Terminal 8 / 10 — notification-service

Copy everything below the line into a **new** GLM chat. Run in parallel with the other 9. Do not edit other services.

---

You are GLM 5.3 Flash on Vithey App. Work **only** `notification-service`.

## Read first

- `prompt/Prompt Backend/LEARNING.md`
- `prompt/Prompt Backend/services/notification-service/UPGRADE_FOR_UI.md` (**implement this**)
- `prompt/Prompt Backend/services/notification-service/API_ENDPOINTS.md`
- Live code: `backend/services/notification-service/`

## Identity

Port **8088** · Eureka `notification-service` · DB `notification_db` · package `com.vithey.notification`

## Allowed paths

```text
backend/services/notification-service/**
prompt/Prompt Backend/services/notification-service/**
```

Do **not** edit POM, gateway, Flutter, or other services.

## Job (upgrade — code is behind the spec)

Implement `UPGRADE_FOR_UI.md` if still missing in Java:

| Method | Path |
|--------|------|
| GET | `/api/v1/notifications?page=&limit=&is_read=` |
| GET | `/api/v1/notifications/unread-count` |
| PATCH | `/api/v1/notifications/{id}/read` |
| PATCH | `/api/v1/notifications/read-all` |
| DELETE | `/api/v1/notifications/{id}` → **204** owner-only |
| POST/DELETE | `/api/v1/notifications/devices` (keep) |

List item must include `actor`, `destination`, `event`, `dedupe_key`, `read_at`.  
List `meta` must include `unread_total`.

Add Flyway only if columns are missing. Keep RabbitMQ consumers. Do not rewrite FCM unless broken.

## Verify

- Test: `is_read=false` filter; delete owner-only
- `mvn -pl services/notification-service -am test` from `backend/`

Print files changed. Stop.
