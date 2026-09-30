# Evidence Basis (Single Source of Truth for this Documentation Set)

> Status: Verified baseline · Last reviewed: 2026-09-30
> This file is the shared evidence anchor. Every generated document must be consistent with it. If code contradicts this file, the code wins — update this file and note the change.

## How to read status tags

- **VERIFIED** — directly supported by repository evidence (code, config, migrations, workflows, scripts). Cite the path.
- **INFERRED** — a reasonable inference from implementation, not formally documented. Must be marked: `Inferred from implementation — requires business confirmation.`
- **PLANNED** — found in plans/prompts/TODOs but not implemented. Must be marked as planned.
- **TBD** — no sufficient evidence. Write: `TBD — Requires confirmation.`

Never present planned/inferred functionality as verified completed functionality.

## 1. Project identity

- **Product name:** Vithey (a student "superapp"). Display name on device: **Vithey**.
- **Client/organisation:** AUB context; built for the **ACLEDA Bank App Competition 2026** (evidence: `docs/Prompt Frontend/00-project-summary.md`, `docs/Prompt Backend/COMMON_CONTEXT.md`). Exact contractual client/entity name: **TBD — Requires confirmation.**
- **Repository:** monorepo. `origin` = `https://github.com/Kimheang-code-IT/Mobile-App-ACLEDA.git`; `upstream` = `https://github.com/vithey-mobile/Mobile-App-ACLEDA.git`.
- **Current branch at documentation time:** `kimheang`. Main integration branch: `main`; auto-promotion target: `dev`.
- **Version strings (verified):** Flutter pubspec `1.0.0+1`; ai_core dist `vithey-ai` `0.2.0`; backend `vithey-backend 0.0.1-SNAPSHOT`; git tag `presync-20260930` at commit `3537584` ("updaate version 0.0.3").
- **History window (evidence-derived, NOT a contractual date):** first commit `7e35770` "Prompt" 2026-06-27 → latest `d11106f` 2026-09-30.

## 2. Components (VERIFIED)

| Component | Path | Toolchain |
|---|---|---|
| Flutter mobile app | `vithey_app/` | Flutter/Dart (pubspec package `aub_connect_app`) |
| Backend microservices | `backend/` | Java 21 / Maven / Spring Boot 3.3.5 / Spring Cloud 2023.0.3 |
| AI core | `ai_core/` | Python 3.10+ (package `vithey_ai`, CLI `python main.py extract\|generate\|serve`) |
| Monitoring | `monitoring/` | Docker Compose: Prometheus, Grafana, Loki, Promtail, node-exporter, cAdvisor |
| Build specs / prompts | `docs/Prompt Al`, `docs/Prompt Backend`, `docs/Prompt Devops`, `docs/Prompt Frontend`, `docs/_shared` | Reference only (largely PLANNED/aspirational) |

Root reference docs (verified): `AGENTS.md`, `plan.md` (locked "Profile M" demo plan), `api_docs.md` (Flutter↔gateway contract). There is **no root `README.md`**.

## 3. Backend services and ports (VERIFIED)

Evidence: `backend/infrastructure/config-repo/*.yml`, each service `src/main/resources/application.yml`.

| Service | Port | App name | Database | Module path |
|---|---|---|---|---|
| api-gateway | 8080 | api-gateway | (none) | `backend/services/api-gateway` |
| auth-service | 8081 | auth-service | auth_db | `backend/services/auth-service` |
| user-profile-service | 8082 | user-profile-service | user_db | `backend/services/user-profile-service` |
| file-service | 8083 | file-service | file_db | `backend/services/file-service` |
| content-service | 8084 | content-service | content_db | `backend/services/content-service` |
| career-service | 8085 | career-service | career_db | `backend/services/career-service` |
| finance-service | 8086 | finance-service | finance_db | `backend/services/finance-service` |
| chat-service | 8087 | chat-service | chat_db | `backend/services/chat-service` |
| notification-service | 8088 | notification-service | notification_db | `backend/services/notification-service` |
| map-service | 8090 | map-service | map_db | `backend/services/map-service` |
| eureka-server | 8761 | eureka-server | (none) | `backend/infrastructure/eureka-server` |
| config-server | 8888 | config-server | (none) | `backend/infrastructure/config-server` |

