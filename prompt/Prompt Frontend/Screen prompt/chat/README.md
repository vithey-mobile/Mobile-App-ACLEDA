# Private Chat — Telegram / Messenger Style Prompt Index

**UI status: complete** in `vithey_app/lib/modules/chat/` (folders, composer emoji, flexible header, Isar/STOMP wiring).

Complete specification for **person-to-person** private chat in Vithey App.

> **Not Vithey AI.** AI assistant prompts live in [`../chatbot/README.md`](../chatbot/README.md).

## Product goal

Deliver a production-quality chat experience comparable to **Telegram** and **Messenger**, matching the Vithey chat UI references:

- **Messenger-style** conversation list with Vithey branding, Add Chat row, unread badges, read ticks
- **Telegram-style** message thread with teal outgoing bubbles, **Seen** label, pill composer
- **Participant profile** with quick actions, contact card, and **Medias / Videos / Files / Links** shared tabs
- Real-time delivery via **WebSocket STOMP**
- **Isar** offline cache for conversations and messages
- **Firebase Cloud Messaging** push with deep-link to chat room

## Visual references

| Screen | Asset |
|--------|-------|
| Conversation list | `Prompt Frontend/screen image/chat/listchat.png` |
| Message thread | `Prompt Frontend/screen image/chat/chatuser.png` |
| Participant profile (wireframe) | `Prompt Frontend/screen image/chat/chat_profile.png` |
| Profile — Medias tab | `Prompt Frontend/screen image/chat/Chat medias share.png` |
| Profile — Videos tab | `Prompt Frontend/screen image/chat/Chat videos share.png` |
| Profile — Files tab | `Prompt Frontend/screen image/chat/Chat files share.png` |
| Profile — Links tab | `Prompt Frontend/screen image/chat/Chat links share.png` |

> **Canonical profile UI:** use the four **Chat * share.png** screens (Vithey participant **Heng Liza**). `chat_profile.png` is a layout wireframe only (Alex Rivera fixture).

## Flow diagram

```text
Bottom Nav (Chat tab active)
        │
        ▼
┌───────────────────┐
│ Chat List         │  listchat.png
│ Add Chat + rows   │
└─────────┬─────────┘
          │ Tap conversation / Add Chat
          ▼
┌───────────────────┐
│ Message Thread    │  chatuser.png
│ Bubbles + composer│
└─────────┬─────────┘
          │ Tap header avatar/name
          ▼
┌───────────────────┐
│ Chat Profile      │  Chat * share.png
│ 4 shared tabs     │
└───────────────────┘
```

## Reading order

| # | Prompt | Delivers |
|---|--------|----------|
| 1 | [`01.list_chat.md`](01.list_chat.md) | Vithey-branded list, Add Chat, Messages rows, bottom nav |
| 2 | [`02.chat_message.md`](02.chat_message.md) | Thread header, teal/white bubbles, Seen, pill composer |
| 3 | [`03.chat_profile.md`](03.chat_profile.md) | Profile header, actions, info card, 4 shared-content tabs |
| 4 | [`04.chat_isar_offline.md`](04.chat_isar_offline.md) | Isar schema, sync, outbox, stale indicators |
| 5 | [`05.chat_api_realtime.md`](05.chat_api_realtime.md) | REST + STOMP + FCM contract, error mapping |

## Technology stack (mandatory)

| Layer | Package / Tech | Role |
|-------|----------------|------|
| UI | `shadcn_flutter ^0.0.52` | Dialogs, buttons, composer actions |
| UI | Material 3 + `context.appColors` | Scaffold, bubbles, list tiles |
| REST | **Dio** | History, send fallback, read receipts |
| Real-time | **`web_socket_channel`** | STOMP over WebSocket via API Gateway |
| Local DB | **Isar** | Offline conversation + message cache, send outbox |
| Push | **`firebase_messaging`** + **`flutter_local_notifications`** | Background alerts |
| State | **GetX** | Controllers, routing, DI |

