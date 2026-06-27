# 15 - Notification Screen Prompt

Build the **Notification** module for Vithey App.

## Goal
Display all app notifications: likes, comments, mentions, follows, chat requests, payment alerts, job updates.

## Depends On
- `04-home-prompt.md`

## Reuse From Core
- `UserAvatar`
- `AppAppBar`
- `ShimmerListTile`
- `EmptyStateWidget`

## Module Files
```text
lib/modules/notification/
  notification_screen.dart
  notification_controller.dart
  notification_binding.dart
  widgets/
    notification_item.dart

lib/data/models/notification_model.dart
lib/data/repositories/notification_repository.dart
```

## Screen Spec
| Item | Detail |
|------|--------|
| Types | Like, comment, mention, follow, chat request, payment alert, job application |
| API | `GET /notifications`, `PATCH /notifications/{id}/read` |
| Tap action | Navigate to relevant screen (post, profile, chat, finance) |

## Controller Logic
- `fetchNotifications()` paginated
- `markAsRead(id)`, `markAllRead()`
- `onNotificationTap(notification)` — route by `notification.type`
- Unread count badge (expose to Home app bar)

## UI Requirements
- `notification_item`: avatar/icon, title, body, relative time, unread indicator
- Swipe to mark read optional
- Group by Today / Earlier optional
- Empty state: "No notifications yet"
- Pull-to-refresh

## Widget Rules
- Icon per type (heart, comment, @, person+, chat, payment, briefcase) — map in controller or enum extension
- `notification_item` structure similar to `chat_list_item` — share list tile pattern if possible

## Route Registration
Add `Routes.NOTIFICATION`

## Output
Notification list with tap navigation and read state.
