# 14N - Notifications Prompt

Build a complete **Notifications** module for Vithey in Flutter, matching the supplied reference and showing all relevant social, sharing, job/CV, chat, finance, and system activity.

Every notification row has an ellipsis menu. Tapping it opens a compact sheet that slides **from the bottom upward** with actions to mark that notification as read and delete **only that selected notification**.

## Visual reference

- `Prompt Frontend/screen image/notification/notification.png`
- Treat the image as the source of truth for the app bar, All/Unread filters, New grouping, avatar/type badges, unread dots, ellipsis actions, timestamps, and compact list density.
- Use Vithey content/types rather than hard-coded fixture names/events.

## Quick info

| Field | Value |
|---|---|
| Screen ID | `14N` |
| Route | `Routes.NOTIFICATION` |
| Flutter module | `lib/modules/notification/` |
| Backend service | `notification-service` |
| Auth required | Yes |
| Entry points | Home bell, push notification, app deep link |

## Goal

Show a paginated, real-time-aware notification inbox where the user can:

- View all notifications.
- Filter to unread notifications.
- Open the related post, profile, comment, chat, payment, job, application, or verification screen.
- Mark a selected notification as read.
- Delete only a selected notification after confirmation.
- Keep the global unread badge synchronized across Home and the app shell.

## Screen composition

### 1. App bar

Match `notification.png`:

- White/light background.
- Left-aligned bold title: **Notifications**.
- Right actions:
  - Search icon when notification search is implemented.
  - Settings gear opening notification preferences.
- Respect `SafeArea` and provide at least `44 × 44` logical-pixel targets.
- If search is not implemented, hide the icon rather than showing a dead action.

### 2. Filter chips/tabs

Immediately below the app bar:

- **All** — selected by default in the reference.
- **Unread**.
- Selected chip uses a pale teal/blue background and stronger text.
- Switching filters preserves each list's pagination/cache/scroll position when practical.
- Unread filtering must be server-backed. Do not filter only the currently loaded All page and claim it contains all unread items.

### 3. Group header

- Display **New** for recent/unread activity, matching the reference.
- Optional right action **See all** only when it has a defined purpose, such as expanding a collapsed New section; do not duplicate the All filter.
- For a full inbox, group by clear date sections such as **New**, **Today**, **Yesterday**, and **Earlier**, based on server timestamps and the user's timezone.

### 4. Notification list

- Use a lazy, paginated vertical list.
- Preserve server ordering, normally newest first.
- De-duplicate by stable `notificationId`.
- Each row is independently actionable and has its own mutation state.

## Notification row design

Match the reference structure:

- Left: actor avatar or type-specific icon.
- Small overlaid circular type badge, for example heart, comment, share, person, briefcase, CV, chat, or payment.
- Center:
  - Human-readable notification text with actor/job/post name emphasized when structured data permits.
  - Relative time below, e.g. **2 minutes ago**.
- Right:
  - Blue/teal unread dot when `isRead == false`.
  - Ellipsis (`…`) button.
- Unread rows may use a subtle tinted background or stronger text; read rows use neutral styling.
- The whole main row opens its destination, except the ellipsis and any inline contextual action.

Do not render server title/body as arbitrary HTML. Prefer structured display data and safe plain/attributed text.

## Supported notification types

Use a typed enum with explicit routing, icons, and copy.

| Frontend type | Trigger/recipient | Tap destination |
|---|---|---|
| `POST_LIKE` | Someone liked user's poster/video/job | Post Detail |
| `POST_COMMENT` | Someone commented on user's post | Post Detail or Home comment sheet for that post/comment |
| `POST_MENTION` | User mentioned in a comment | Post/comment target |
| `POST_SHARE` | Someone publicly shared user's post | Shared/original Post Detail |
| `NEW_FOLLOWER` | Someone followed user | Actor Profile |
| `JOB_APPLICATION_RECEIVED` | Someone applied with CV to user's job | Owned job's Application Detail/Applicants list |
| `JOB_APPLICATION_STATUS` | User's application accepted/rejected/reviewed | My Application Detail |
| `CHAT_REQUEST` | New message request | Message Requests |
| `CHAT_MESSAGE` | New message | Chat Detail |
| `PAYMENT_DUE` | Payment due soon | Finance/payment detail |
| `PAYMENT_OVERDUE` | Payment overdue | Finance/payment detail |
| `STUDENT_VERIFICATION` | Verification status changed | Verification Status |
| `SYSTEM` | Service/product notice | Approved internal destination or detail |

