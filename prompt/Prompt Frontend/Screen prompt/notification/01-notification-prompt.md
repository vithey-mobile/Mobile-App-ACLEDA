# 14N — Notifications (Legacy Index)

> **This file has been split into a full prompt suite.** Use the index below instead.

## Start here

**[`README.md`](README.md)** — Facebook-style notification system master index.

## Reading order

| # | Prompt | Topic |
|---|--------|-------|
| 1 | [`01.notification_center.md`](01.notification_center.md) | Inbox UI, filters, grouping, action sheet |
| 2 | [`02.notification_types_routing.md`](02.notification_types_routing.md) | 9 notification types, icons, deep links |
| 3 | [`03.notification_fcm_local.md`](03.notification_fcm_local.md) | Firebase Messaging + flutter_local_notifications |
| 4 | [`04.notification_isar_offline.md`](04.notification_isar_offline.md) | Isar offline cache |
| 5 | [`05.notification_api_backend.md`](05.notification_api_backend.md) | REST API, RabbitMQ events, Firebase Admin |
| 6 | [`06.notification_page_redesign.md`](06.notification_page_redesign.md) | Card-style visual redesign of the inbox |

## Quick summary

Build a **Facebook-style notification center** with:

- **9 types:** message, like, comment, share, follower, job application, payment, AI response, system
- **FCM** for push + **`flutter_local_notifications`** for OS tray
- **Social feed** events → RabbitMQ → notification-service → FCM → inbox
- **Chat** realtime via WebSocket; chat alerts via FCM when backgrounded
- **Backend:** Spring Boot, PostgreSQL, Redis, Firebase Admin SDK

The original monolithic spec content is preserved across prompts 01–05.
