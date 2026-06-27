# 14 - AI Chatbot Screen Prompt

Build the **AI Chatbot** module for Vithey App.

## Goal
AI assistant for CV writing, job applications, interviews, student support, and finance questions.

## Depends On
- `00-foundation-prompt.md`, optionally `13-chat-detail-prompt.md` for shared bubbles

## Reuse From Core
- `AppAppBar`
- `CustomTextField`
- `LoadingWidget`
- `chat_bubble.dart` from core IF extracted in prompt 13; else module-specific bubbles

## Module Files
```text
lib/modules/chatbot/
  chatbot_screen.dart
  chatbot_controller.dart
  chatbot_binding.dart
  widgets/
    ai_message_bubble.dart
    user_message_bubble.dart
    chatbot_input.dart
    suggestion_chip_row.dart    # Quick prompts: "How to write CV?"

lib/data/repositories/chatbot_repository.dart
lib/data/services/chatbot_service.dart
```

## Screen Spec
| Item | Detail |
|------|--------|
| Question types | CV, job, interview, student support, finance |
| Example | "How to write a good CV?" |
| API | `POST /ai/chat` with message history |
| UI | Chat-style message list |

## Controller Logic
- `RxList<ChatMessage> messages` with role user/assistant
- `sendMessage(text)` — append user msg → API → append AI reply
- `isTyping` loading state with animated dots
- `sendSuggestion(text)` from chips
- Keep last N messages for context in API payload
- Handle API errors gracefully with assistant error message

## UI Requirements
- Welcome state with suggestion chips when empty
- `suggestion_chip_row`: 4–6 example questions
- Reuse bubble widgets — **prefer single `ChatBubble` in core** with `isAi` flag
- `chatbot_input` same pattern as `message_input` from chat detail
- App bar title: "Vithey AI" or similar

## Widget Rules
- Do not duplicate bubble UI — unify with chat detail if possible
- Suggestion chips can be `lib/core/widgets/suggestion_chip.dart` if reused elsewhere

## Route Registration
Add `Routes.CHATBOT` — accessible from Home FAB or bottom nav

## Output
AI chat UI with suggestions and mock AI responses when backend offline.