The current backend uses broad types such as `LIKE`, `COMMENT`, `FOLLOW`, `CHAT`, `PAYMENT`, and `JOB`. Normalize them in the repository, but extend the backend payload with subtypes/event names where one broad type has multiple destinations.

## Like, share, and Apply CV notifications

### Like

- Created from `reaction.added` for the post author.
- Copy example: **{actor} liked your poster.**
- `referenceType=POST`, `referenceId=postId`.
- Do not notify a user for liking their own post.

### Share

- Created only for a real public reshare, not a private save/bookmark.
- Copy example: **{actor} shared your post.**
- Private **Save this post** actions from Home must never notify the author.
- The current content/notification contracts do not define `post.shared`; add a deduplicated share event and `POST_SHARE` mapping before enabling this type.

### Apply CV received

- Created from `job.application.submitted` for the job owner.
- Copy example: **{applicant} applied for {job title}.**
- Tap opens the authorized application detail or applicants list using `applicationId` and `jobPostId`.
- Never include a public CV URL, sensitive document contents, student ID, or private contact details in title/body/push payload.

### Application status update

- Created from `job.application.status_changed` for the applicant.
- Copy examples:
  - **Your application for {job title} is under review.**
  - **Your application for {job title} was accepted.**
  - **Your application for {job title} was not selected.**
- Tap opens the current user's application detail, not the job owner's applicant-management route.

## Row tap behavior

1. Optimistically mark the selected notification read if it is unread.
2. Update global unread count once.
3. Route by typed destination and stable IDs.
4. Reconcile mark-read response; rollback unread state/count if it fails, unless navigation policy intentionally keeps it read locally pending retry.
5. If the target was deleted/unavailable, keep the notification read and show **This content is no longer available**.

Tapping the ellipsis must not mark the notification read and must not trigger row navigation.

## Bottom-up notification action sheet

Tapping a row's `…` opens a compact modal sheet for that exact notification.

### Presentation

- Slides upward from the bottom and remains anchored/sticky to the bottom edge.
- White surface with rounded top corners.
- Centered short drag handle.
- Dimmed modal barrier behind it.
- Optional compact preview/title of the selected notification.
- Respects bottom safe area and large text.
- Dismiss with swipe down, outside tap, close semantics, or system Back.
- Preserve notification-list scroll position.

### Actions

1. **Mark as read**
   - Leading check/read icon.
   - Show and enable only when the selected notification is unread.
   - If already read, hide it or show a non-action **Already read** state; do not send duplicate requests.
2. **Delete notification**
   - Leading trash icon.
   - Red/destructive styling.
   - Targets only the selected `notificationId`.

The sheet receives an immutable selected-notification snapshot/ID. It must never use a list index because pagination/reordering can change indices while the sheet is open.

## Mark selected notification as read

On **Mark as read**:

1. Prevent duplicate mutation for that ID.
2. Optimistically set `isRead=true` in All and Unread caches.
3. Remove it from the visible Unread list with an accessible animation, if that filter is active.
4. Decrement global unread count once, never below zero.
5. Call `PATCH /api/v1/notifications/{notificationId}/read`.
6. On success, close the sheet and reconcile server state/count.
7. On failure, rollback the row and count, keep/reopen actionable UI, and show Retry.

Marking a notification read does not modify the underlying post, share, application, CV, chat, or payment.

## Delete only the selected notification

Tapping **Delete notification** opens a confirmation dialog:

- Title: **Delete notification?**
- Message: **This removes only this notification from your list. The related post, application, message, or payment will not be deleted.**
- Actions:
  - **Cancel**.
  - Red **Delete**.
- Outside tap must not confirm deletion.

On confirmation:

1. Capture the exact `notificationId`.
2. Prevent duplicate delete requests.
3. Call the documented owner-only delete endpoint.
4. Remove only that ID from All, Unread, grouped sections, and caches after success, or optimistically with reliable rollback.
5. If the deleted item was unread, decrement global unread count exactly once.
6. Leave every other notification unchanged.
7. Close dialog/sheet and return focus near the removed row.
8. On failure, keep/restore the item and show Retry.

