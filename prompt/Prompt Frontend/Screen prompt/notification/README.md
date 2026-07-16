# Notifications — Facebook-Style Notification Center Prompt Index

Complete specification for a **Facebook-style notification system** in Vithey App.

## Product goal

Deliver a production-quality notification experience comparable to **Facebook / Meta**:

- Grouped notification inbox (New, Today, Earlier)
- Actor avatar + type badge on every row
- All / Unread filters with server-backed pagination
- Global unread badge on Home bell icon
- **Firebase Cloud Messaging** for push delivery
- **`flutter_local_notifications`** for OS tray display when app is backgrounded
- Tap notification → deep-link to post, profile, chat, job, payment, AI thread, or system detail
- **Backend-ready** — mock today, Spring Boot + PostgreSQL + Redis + Firebase Admin SDK tomorrow

## Visual reference

| Screen | Asset |
|--------|-------|
| Notification center | `Prompt Frontend/screen image/notification/notification.png` |
| Notification page redesign | `Prompt Frontend/screen image/notification/notification_page.png` |

## Technology stack (mandatory)

| Layer | Package / Tech | Role |
|-------|----------------|------|
| UI | `shadcn_flutter ^0.0.52` | Action sheet, delete dialog, filter chips |
| UI | Material 3 + semantic colors | List, badges, unread dots |
| REST | **Dio** | Inbox list, mark read, delete, unread count, device token |
| Push receive | **`firebase_messaging`** | Foreground/background/terminated push |
| Push display | **`flutter_local_notifications`** | Show tray notification + tap channel |
| Local DB | **Isar** *(recommended)* | Offline inbox cache, dedupe by `notificationId` |
| State | **GetX** | Controllers, routing, shared unread badge |

### End-to-end architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│                        SOCIAL FEED (content-service)             │
│   Like ──► reaction.added                                        │
│   Comment ──► comment.added                                      │
│   Follow ──► follow.created                                      │
│   Share ──► post.shared (public reshare only)                    │
└────────────────────────────┬────────────────────────────────────┘
                             │ RabbitMQ events
┌────────────────────────────┼────────────────────────────────────┐
│  CAREER / FINANCE / CHAT / AI services                           │
│   job.application.submitted / status_changed                     │
│   payment.due / payment.overdue                                  │
│   chat.message.sent / chat.request.received                      │
│   ai.response.ready (planned)                                    │
└────────────────────────────┬────────────────────────────────────┘
                             ▼
              notification-service (Spring Boot :8088)
              ├── PostgreSQL — notification rows, device tokens
              ├── Redis — unread count cache (optional)
              └── Firebase Admin SDK — send FCM data message
                             │
                             ▼
              Firebase Cloud Messaging
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                         FLUTTER APP                              │
│   firebase_messaging ──► FcmService                            │
│   flutter_local_notifications ──► LocalNotificationService       │
│   NotificationRouter ──► deep link by type + IDs                 │
│   NotificationRepository ──► REST sync + Isar cache              │
│   Notification Center UI ──► inbox list + badge                  │
└─────────────────────────────────────────────────────────────────┘

CHAT (parallel realtime path — in-app only)
   WebSocket STOMP ──► ChatStompService (live thread)
   chat.message.sent ──► FCM when recipient app backgrounded
