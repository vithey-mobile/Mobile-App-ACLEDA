# Vithey AI Chatbot — New Design Prompt Index

**UI status: complete** in `vithey_app/lib/modules/chatbot/` (home, suggestions, history drawer, composer, reasoning UI).

Complete specification for the **new Vithey AI** experience — minimal ChatGPT-style UI from updated reference screens.

## Product goal

Deliver a polished AI assistant comparable to modern mobile chatbots:

- **Minimal home** — large white chat canvas, suggestion rows above composer
- **Teal brand pill** — `Vithey AI` in app bar
- **History drawer** — New Chat + Recent Chats + trash per row
- **Reasoning state** — Vithey logo + teal dots in grey pill below assistant bubble
- **Sticky composer** — grey pill grows upward; `+` attach, teal send
- Markdown responses, copy/share/regenerate (feature-gated)
- **Backend-ready** — mock today, `ai-service` (Java Spring Boot :8089) tomorrow

## Visual references (source of truth)

| Screen | Asset |
|--------|-------|
| Home / empty + suggestions | `Prompt Frontend/screen image/chatbot/chatbot-home.png` |
| History drawer | `Prompt Frontend/screen image/chatbot/chatbot-menu-list-chat-history.png` |
| Assistant reply + thinking | `Prompt Frontend/screen image/chatbot/Reasoning-bot-response.png` |

## New design vs legacy (what changed)

| Area | Old prompt | **New reference** |
|------|------------|-------------------|
| App bar trailing | `Icons.add_comment_outlined` | **Circular `Icons.chevron_right`** → `newChat()` |
| App bar title | `centerTitle: true` | **Vithey AI pill left-of-center** (after menu) |
| Empty state | Centered hero + outline buttons | **Suggestion rows above composer only** (icon + text) |
| History drawer | Pin + overflow Rename/Pin/Delete | **Recent Chats + trash icon** (pin/rename feature-gate) |
| Thinking UI | "Thinking…" + dots | **App logo + grey pill + 3 teal dots** (minimal) |
| Assistant bubble | Wide markdown column | **White rounded card bubble** + logo row below |
| Disclaimer | Always below composer | **Optional** — can hide on empty home; show when messages exist |

## Technology stack (mandatory)

| Package | Use |
|---------|-----|
| `shadcn_flutter ^0.0.52` | New Chat, dialogs, buttons |
| `flutter_markdown ^0.7.4` | Assistant Markdown |
| `share_plus` | Share answer |
| `cached_network_image` / `Image.asset` | Vithey logo in thinking row |
| GetX | Controller, drawer, sessions |
| Material 3 + `context.appColors` | Surfaces, input fill, borders |

## Architecture

```text
Home [✨ Vithey AI]  →  AppRoutes.chatbot
    │
    ├── [≡] open drawer (02)
    ├── [>] newChat() (01)
    │
    ├── Empty → suggestion chips above composer (01)
    ├── Messages → user bubble + assistant card (04)
    └── Composer → send/stop (03)
            │
            ▼
    AiRepository → AiService → POST /ai/chat, GET /ai/sessions
```

## Reading order

| # | Prompt | Delivers |
|---|--------|----------|
| 1 | [`01.chatbot_home.md`](01.chatbot_home.md) | Shell, app bar, suggestion list, scroll, session orchestration |
| 2 | [`02.chatbot_list_history.md`](02.chatbot_list_history.md) | Drawer, New Chat, Recent Chats, delete |
| 3 | [`03.chatbot_input.md`](03.chatbot_input.md) | Grey pill composer, multiline growth, send/stop |
| 4 | [`04.chatbot_response.md`](04.chatbot_response.md) | White bubble, logo+dots thinking, markdown, actions |
| 5 | [`05.chatbot_api_streaming.md`](05.chatbot_api_streaming.md) | REST/SSE contract, repository, mock switch |

## Entry points

| Source | Behavior |
|--------|----------|
| Home app bar `Icons.auto_awesome_outlined` | `Get.toNamed(AppRoutes.chatbot)` |
| Deep link `vithey://ai` | Open chatbot, optional `sessionId` |

## Feature matrix

| Feature | UI | REST | SSE |
|---------|----|------|-----|
| Suggestion chips (home) | `01` | — | — |
| New Chat (app bar `>`) | `01` | — | — |
| History drawer | `02` | `GET /ai/sessions` | — |
| Delete chat (trash) | `02` | `DELETE /ai/sessions/{id}` | — |
| Send message | `03` | `POST /ai/chat` | planned |
| Stop generating | `03` | planned cancel | planned |
| Thinking dots | `04` | — | status events |
| Markdown reply | `04` | `reply` field | deltas |
| Copy / Share | `04` | — | — |
| Regenerate | `04` | planned | planned |
| Rename / Pin | `02` | planned `PATCH` | — |

## Module layout (target)

```text
lib/modules/chatbot/
  chatbot_screen.dart
  chatbot_controller.dart
  chatbot_binding.dart
  widgets/
    chatbot_app_bar.dart           # NEW — menu, pill, chevron
    chatbot_suggestion_list.dart   # NEW — icon + text rows above composer
    chatbot_history_drawer.dart
    chatbot_composer.dart
    chatbot_empty_state.dart       # thin wrapper or merge into suggestions
    user_message_bubble.dart
    assistant_message.dart
    assistant_thinking_indicator.dart
    markdown_message_body.dart
    code_block_card.dart
    message_action_row.dart
    jump_to_latest_button.dart
```

## Backend

| Service | Port | Docs |
|---------|------|------|
| `ai-service` (Java Spring Boot) | 8089 | `Prompt Backend/services/ai-service/API_ENDPOINTS.md` |
| Gateway | 8080 | `/api/v1/ai/**` |

**Not** `chat-service` — that is user-to-user private chat.

## Acceptance checklist

- [ ] Matches all three `screen image/chatbot/` references in light mode
- [ ] App bar: menu + Vithey AI pill + chevron `>`
- [ ] Home shows suggestion rows above composer (not centered hero buttons)
- [ ] Drawer: New Chat + Recent Chats + trash delete
- [ ] Thinking: logo + grey pill + 3 teal dots
- [ ] Composer grey pill grows upward
- [ ] `flutter_markdown` on assistant replies
- [ ] Dark mode readable
- [ ] `USE_MOCK_AI=false` works against gateway
- [ ] `flutter analyze` zero errors

## Output

Implement the **new Vithey AI** by following prompts **01 → 05**. Extend existing `vithey_app/lib/modules/chatbot/` — do not duplicate private chat module.

## Dependencies

- `Prompt Frontend/COMMON_CONTEXT.md`
- `Prompt Frontend/api-intergration/integration-contract.md`
- `Prompt Backend/_shared/SEARCH.md` *(unrelated — do not mix chat modules)*