Infra host ports: PostgreSQL 15432 (full stack) / 15433 (infra-only compose); Redis 16379; RabbitMQ 5672 + 15672; MinIO 19000/19001. ai_core 8100.

There is **no** `services/ai-service` module and **no** `general-service`. The Java `ai-service` is retired (evidence: `backend/DOCKER.md`, `backend/DEMO.md`, `api_docs.md` §10).

## 4. Architecture (VERIFIED)

- Client → gateway only: Flutter calls `http://<host>:8080/api/v1/**`, never `ai_core`/LLM directly.
- Gateway is reactive; routes via Spring Cloud Gateway (`lb://<service>` through Eureka), plus a direct route `/api/v1/ai/**` → `http://ai-core:8100` (NOT Eureka), and `lb:ws://chat-service` for `/ws/**`.
- Gateway security: `JwtAuthenticationGlobalFilter` validates Bearer JWT and injects `X-User-Id`, `X-User-Roles`, `X-User-Email`; Redis-based `RequestRateLimiter` on all routes via `#{@rateLimitKeyResolver}`; CORS filter.
- Each domain service has its own `SecurityConfig` + `JwtAuthenticationFilter` (defense in depth), stateless, method security enabled.
- Service discovery: Eureka (`register-with-eureka: false` on server). Config: Spring Cloud Config **native** profile, files in `backend/infrastructure/config-repo/`, baked into the config-server image (config change ⇒ rebuild config-server); compose also bind-mounts config-repo for local.
- Inter-service calls: OpenFeign resolving via Eureka; `FeignAuthConfig` forwards `Authorization` + `X-User-*` headers. Feign circuit breaker enabled globally.
- Messaging: RabbitMQ via Spring AMQP on a single topic exchange **`vithey.events`**. No Kafka anywhere.
- Caching: Redis used imperatively via `StringRedisTemplate` (no Spring Cache abstraction). Gateway rate limiter; chat recent-message cache (`chat:recent:*`, 24h); map places cache (search 5m, detail 24h, degrade on Redis failure).

### RabbitMQ routing keys (VERIFIED)

Producers: auth `user.registered`, `student.verified`; content `post.created`, `comment.added`, `reaction.added`, `follow.created`, `mention.created`; career `job.application.submitted`, `job.application.status_changed`; chat `chat.request.received`, `chat.message.sent`; finance `payment.due`, `payment.overdue`; user-profile `profile.updated`.

Consumers: notification (queues `notification.<routing-key>` for comment/reaction/follow/mention/chat.request/chat.message/payment.due/payment.overdue/job.*); user-profile (`user-profile.user.registered`); finance (`finance.student.verified`).

## 5. Security (VERIFIED unless marked)

- JWT: HMAC, JJWT 0.12.6; claims `sub`, `email`, `roles`; access TTL 15m, refresh TTL 7d (`vithey.jwt.secret`, `access-token-ttl`, `refresh-token-ttl`).
- Roles: `USER`, `STUDENT`, `COMPANY`, `ADMIN` → `ROLE_<name>`.
- Method security actually used in only two places: `@PreAuthorize("hasRole('STUDENT')")` on `FeeController` and `PaymentController` in finance-service.
- Password storage: bcrypt (auth-service). Refresh tokens stored hashed. Email/reset tokens stored hashed.
- Public auth paths at gateway: register, login, refresh, forgot-password, reset-password, verify-email (+ actuator/swagger). Note: `/api/v1/students/verify` is routed but not in the public matcher, so the gateway requires a JWT for it (documented discrepancy).
- Secrets: only `.env.example` files are tracked; no `.env` committed. Do NOT print values.
- Formal security assessment / penetration test / audit: **Not yet formally assessed.** No evidence exists.