```

> **Rule:** Social events never open chat via WebSocket. Chat realtime is STOMP; chat **alerts** use FCM → Notification Center or direct deep link.

## Supported notification types

| # | User-facing type | Frontend enum | Backend type / event |
|---|------------------|---------------|----------------------|
| 1 | New message | `chatMessage` | `CHAT` / `chat.message.sent` |
| 2 | Like post | `postLike` | `LIKE` / `reaction.added` |
| 3 | Comment | `postComment` | `COMMENT` / `comment.added` |
| 4 | Share post | `postShare` | `POST_SHARE` / `post.shared` *(planned)* |
| 5 | New follower | `newFollower` | `FOLLOW` / `follow.created` |
| 6 | Job application | `jobApplicationReceived`, `jobApplicationStatus` | `JOB` / `job.application.*` |
| 7 | Payment notification | `paymentDue`, `paymentOverdue` | `PAYMENT` / `payment.due` |
| 8 | AI assistant response | `aiAssistantResponse` | `AI` / `ai.response.ready` *(planned)* |
| 9 | System announcement | `system` | `SYSTEM` / `system.announcement` |

Also supported (existing Vithey): `postMention`, `chatRequest`, `studentVerification`.

## Reading order

| # | Prompt | Delivers |
|---|--------|----------|
| 1 | [`01.notification_center.md`](01.notification_center.md) | Facebook-style inbox UI, filters, row design, action sheet |
| 2 | [`02.notification_types_routing.md`](02.notification_types_routing.md) | All 9 types — copy, icons, badges, deep-link map |
| 3 | [`03.notification_fcm_local.md`](03.notification_fcm_local.md) | FCM + flutter_local_notifications setup & handlers |
| 4 | [`04.notification_isar_offline.md`](04.notification_isar_offline.md) | Isar schema, cache, dedupe, offline badge |
| 5 | [`05.notification_api_backend.md`](05.notification_api_backend.md) | REST contract, events, Firebase Admin payload |
| 6 | [`06.notification_page_redesign.md`](06.notification_page_redesign.md) | Card-style visual redesign — segmented pill, day groups, accent-bar cards |

## Feature matrix

| Feature | UI | Isar | REST | FCM | Local notifications |
|---------|----|------|------|-----|---------------------|
| Notification list | `01` | ✅ cache | `GET /notifications` | upsert on push | — |
| All / Unread filter | `01` | filter local | server `?read=false` | — | — |
| Unread badge (Home) | `01` | count | `GET /unread-count` | increment | — |
| Actor avatar + badge | `01`, `02` | snapshot | in DTO | — | large icon |
| Mark one read | `01` | ✅ | `PATCH /{id}/read` | — | — |
| Delete one | `01` | ✅ | `DELETE /{id}` *(planned)* | — | — |
| **App bar search** | `01` | — | — | — | — → `AppRoutes.search` (global search) |
| Tap row → navigate | `02` | — | — | tap payload | tap payload |
| Foreground push | — | upsert | reconcile | `onMessage` | show heads-up |
| Background push | — | — | fetch on open | `onMessageOpenedApp` | tray |
| Terminated tap | — | — | hydrate | `getInitialMessage` | tray |
| Register FCM token | — | — | `POST /devices` | `getToken()` | — |
| Chat message alert | `02` | — | — | data payload | channel `chat` |
| AI response alert | `02` | — | — | data payload | channel `ai` |

## Module architecture (target)

```text
lib/modules/notification/
  notification_screen.dart
  notification_controller.dart
  notification_binding.dart
  widgets/
    notification_filter_bar.dart
    notification_group_header.dart
    notification_item.dart
    notification_type_badge.dart
    notification_action_sheet.dart
    delete_notification_dialog.dart
    notification_empty_state.dart

lib/data/
  local/isar/
    local_notification.dart
    notification_isar_mapper.dart
  models/
    app_notification_model.dart
    notification_destination.dart
  repositories/
    notification_repository.dart
  services/
    notification_service.dart          # Dio REST
  push/
    fcm_service.dart                 # firebase_messaging
    local_notification_service.dart  # flutter_local_notifications
    notification_router.dart         # tap → typed route
    notification_channels.dart       # Android channels per type group
```

## Current codebase baseline

Extend these existing files — do not rewrite from scratch:

- `lib/modules/notification/notification_screen.dart`
- `lib/modules/notification/notification_controller.dart`
- `lib/modules/notification/widgets/notification_item.dart`
- `lib/modules/notification/widgets/notification_action_sheet.dart`
- `lib/data/models/app_notification_model.dart`
- `lib/data/repositories/notification_repository.dart`
- `lib/data/push/fcm_service.dart` *(stub — implement in prompt 03)*

## Environment variables

```env
FCM_ENABLED=true
# Android: google-services.json in android/app/
# iOS: GoogleService-Info.plist in ios/Runner/
```

## Acceptance checklist (release gate)

- [ ] Inbox matches `notification.png` — filters, grouping, avatar badges, unread dots
- [ ] All 9 notification types render with correct icon, copy, and tap destination
- [ ] Foreground FCM updates list + badge without duplicate rows
- [ ] Background/terminated tap opens correct screen with auth check
- [ ] `flutter_local_notifications` shows tray on Android + iOS
- [ ] Mark read / delete affects only selected notification ID
- [ ] Global Home bell badge syncs with server `unread-count`
- [ ] Chat message push deep-links to `ChatDetail(conversationId)`
- [ ] AI response push deep-links to `Chatbot` thread *(when AI route exists)*
- [ ] No CV URLs, payment secrets, or message body in push payload
- [ ] Isar shows cached inbox when offline
- [ ] `flutter analyze` zero errors

## Output

Implement the full Facebook-style notification system by following prompts **01 → 05** in order. Keep GetX + Clean Architecture: widgets compose UI; controllers orchestrate; repository coordinates REST + FCM + Isar + local notifications.

## Dependencies

- `Prompt Frontend/COMMON_CONTEXT.md`
- `Prompt Frontend/api-intergration/integration-contract.md`
- `Prompt Backend/services/notification-service/UPGRADE_FOR_UI.md` — **backend upgrade spec (start here for Spring Boot)**
- `Prompt Backend/services/notification-service/SERVICE_PROMPT.md`
- `Screen prompt/media/01-home-prompt.md` (bell entry)
- `Screen prompt/chat/05.chat_api_realtime.md` (chat FCM overlap)
- `Screen prompt/chatbot/README.md` (AI response destination)
