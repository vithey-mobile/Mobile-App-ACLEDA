# Chat Service — Kickoff Prompt

Build the **Chat Service** — private messaging, message requests, read status, block/report.

## Read First
1. `../../COMMON_CONTEXT.md` → 2. `COMMON_CONTEXT.md` → 3. `SERVICE_PROMPT.md`

## Port
**8087** | Database: **chat_db** | Cache: **Redis**

## Rules
- Receiver must accept message request before full conversation (privacy).
- WebSocket/STOMP for real-time; REST fallback for polling.
