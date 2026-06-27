# 12 - Chat Screen Prompt

Build the **Chat** module (conversation list + message requests) for Vithey App.

## Goal
Show private chat list, search users, and handle message requests (receiver must accept before full chat).

## Depends On
- `03-auth-prompt.md`

## Reuse From Core
- `UserAvatar`
- `AppAppBar`
- `CustomTextField` (search)
- `ShimmerListTile`
- `EmptyStateWidget`
- `ConfirmDialog`

## Module Files
```text
lib/modules/chat/
  chat_screen.dart
  chat_controller.dart
  chat_binding.dart
  widgets/
    chat_list_item.dart
    message_request_card.dart
    search_user_box.dart

lib/data/models/chat_model.dart
lib/data/repositories/chat_repository.dart
lib/data/services/chat_service.dart
```

## Screen Spec
| Item | Detail |
|------|--------|
| Main UI | Chat list, search, message requests section |
| Privacy | Receiver accepts request before active chat |
| Safety | Block and report user |
| API | `GET /conversations`, accept/decline request endpoints |
| Nav | Tap chat → Chat Detail |

## Controller Logic
- `fetchConversations()` — active chats
- `fetchMessageRequests()` — pending requests
- `acceptRequest(id)`, `declineRequest(id)`
- `searchUsers(query)` — debounced
- `blockUser(userId)`, `reportUser(userId)` with `ConfirmDialog`
- Badge count for pending requests

## UI Requirements
- Top: `search_user_box` composes `CustomTextField`
- Section **Message Requests** with horizontal or vertical `message_request_card` list
- Section **Chats** with `chat_list_item` (avatar, name, last message, time, unread dot)
- Long-press or menu: block/report
- FAB optional for new message → search

## Widget Rules
- `chat_list_item` pattern similar to notification item — if structure matches, extract `lib/core/widgets/list_tile_with_avatar.dart` later

## Route Registration
Add `Routes.CHAT`

## Output
Chat list with request handling and navigation to detail.
