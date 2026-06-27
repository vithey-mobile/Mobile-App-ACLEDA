# Notification Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `15` |
| Route | `Routes.NOTIFICATION` |
| Flutter module | `lib/modules/notification/` |
| Backend service(s) | `notification-service` |
| Auth required | Yes |

## Purpose

Show all in-app notifications for social, chat, payment, and job events.

## Open from

- Home app bar icon, bottom nav

## Notification types

| Type | Trigger |
|------|---------|
| LIKE | Someone liked your post |
| COMMENT | New comment |
| MENTION | @mentioned in comment |
| FOLLOW | New follower |
| CHAT_REQUEST | New message request |
| CHAT_MESSAGE | New message |
| PAYMENT_ALERT | Payment due soon |
| JOB_APPLICATION | New applicant |
| JOB_STATUS | Application status update |

## Main UI

| Element | Description |
|---------|-------------|
| Notification list | Icon, title, body, time, unread dot |
| Pull to refresh | Reload |
| Empty state | No notifications yet |
| Mark all read | Optional action |

## User actions

| Action | Result |
|--------|--------|
| Tap notification | Navigate to related screen |
| Swipe / tap | Mark as read |

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v1/notifications` | Paginated |
| GET | `/api/v1/notifications/unread-count` | Badge |
| PATCH | `/api/v1/notifications/{id}/read` | Mark read |

## Status checklist

- [ ] UX/UI designed
- [ ] Tap navigation per type
- [ ] Unread badge on Home