## 6. AI (VERIFIED)

- `ai_core` (Python FastAPI, :8100) owns the whole `/api/v1/ai/**` surface (chat + CV), returns the Vithey `{data,meta,error}` snake_case envelope (`vithey_ai/api/flutter_routes.py`).
- LLM client `DeepSeekClient` wraps `openai.OpenAI`; env names keep the `DEEPSEEK_*` prefix but defaults are OpenRouter GLM: `DEEPSEEK_BASE_URL=https://openrouter.ai/api/v1`, `DEEPSEEK_MODEL=z-ai/glm-5.3-flash`.
- **CV generation uses the real LLM.** Pipeline: fetch profile+posts (httpx) → extract (JSON-mode LLM, cached by SHA-256) → dedupe → build prompt → LLM → deterministic `normalize_cv` → `score_cv` quality rubric (100 pts). Output `StandardCV`.
- **Chat is a stub.** `AI_CHAT_MODE` default `stub` is read but never branched on; `ChatService` always calls `stub_reply`; `/cv/suggest` is also stubbed. No RAG / no GDCE (explicitly out of scope).
- Cost/limits: `MAX_TOKENS=3000`, `TEMPERATURE=0.2`, `TIMEOUT_SECONDS=30`, `MAX_RETRIES=2`, `MAX_POSTS_PER_BUILD=100`, `MAX_CONTENT_CHARS=6000`, `AI_CV_MAX_POSTS=20`. In-memory extraction cache (512), in-memory LLM rate limiter (120/60s), per-IP HTTP rate limit (30/min), body cap 512 KB.
- Known limitation: `cv_app_service.to_draft` field mismatch (`items` vs `skills`, `summary` vs `bullets`) can drop fields in the Flutter draft.

## 7. Frontend (VERIFIED)

- Flutter + **GetX 4.6.6** state/DI/routing; **Dio 5.4** networking with a single interceptor (token injection + 401 refresh); **Isar 3.1** local DB (chat only: conversations/messages/outbox); `flutter_secure_storage` for tokens; `shared_preferences` for settings; `shadcn_flutter` design layer.
- Package name `aub_connect_app`; modules under `lib/modules/` (auth, home, jobs, profile, chat, chatbot, finance, search, settings, map). No `lib/features/`.
- `.env` is a declared pubspec asset (gitignored); `AppConfig` reads `API_BASE_URL` (default `http://localhost:8080/api/v1`), `WS_BASE_URL` (default `ws://10.0.2.2:8080/ws`), timeouts, flags.
- Auth gating is manual (no GetX middleware): `SplashController` + `AuthNavigation`.
- Stubs / disabled: **Google auth** UI-only (throws unless mock); **FCM** commented out (no Firebase packages, no `google-services.json`); chat call simulation; several "coming soon" items (2FA, biometric, data & storage, accessibility, chatbot attachments, history search).
- Localization: English strings hardcoded (`AppStrings`); Khmer is a stored preference + CV label only (no `.arb`).
- Mock-first: `FeatureFlags` / many `USE_MOCK_*` flags; fixtures in `lib/data/fixtures/`.
- Tests: only 3 files under `test/` (widget, notification prefs, notification utils). No integration/golden tests.
- Release signing: Android release currently **signs with debug keys** (explicit TODO in `android/app/build.gradle`).
- Web/Chrome unsupported (Isar/secure storage/camera).

## 8. Data (VERIFIED)

- One PostgreSQL database per service (see §3); default `public` schema; Flyway per service (`ddl-auto: validate`, `open-in-view: false`). No shared DB. `init-databases.sql` creates auth_db, user_db, file_db, content_db, career_db, finance_db, chat_db, notification_db, ai_db, map_db (ai_db is created but unused by Java now).
- Migration counts: auth 4, user-profile 3, content 5, career 4 files (**two share version `V3` — Flyway conflict**), chat 3, finance 3, file 3, notification 4, map 1.

