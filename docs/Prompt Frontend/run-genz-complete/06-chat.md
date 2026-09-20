# GLM 5.3 Flash — Prompt 06 — Chat (GenZ)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with other modules.

---

You are a Flutter UI agent. Restyle **chat module only** to GenZ smart screens (includes heads-up-friendly density, not notification host).

## Own only

```text
vithey_app/lib/modules/chat/**
```

## Screens

Chat list, detail, profile, folders sheet, composer, bubbles, call UI chrome.

## Requirements

1. List leading actions / new chat / folders → rounder icon chrome.
2. Conversation rows: radius 16 cards or ink with 16 clip; unread badge pill.
3. Composer: pill send button (circle 48), attachment icons soft wash.
4. Bubbles: radius ≥ 16; media thumbs `VitheyRadii.media`.
5. Chat profile quick actions: circular 48 columns (already ~48 — unify fill to primary wash).
6. Incoming call / call screen controls: large circular accept/decline (keep red/green semantics).
7. Sheets (folders, delete) → Vithey dialogs/sheets where touched.
8. Do not break STOMP/mock send/receive or in-app alert service (lives in core).

## Stop when

Chat GenZ-consistent; analyze clean.