## Design tokens (from references)

| Token | Value | Use |
|-------|-------|-----|
| Primary teal | `AppColors.primary` (`#08B9B3`) | Outgoing bubbles, send button, active tab, badges, online text |
| Chat background | `#F5F7FA` / `context.appColors.bodyBackground` | Thread screen behind bubbles |
| List background | White | Conversation list |
| Unread badge | Teal filled circle, white count | e.g. **3** |
| Read indicator | Teal double-check icon | Own last message read |
| Typing | Teal text **Typing…** | List subtitle only when server event active |
| Relative time | `2m ago`, `Yesterday` | List trailing (not `h:mm a` on list rows) |
| Bubble radius | `16dp`; tail corner `4dp` | Left bottom-left; right bottom-right |
| Composer | Pill `24dp` radius, light gray fill | Placeholder per reference |

## Feature matrix

| Feature | UI prompt | Local (Isar) | REST | WebSocket | FCM |
|---------|-----------|--------------|------|-----------|-----|
| Vithey logo app bar | `01` | — | — | — | — |
| Add Chat horizontal row | `01` | — | user search | — | — |
| Conversation list rows | `01` | ✅ cache | `GET /conversations` | upsert on message | badge |
| Relative time `2m ago` | `01` | `updated_at` | ✅ | — | — |
| Teal unread badge | `01` | ✅ | in DTO | increment | — |
| Teal double-check read | `01` | ✅ | last_message.status | — | — |
| Typing subtitle | `01`, `02` | — | — | typing event | — |
| Thread header + Active Now | `02` | presence TTL | presence API | presence | — |
| Teal outgoing / white incoming bubbles | `02` | ✅ | — | — | — |
| **Seen** label under own bubble | `02` | ✅ | read receipt | read event | — |
| Timestamp inside bubble | `02` | `created_at` | ✅ | — | — |
| Pill composer + plane send | `02` | outbox | POST message | STOMP send | — |
| Reply / copy / delete | `02` | `reply_to_id` | planned | planned | — |
| Profile quick actions | `03` | — | — | — | — |
| Medias / Videos / Files / Links tabs | `03` | cache metadata | attachments API | — | — |
| Block / Report | `03` | — | block/report | — | — |
| Offline cache | `04` | Isar | gap fill | reconnect | — |
| Push deep link | `05` | — | — | — | FCM |

## Module architecture (target)

```text
lib/modules/chat/
  chat_list_screen.dart
  chat_list_controller.dart
  chat_detail_screen.dart
  chat_detail_controller.dart
  chat_profile_screen.dart
  chat_profile_controller.dart
  chat_binding.dart
  widgets/
    chat_list_app_bar.dart           # Vithey logo + search
    add_chat_contacts_row.dart       # horizontal Add Chat + avatars
    conversation_list_tile.dart
    message_request_card.dart
    chat_detail_header.dart
    message_bubble.dart
    message_status_label.dart        # "Seen" + ticks
    chat_composer.dart
    typing_indicator_banner.dart
    reply_preview_bar.dart
    date_separator.dart
    jump_to_latest_chip.dart
    chat_profile_header.dart
    chat_quick_actions_row.dart
    chat_contact_info_card.dart
    chat_shared_tabs.dart
    shared_media_grid.dart
    shared_video_grid.dart
    shared_file_tile.dart
    shared_link_tile.dart
```

## Acceptance checklist (release)

- [x] List — Vithey header, folders/tabs, conversation rows, Chat tab
- [x] Thread — bubbles, Seen, pill composer, emoji panel
- [x] Profile — shared content tabs
- [x] Relative times on list; clock time inside bubbles
- [x] Isar offline + STOMP paths per `04` / `05` (mock-capable)
- [x] Dark mode readable
- [ ] Live FCM deep link against production Firebase (env-gated)

## Output

Implement the full private chat module by following prompts **01 → 05** in order.