### Documented data defects (VERIFIED — document, do not silently fix)

1. **career-service duplicate Flyway version `V3`** (`V3__Job_application_composite_indexes_and_status_check.sql` + `V3__User_cv_file_unique_and_application_fk.sql`).
2. **career `UserCv` entity `@Id` maps `user_id`** while DB PK is `id`.
3. **user-profile trigram index no-op**: V3 re-create is skipped (`IF NOT EXISTS`) so the intended `LOWER(full_name)` GIN index is not created.
4. **Enum vs DB CHECK supersets** in career/content/chat/finance/notification (entities cannot represent all DB-permitted states).
5. **Smoke `*SmokeIT` tests are not run by plain `mvn test`** (no failsafe config).

## 9. DevOps / CI / Monitoring (VERIFIED)

- Docker Compose demo (Profile M) via `backend/scripts/docker-up-demo.ps1` (base + `docker-compose.demo.yml` overlay); resource caps from `backend/.env` (`mem_limit`, JVM opts, pools) — no hardcoded limits. `backend/.env` is absent by default (defaults apply).
- Multi-stage Java Dockerfiles (Maven/Temurin 21 build → JRE 21 alpine runtime, non-root `vithey`); ai_core single-stage python:3.12-slim. No Flutter Dockerfile.
- CI: `.github/workflows/ci-promote-dev.yml` (tests backend + Flutter + ai_core, builds/pushes 13 images to GHCR, then fast-forwards the passing commit to `dev`) + 9 per-service workflows (test → docker build → compose validate). Registry: `ghcr.io/<owner>/vithey-<service>` tags `latest`, `sha-<short>`.
- **No staging and no production deployment exist.** No K8s/Helm/Terraform/Jenkins. `application-prod.yml` exists but nothing activates it in CI.
- Monitoring: profile-gated (`--profile monitoring`); Prometheus scrapes `/actuator/prometheus` for **9** services (api-gateway + the 8 DB-backed domain services; `eureka-server`, `config-server`, `map-service` and `ai_core` are NOT scraped); alerts defined but **no Alertmanager**; Grafana dashboards provisioned; Loki 168h retention.
- Health: `/actuator/health` on services; ai_core `/health`.

## 10. Tests (VERIFIED)

- Backend: **41** test Java files (19 unit `*Test`, 11 H2 `*ContextTest`, 11 Docker-gated `*SmokeIT`). map-service has unit tests only (no context/IT, no test-support dep). Shared bases in `backend/shared/vithey-test-support`. No JaCoCo/coverage config; no failsafe config.
- Flutter: 3 unit tests. ai_core: **11** pytest files (`test_*.py`, plus a `fakes.py` helper). Monitoring/scripts: none.
- **Test execution during this documentation task:** not performed. Any "result" must be written as `Test implemented — current execution result not independently verified.`

## 11. Team (INFERRED from git authors + `Action_Plan_Vithey.csv`)

Names from commit metadata: Kim heang (project lead, backend/DevOps/integration), Ponloeng Bora (gateway/auth/infra), namayheng (Flutter auth/settings/theme), KhornMolika (Flutter profile/settings/media/map), KosalChansothay (ai_core), sovannarith (Flutter finance/ACLEDA payment), Heng Liza/Icesuza (UI/name). **Mark these as inferred — roles require confirmation.** Formal stakeholder names and contractual signatories: **TBD — Requires confirmation.**

## 12. Status of governance artefacts

- **UAT:** has NOT been formally executed; no evidence found.
- **Production deployment:** not performed.
- **Security assessment:** not performed.
- **Formal acceptance/sign-off:** not present (blank fields in `plan.md` §14).
- **Staging:** does not exist.

## 13. Secret handling

Never write actual values. Document environment variable NAMES only (e.g. `VITHEY_JWT_SECRET`, `DEEPSEEK_API_KEY`, `MINIO_SECRET_KEY`, `POSTGRES_PASSWORD`). If a value must be shown, use `<REDACTED>`.
