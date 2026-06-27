# Infrastructure — Kickoff Prompt

Build **Eureka Server**, **Config Server**, and root **docker-compose** for Vithey App microservices.

## Read First
1. `../../COMMON_CONTEXT.md`
2. `COMMON_CONTEXT.md` (this folder)
3. `SERVICE_PROMPT.md`

## Scope
- Service Discovery (Eureka) — port **8761**
- Config Server — port **8888**
- `docker-compose.yml` — PostgreSQL, Redis, RabbitMQ, MinIO, Eureka, Config

## Rules
- No business domain APIs here — infrastructure only.
- Config Server serves shared `application.yml` fragments per service.
- Eureka must start before other services register.

## Output
Runnable infrastructure that other services can connect to locally.
