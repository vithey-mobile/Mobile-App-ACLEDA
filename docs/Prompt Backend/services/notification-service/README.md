# Notification Service — Prompt Index

Upgrade **notification-service** to power the Facebook-style Notification Center UI.

## Visual / product reference (frontend)

| Asset | Path |
|-------|------|
| Notification inbox UI | `Prompt Frontend/screen image/notification/notification.png` |
| Frontend spec index | `Prompt Frontend/Screen prompt/notification/README.md` |
| REST + FCM contract (Flutter) | `Prompt Frontend/Screen prompt/notification/05.notification_api_backend.md` |

## Architecture (from backend plan)

```text
content / career / finance / chat / ai services
        │ publish domain events
        ▼
   RabbitMQ (Kafka-compatible naming)
        │
        ▼
notification-service :8088
├── PostgreSQL notification_db
├── Redis (optional unread cache)
└── Firebase Admin SDK → FCM
        │
        ▼
API Gateway /api/v1/notifications/**
        │
        ▼
Flutter Notification Center + Home bell badge
```

## Reading order (backend)

| # | Document | Purpose |
|---|----------|---------|
| 0 | [`../../COMMON_CONTEXT.md`](../../COMMON_CONTEXT.md) | Platform-wide rules |
| 1 | [`COMMON_CONTEXT.md`](COMMON_CONTEXT.md) | Service identity |
| 2 | **[`UPGRADE_FOR_UI.md`](UPGRADE_FOR_UI.md)** | **UI upgrade spec — start here if upgrading** |
| 3 | [`API_ENDPOINTS.md`](API_ENDPOINTS.md) | Canonical REST paths |
| 4 | [`DB_SCHEMA.md`](DB_SCHEMA.md) | Tables + V2 migration |
| 5 | [`SERVICE_LOGIC.md`](SERVICE_LOGIC.md) | Event mapping + flows |
| 6 | [`SERVICE_PROMPT.md`](SERVICE_PROMPT.md) | Full implementation scaffold |
| 7 | [`FOLDER_STRUCTURE.md`](FOLDER_STRUCTURE.md) | Java package layout |

## What the new UI requires (summary)

| UI feature | Backend deliverable |
|------------|---------------------|
| All / Unread filter chips | `GET /notifications?is_read=false` server-side |
| Grouped inbox (New / Today / Earlier) | `created_at` + `is_read` in list DTO; grouping is client-side |
| Actor avatar + type badge | `actor` object on every row |
| Row tap deep link | Structured `destination` object (not only `reference_id`) |
| Mark read / Delete | `PATCH /{id}/read`, `DELETE /{id}` |
| Home bell badge | `GET /unread-count` + optional Redis cache |
| Push tap → same destination | FCM `data` map mirrors REST `destination` |
| 9 notification categories | Extended `type` + `event` enum (see upgrade doc) |
| No duplicate rows on retry | `dedupe_key` unique per user |

## Definition of done (UI upgrade)

- [ ] V2 schema applied (actor, event, dedupe_key, destination JSON)
- [ ] All endpoints in `UPGRADE_FOR_UI.md` implemented
- [ ] Every event in event table creates correct notification + FCM payload
- [ ] `is_read` filter works with pagination
- [ ] Delete removes single row; owner-only
- [ ] FCM payload matches Flutter `NotificationRouter` parser
- [ ] Gateway routes documented in `api-gateway/API_ENDPOINTS.md`
- [ ] Integration contract updated
- [ ] Postman/OpenAPI examples for inbox list + unread filter

## Output

Implement or upgrade **notification-service** following **`UPGRADE_FOR_UI.md`**, then verify against frontend acceptance checklist in `Screen prompt/notification/README.md`.
