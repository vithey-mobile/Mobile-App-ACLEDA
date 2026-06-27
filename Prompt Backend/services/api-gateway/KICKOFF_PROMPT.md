# API Gateway — Kickoff Prompt

Build the **API Gateway** for Vithey App — single entry point for Mobile App, Admin Panel, and external clients.

## Read First
1. `../../COMMON_CONTEXT.md`
2. `COMMON_CONTEXT.md`
3. `SERVICE_PROMPT.md`

## Scope
Spring Cloud Gateway with JWT validation, rate limiting, CORS, and route definitions to all downstream services.

## Port
**8080**

## Rules
- No domain business logic or database.
- All public API traffic goes through this gateway.
- JWT filter validates token before routing to protected services.
