# AI Service — Kickoff Prompt

You are building the **AI Service** for Vithey App: CV help, job advice, interview
prep, student support, and finance Q&A — backed by a configurable LLM provider.

## Read First (in this order, then stop and build)

1. `../../COMMON_CONTEXT.md` — global platform rules (stack, layout, envelopes, codes).
2. `COMMON_CONTEXT.md` — this service's identity, entities, provider config, topics, boundaries.
3. `SERVICE_PROMPT.md` — the authoritative API contract and build checklist.

> Precedence on conflict: `SERVICE_PROMPT.md` > service `COMMON_CONTEXT.md` > root `COMMON_CONTEXT.md`.

## Fixed Facts

- **Port:** 8089 · **Database:** `ai_db` · **Cache:** Redis · **Package:** `com.vithey.ai`
- **Provider:** OpenAI or Gemini, selected by `AI_PROVIDER` env (OpenAI wire format).

## Non-Negotiable Rules

- Provider is swappable via env — code against the `AiProvider` interface, never a single vendor.
- Store chat history for conversation context; load only the last N messages per call.
- Never send real payment amounts, passwords, or secrets to the LLM; sanitize user input first.
- Follow the standard response envelope and HTTP status codes from root `COMMON_CONTEXT.md`.

## Definition of Done

A runnable Spring Boot service on port 8089 implementing every endpoint in
`SERVICE_PROMPT.md`, with the required modules, tests (mocked provider), and docs.
