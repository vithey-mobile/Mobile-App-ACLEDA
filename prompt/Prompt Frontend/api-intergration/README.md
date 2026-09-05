# Frontend API Integration Prompts

**All frontend API integration prompts and contracts live here only.**

Use this folder when wiring the Flutter app to the live Spring Boot backend through API Gateway.

## Read Order

1. `integration-contract.md` — single source of truth for frontend ↔ backend API behavior
2. `api-overview.md` — endpoint index, relative paths, auth rules
3. `00-api-intergration-prompt.md` — AI prompt to wire live Dio/services/repositories

## Folder Contents

| File | Purpose |
|------|---------|
| `integration-contract.md` | Full frontend ↔ backend contract, gateway routing, events, cross-service flows |
| `api-overview.md` | Endpoint index grouped by backend service |
| `00-api-intergration-prompt.md` | Prompt to implement live API wiring in Flutter |

## Rule

Do not create or use API integration prompts in `reference/`, screen prompt folders, or elsewhere. Screen prompts may mention endpoint needs, but the implementation contract must point back here.

## Build Command

Use this in `MASTER_AI_PROMPT.md` when the backend and UI shell are ready:

```text
TASK: Prompt Frontend/api-intergration/00-api-intergration-prompt.md
```

