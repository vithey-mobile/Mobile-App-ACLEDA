# 13 - Chat Detail Screen Prompt

Build the **Chat Detail** module for Vithey App.

## Goal
Real-time or polling-based private messaging with sent/delivered/read status and block option.

## Depends On
- `12-chat-prompt.md`

## Reuse From Core
- `UserAvatar`
- `AppAppBar`
- `CustomTextField`
- `ConfirmDialog`

## Module Files
```text
lib/modules/chat_detail/
  chat_detail_screen.dart
  chat_detail_controller.dart
  chat_detail_binding.dart
  widgets/
    message_bubble.dart
    message_input.dart
    read_status.dart

lib/data/models/message_model.dart
```

## Screen Spec
| Item | Detail |
|------|--------|
| UI | Message bubbles, input, send |
| Status | Sent, delivered, read |
| Privacy | Block user from app bar menu |
| API | `GET /conversations/{id}/messages`, `POST /messages` |
| Real-time | `socket_io_client` when available; fallback polling every 5s |

## Controller Logic
- `conversationId` from arguments
- `fetchMessages()`, `sendMessage(text)`
- `connectSocket()` / `disconnectSocket()` in `onInit`/`onClose`
- `markAsRead()`
- `blockUser()` via app bar menu
- `RxList<MessageModel> messages` grouped by date headers optional

## UI Requirements
- Reverse `ListView` (newest at bottom)
- `message_bubble` — left (other) vs right (self) with theme colors
- `message_input` — `CustomTextField` + circular send button
- `read_status` — small ticks under own messages
- Date separator chips between days
- Typing indicator optional (mock)

## Promote to Core
If AI Chatbot uses same bubble style, extract `lib/core/widgets/chat_bubble.dart` with `isMe` parameter and reuse in Chatbot prompt 14.

## Route Registration
Add `Routes.CHAT_DETAIL`

## Output
Working chat detail with send/receive and read status UI.