Deletion removes only the inbox record. It must never delete the referenced content, share, job application, CV, chat, payment, user, or push event history outside the notification retention contract.

## Contextual inline actions

The reference shows actions such as Confirm/Delete for friend requests. Vithey may show type-specific inline actions only when fully supported, for example Accept/Decline message request. These controls:

- Must use the underlying domain endpoint, not notification mutation endpoints.
- Must stop row navigation.
- Must update notification state after domain success.
- Must not be added for likes/shares merely for visual parity.

## Pagination, refresh, and live updates

- Pull to refresh from the current filter.
- Load next page near list end with footer spinner.
- Preserve loaded rows on pagination error and show footer Retry.
- Foreground FCM/in-app events upsert by `notificationId` or dedupe key at the top.
- Background notification taps first hydrate/authenticate, fetch authoritative notification/target if needed, mark read, and route once.
- Avoid duplicates when the same event arrives through FCM and subsequent REST refresh.
- Keep global unread badge synchronized through one shared notification store.

## Unread count

- Fetch `GET /api/v1/notifications/unread-count` on app/session start, resume, and after uncertain reconciliation.
- Optimistically adjust for mark-read/delete but periodically reconcile with server.
- Never let the badge become negative.
- Cap display such as `99+` while preserving the full semantic count.
- Clear user-scoped count/cache on logout/account switch.

## Current API

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/api/v1/notifications?page&limit` | Paginated All list |
| `GET` | `/api/v1/notifications/unread-count` | Global unread badge |
| `PATCH` | `/api/v1/notifications/{id}/read` | Mark one owned item read |
| `PATCH` | `/api/v1/notifications/read-all` | Mark all read, if exposed elsewhere |
| `POST` | `/api/v1/notifications/devices` | Register FCM token |
| `DELETE` | `/api/v1/notifications/devices/{token}` | Remove device token |

## Required backend contract extensions

1. Add an owner-only endpoint to delete one notification, conceptually `DELETE /notifications/{notificationId}`. Do not confuse it with device-token deletion.
2. Add server-backed Unread filtering/pagination, e.g. a documented filter query. Client-only filtering of loaded pages is incomplete.
3. Add structured actor summary (`actorId`, display name, avatar) or safe display metadata for the reference row design.
4. Add precise event subtype plus destination payload IDs, especially for received application vs applicant status update.
5. Add public-share event/type mapping. Private saves produce no notification.
6. Define event dedupe key/idempotency so FCM and REST do not duplicate rows.
7. Define deletion retention/audit behavior and `404` idempotent reconciliation.
8. Define deep-link versioning/fallback for deleted targets.

Suggested typed repository boundaries:

```dart
Future<Paginated<AppNotification>> getNotifications({
  required NotificationFilter filter,
  required PageRequest page,
});

Future<AppNotification> markRead(String notificationId);
Future<void> deleteNotification(String notificationId);
Future<int> getUnreadCount();
```

Do not silently invent production URLs. Feature-gate Delete until the owner-only endpoint exists.

## Notification model

Use structured fields:

```dart
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final NotificationActor? actor;
  final NotificationDestination destination;
  final bool isRead;
  final DateTime createdAt;
  final String? dedupeKey;
}
```

`NotificationDestination` is a sealed/typed model containing only needed stable IDs. Do not route by parsing title/body strings.

## Empty, loading, and errors

- Initial loading: 6–8 skeleton notification rows.
- All empty: **No notifications yet**.
- Unread empty: **You’re all caught up**.
- Initial error: full/inline Retry.
- Pagination error: footer Retry with loaded list retained.
- Mark-read failure: rollback selected row/count.
- Delete failure: selected row remains/restores; no other item changes.
- Target missing: content-unavailable message, inbox remains usable.
- `401`: global token refresh/reauthentication while preserving destination IDs.
- Malformed/unknown type: safe generic System notification or skip/report; never crash the list.

## Push notification integration

- Request OS notification permission contextually, not on first frame without explanation.
- Register/upsert FCM token with platform.
- Remove token on logout where appropriate.
- Push payload contains no CV file URL, payment details, message secrets, or excessive personal data.
- Foreground push updates the in-app list/badge once.
- Background/dead-app tap validates ownership/auth and resolves the latest destination safely.

## Accessibility and responsive behavior

- Label title, filters, unread count, each row/type/time, unread state, ellipsis, sheet actions, confirmation, and errors.
- Announce read/delete success without excessive chatter.
- Do not rely only on blue dots/color for unread state.
- Ensure `44 × 44` targets for rows, ellipsis, filters, and sheet actions.
- Support `320 px`, large text, long names/job titles, screen readers, keyboard traversal, and reduced motion.
- Trap focus in modal sheet/dialog and return it to the originating ellipsis or logical next row.

## Architecture

```text
lib/modules/notification/
  notification_screen.dart
  notification_controller.dart
  notification_binding.dart
  widgets/
    notification_app_bar.dart
    notification_filter_bar.dart
    notification_group.dart
    notification_item.dart
    notification_type_badge.dart
    notification_action_sheet.dart
    delete_notification_dialog.dart
    notification_empty_state.dart

