# AGENTS.md

Monorepo for **Vithey** (AUB student superapp): Flutter app + Spring Boot microservices + Python AI CV engine. Each component has its own toolchain and working directory — there is no root build.

## Layout

| Path | What | Toolchain |
| --- | --- | --- |
| `vithey_app/` | Flutter mobile app (GetX, Dio, Isar) | Flutter / Dart |
| `backend/` | Maven multi-module Spring Cloud stack | Java 21 / Maven |
| `ai_core/` | Python CV engine (FastAPI, LLM-backed) | Python 3.10+ |
| `monitoring/` | Prometheus / Grafana / Loki stack | Docker Compose |
| `docs/` | Original build specs and prompts (reference only) | — |
| `plan.md` | Locked demo ("Profile M") architecture + runbook | — |
| `api_docs.md` | Flutter ↔ gateway API contract | — |

## Commands

### Flutter (`vithey_app/`)
`.env` is a declared pubspec asset and is gitignored, so **copy it before any build/analyze/test**:
```powershell
copy .env.example .env
flutter pub get
flutter analyze --no-fatal-infos   # CI lint gate
flutter test                       # CI gate
flutter run
```
- Isar models are generated: after editing `lib/data/local/isar/*.dart` run `dart run build_runner build --delete-conflicting-outputs`. `*.g.dart` files are committed and excluded from the analyzer.
- Web/Chrome is unsupported (Isar, secure storage, camera). Use an Android emulator or physical device.
- Emulator reaches the host at `10.0.2.2`, not `localhost`; use the PC LAN IP for a physical device.

### Backend (`backend/`)
```powershell
mvn test                              # all modules (unit + context; smoke needs Docker)
mvn -pl services/auth-service -am test
mvn test -Dtest=CareerServiceSmokeIT  # single test
```
- Java 21 required. `*SmokeIT` are Testcontainers integration tests — they need Docker and are skipped otherwise.
- `.vscode/settings.json` hardcodes a local Windows JDK path; do not rely on it on another machine.
- Test base classes live in `shared/vithey-test-support`; each service uses the container set matching its dependencies (see `TESTING.md`).

### ai_core (`ai_core/`)
```powershell
pip install -e ".[server,dev]"
pytest
python main.py serve --port 8100
```
- Directory is `ai_core/` but the importable package is `vithey_ai` (distribution `vithey-ai`), and the CLI entry is `python main.py extract|generate|serve`.

### Demo stack (from `backend/`)
```powershell
copy .env.example .env           # env-driven resource limits / profiles
.\scripts\docker-up-demo.ps1     # Profile M: infra + all Java services + Python ai_core
.\scripts\docker-up-demo.ps1 -Profiles map   # opt-in map-service
.\scripts\docker-up-demo.ps1 -Services auth-service,user-profile-service,api-gateway  # subset
.\scripts\smoke-api.ps1          # end-to-end API smoke
.\scripts\docker-down-demo.ps1   # add -v to wipe volumes (DB reset)
.\scripts\start-dev-host.ps1     # Windows: infra in Docker, selected JVMs on host (leanest dev loop)
./scripts/start-dev-host.sh <svc> # macOS/Linux: infra in Docker, service on host JVM (or ./run-backend-dev.sh)
.\scripts\set-docker-limits.ps1  # cap Docker Desktop/WSL2 RAM+CPU
```
Requires `ai_core/.env` with an API key first. See `DEMO.md`, `DOCKER.md`, `TESTING.md`.

## Architecture notes

- Flutter calls only the gateway (`:8080`, paths under `/api/v1`), never `ai_core` or the LLM directly.
- AI flow: `Flutter → Gateway → ai_core :8100 → LLM`. Python `ai_core` owns both chat and CV and returns the Vithey `{data,meta,error}` snake_case envelope directly (`vithey_ai/api/flutter_routes.py`). The Java `ai-service` is retired — do not reintroduce it.
- ai_core env vars keep the `DEEPSEEK_*` prefix for legacy reasons but default to OpenRouter GLM (`DEEPSEEK_BASE_URL=https://openrouter.ai/api/v1`, `DEEPSEEK_MODEL=z-ai/glm-5.3-flash`). Copy `ai_core/.env.example` and set the key.
- Vithey AI chat is a **stub** (`AI_CHAT_MODE=stub`). Do not wire `general-service`/GDCE RAG — it is explicitly out of scope. Peer chat (`chat-service`) is a separate live service.
- Service runtime config lives in `backend/infrastructure/config-repo/*.yml`, baked into the config-server image. Config changes require rebuilding config-server.

## Conventions

- All JSON is snake_case. List responses paginate via `page`/`limit` query params and a `meta` block.
- `.env` files are gitignored everywhere — put shared defaults in `.env.example`, keep local secrets in `.env`.
- All compose resource caps (`mem_limit`, JVM flags, pools, Postgres/Redis/RabbitMQ sizing) come from `backend/.env` / `backend/.env.example`. Never hardcode limits in compose — add a `${VAR:-default}` knob instead.
- Optional services are Compose profiles, not deleted files: `map` (map-service) and `monitoring` (Prometheus/Grafana/...). `monitoring/` starts nothing without `--profile monitoring`.
- Flyway: never edit an already-applied migration (checksum mismatch). Add a new version instead; reset local DBs with `docker-down-demo.ps1 -v`.
- CI: per-service workflows run `mvn -pl services/<svc> -am test`; `ci-promote-dev.yml` runs all backend + Flutter tests on pushes to `kimheang`/`main` and auto-pushes passing commits to `dev`.
- Port map: gateway 8080, auth 8081 … notification 8088, map 8090, ai_core 8100, Eureka 8761, Config 8888, Postgres 15432, Redis 16379, RabbitMQ 5672, MinIO 19000/19001.

## Read more

`plan.md`, `backend/DOCKER.md`, `backend/TESTING.md`, `backend/DEMO.md`, `api_docs.md`, `ai_core/README.md`, `vithey_app/README.md`, `monitoring/README.md`.
