# Vithey

Vithey is a student "superapp" built for the **ACLEDA Bank App Competition 2026**. This repository is a monorepo containing a Flutter mobile app, a Spring Boot microservices backend, a Python AI CV engine, and a monitoring stack.

## Layout

| Path | What | Toolchain |
| --- | --- | --- |
| `vithey_app/` | Flutter mobile app (GetX, Dio, Isar) | Flutter / Dart |
| `backend/` | Maven multi-module Spring Cloud stack | Java 21 / Maven |
| `external-services/ai-core/` | Python CV engine (FastAPI, LLM-backed) | Python 3.10+ |
| `external-services/fake-payment-service/` | Fake external payment provider (demo/UAT) | Python / FastAPI |
| `monitoring/` | Prometheus / Grafana stack | Docker Compose |
| `docs/` | Documentation package (see below) | — |

## Documentation

The full documentation package — project overview, requirements, architecture, database, API, frontend, backend, AI, security, testing, UAT, DevOps, deployment, monitoring, operations, user guides, risk management, handover, and final report — starts at:

**[docs/00-project-overview/07-document-index.md](docs/00-project-overview/07-document-index.md)**

Key starting points:

- [Project overview](docs/00-project-overview/01-project-overview.md)
- [System architecture](docs/03-system-design/01-system-architecture.md)
- [API overview](docs/06-api/01-api-overview.md)
- [Executive summary (final report)](docs/20-final-report/01-executive-summary.md)

> Note: requirements, UAT, security assessment, and production deployment contain `TBD — Requires confirmation.` items and are **not** to be treated as complete until confirmed.

## Quick commands

Per-component commands, in short:

- Flutter (`vithey_app/`): `copy .env.example .env` → `flutter pub get` → `flutter analyze --no-fatal-infos` → `flutter test`
- Backend (`backend/`): `mvn test` (Java 21; `*SmokeIT` need Docker)
- AI (`external-services/ai-core/`): `pip install -e ".[server,dev]"` → `pytest` → `python main.py serve --port 8100`
- Demo stack (`backend/`): `.\scripts\docker-up-demo.ps1` (see [`DEMO.md`](backend/DEMO.md), [`DOCKER.md`](backend/DOCKER.md))