lib/data/models/
  app_notification_model.dart
  notification_actor_model.dart
  notification_destination.dart

lib/data/services/
  notification_service.dart

lib/data/repositories/
  notification_repository.dart
```

- Maintain one user-scoped normalized store keyed by notification ID.
- All/Unread/grouped views derive from the same normalized entities plus server page IDs.
- Keep routing maps and mutations out of row widgets.
- Share unread badge state with Home app bar/app shell.

## Controller responsibilities

- `loadNotifications(filter)` / `loadMore(filter)`.
- `refreshNotifications(filter)`.
- `selectFilter(filter)`.
- `openNotification(notificationId)`.
- `openActionSheet(notificationId)`.
- `markAsRead(notificationId)`.
- `requestDelete(notificationId)` / `confirmDelete(notificationId)`.
- `upsertPushNotification(payload)`.
- `reconcileUnreadCount()`.
- Route typed destinations and handle missing targets.
- Ignore stale pagination/mutation results after filter/account changes.

## Navigation mapping

| Type | Destination |
|---|---|
| Like / Comment / Mention / Share | Post or comment target |
| Follow | Actor Profile |
| Job application received | Owner-only Application Detail/Applicants |
| Job application status | Applicant's My Application Detail |
| Chat request | Message Requests |
| Chat message | Chat Detail |
| Payment | Finance/payment detail |
| Verification | Verification Status |

## Testing and acceptance criteria

- Screen matches `notification.png`: title/actions, All/Unread chips, New grouping, avatar/type badges, relative times, unread dots, and ellipsis controls.
- Lists likes, shares, comments, follows, CV applications, application status, chat, payment, verification, and safe system events when delivered.
- Tapping a row marks only that item read and opens the correct typed destination.
- Tapping ellipsis never opens the row or marks it read.
- Ellipsis opens a rounded sticky sheet sliding bottom-to-top with Mark as read and Delete notification.
- Mark as read updates only the selected ID across caches and decrements unread count once.
- Delete always confirms and removes only the selected notification ID—not all notifications or referenced domain data.
- Delete/mark-read failures rollback only the affected item.
- Public shares notify; private saves never notify.
- Apply-CV notifications route job owner to authorized applicant/application detail without exposing the CV in push payload.
- All/Unread pagination is server-backed, deduplicated, refreshable, and reconciles FCM/REST events.
- Loading, empty, pagination error, missing target, malformed type, offline cache, auth expiry, push foreground/background, and account-switch clearing are tested.
- No overflow occurs on small screens, large text, long notification copy, or modal actions.

## Dependencies

- `00-foundation-prompt.md`
- `media/01-home-prompt.md`
- `../upload_cv/01.upload_cv.md`
- `profile/01.profile_home.md`
- `finance/02.pending_verify.md`
- `Prompt Frontend/api-intergration/integration-contract.md`
- `Prompt Backend/services/notification-service/SERVICE_PROMPT.md`
- `Prompt Backend/services/content-service/SERVICE_PROMPT.md`
- `Prompt Backend/services/career-service/SERVICE_PROMPT.md`
- `Prompt Backend/services/chat-service/SERVICE_PROMPT.md`
- `Prompt Backend/services/finance-service/SERVICE_PROMPT.md`

## Output

Deliver a secure, responsive notification inbox with complete social/share/job/CV routing, All and Unread lists, synchronized badge state, and a per-item bottom-up action sheet that marks or deletes only the selected notification.
