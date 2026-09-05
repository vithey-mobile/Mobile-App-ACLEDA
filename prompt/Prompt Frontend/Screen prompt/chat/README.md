# Private Chat Prompt Index

Use this folder as the single source of truth for person-to-person Chat.

## Reading order

1. [`01.list_chat.md`](01.list_chat.md) — conversation list, search, Add Chat, message requests.
2. [`02.chat_message.md`](02.chat_message.md) — real-time thread, messages, read state, composer.
3. [`03.chat_profile.md`](03.chat_profile.md) — chat participant profile, safety, shared media.

## Ownership boundaries

| Prompt | Owns |
|---|---|
| List | Conversation/request pagination, unread summaries, new conversation entry |
| Message | Thread history, send/receive, status, typing/read, connection lifecycle |
| Profile | Participant info, Message/Call/Video/Mute, shared media, Block/Report |

This folder is for private human chat only. Vithey AI remains in `../chatbot/`.
