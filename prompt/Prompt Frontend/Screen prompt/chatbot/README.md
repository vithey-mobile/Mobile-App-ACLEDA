# Chatbot Prompt Index

Use this folder as the single source of truth for Vithey AI.

## Reading order

1. [`01.chatbot_home.md`](01.chatbot_home.md) — screen shell, sessions, topic, message list orchestration.
2. [`02.chatbot_list_history.md`](02.chatbot_list_history.md) — drawer, New Chat, rename, pin, delete confirmation.
3. [`03.chatbot_input.md`](03.chatbot_input.md) — sticky composer, send/stop, attachments, drafts.
4. [`04.chatbot_response.md`](04.chatbot_response.md) — thinking, streaming, rich response blocks and actions.

## Ownership boundaries

| Prompt | Owns |
|---|---|
| Home | Current session, screen layout, history/message loading, topic and routing |
| History | Drawer pagination and session mutations |
| Input | Draft, attachments, send lifecycle entry, keyboard behavior |
| Response | Assistant streaming/rendering, thinking, code/citations/actions |

Avoid duplicating behavior between files. All operations use stable session/message IDs and enforce server ownership.
