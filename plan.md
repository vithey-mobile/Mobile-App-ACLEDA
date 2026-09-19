# Vithey Demo Plan — Backend First + AI Integration

> **Status:** Demo running path — OpenRouter **GLM 5.3 Flash** via `ai_core` on host `:8100`; Vithey stack in Docker.  
> **LLM:** OpenRouter `z-ai/glm-5.3-flash` (configured in `ai_core/.env`, gitignored).  
> **Scope:** Demo project only (~**10 concurrent users**), run on **your local computer**.  
> **Goal:** Run **all Vithey backend services live** + wire `ai_core` for AI on **your PC** (tight RAM caps, no GDCE, cloud API key).

**How to run now (from** `backend/`**):**

```powershell
# 1) Set DeepSeek key in ai_core/.env (copy from .env.example)
# 2) Start Profile M demo stack
.\scripts\docker-up-demo.ps1
# Docs: DEMO.md
```

---



## 0. Decision summary (LOCKED)


| Item                        | Decision                                                                                                      |
| --------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Where to run                | **Your local computer only** (no cloud cluster / shared server for demo)                                      |
| Audience                    | Internal demo / student pitch — max **10 users at once**                                                      |
| Profile                     | **Profile M — Full app live** (locked) — **all Vithey domain services run**                                   |
| Finance live?               | **Yes** — `finance-service` live                                                                              |
| Peer chat live?             | **Yes** — `chat-service` + WebSocket live                                                                     |
| Notification live?          | **Yes** — `notification-service` live (FCM optional / stub device ok)                                         |
| Map live?                   | **Yes** — `map-service` live **if** Google Places server key is set; otherwise map returns clear config error |
| GDCE RAG                    | **No** — do **not** run or depend on `general-service` / GDCE stack                                           |
| Chatbot (Vithey AI) replies | **Topic stub** inside Spring `ai-service` (no RAG, no GDCE)                                                   |
| AI / LLM                    | **DeepSeek cloud via API key** (`DEEPSEEK_API_KEY` in local `.env` only)                                      |
| CV engine                   | `ai_core` on this PC (`:8100`) calls DeepSeek with that key                                                   |
| Priority                    | **Backend + AI first**; then turn Flutter `USE_MOCK_*=false` per module when healthy                          |
| AI focus                    | **Auto-Create CV** via `ai_core` (P0) → stub Vithey AI chatbot (P1) → optional rule match/skills (P2)         |
| Architecture                | Full microservice set on one PC with **tight memory caps**, 1 shared Postgres                                 |
| Persistence                 | Single Postgres, small volumes, short retention                                                               |
| Not in demo                 | GDCE RAG, K8s, local GPU LLM, OCR/PDF, Google OAuth, production HA                                            |


**Approve checklist (you):**

- [x] Profile **M** — **all services live**  
- [x] Finance / peer-chat / notification / (map) **live**  
- [x] **No** GDCE RAG — Vithey AI chatbot = stub only  
- [x] AI via **DeepSeek API key** on local PC  
- [ ] Phase order (§5) OK to start build  
- [ ] “Out of scope” (§8) OK  
- [ ] PC has enough RAM for Profile M (~**12–16 GB** system recommended)

---



## 1. Current state (as of this plan)

```text
Flutter (vithey_app)  — on your PC / phone
  → API Gateway :8080  — local Docker
      → ALL Vithey Spring services (auth … map + ai-service)
      → ai-service :8089
            → Vithey AI CHAT: in-process topic STUB  (NO general-service / NO GDCE)
            → CV:   ai_core :8100  → DeepSeek API (API key)
```


| Layer                  | Reality                                                                                                       |
| ---------------------- | ------------------------------------------------------------------------------------------------------------- |
| `vithey_app`           | UI ready; many modules still mock until flags flipped live.                                                   |
| Gateway + Java         | Full set exists in repo — **demo starts all domain services** under memory caps.                              |
| Spring `ai-service`    | Chat + `POST /ai/cv/suggest` exist; may call RAG today — **demo forces chat stub**. No `/ai/cv/generate` yet. |
| `ai_core` (Python)     | Ready for CV; needs local `DEEPSEEK_API_KEY`. Not wired from Java yet.                                        |
| GDCE / general-service | **Out of scope — do not install or start.**                                                                   |


**Biggest gap for “UI + AI” demo:** wire **Auto-Create CV**:

`Flutter → Gateway → ai-service → ai_core → DeepSeek (API key) → map StandardCV → AiCvDraft`

---



## 2. Target architecture (demo — Profile M, all services live on your PC)

```text
┌──────────────────────────────────────────────────────────────┐
│  YOUR COMPUTER (local demo — Profile M)                      │
│                                                              │
│  Flutter app (prefer physical phone if RAM tight)            │
│       │ Bearer JWT                                           │
│       ▼                                                      │
│  api-gateway :8080                                           │
│       │                                                      │
│       ├─ auth :8081                              ✅ LIVE     │
│       ├─ user-profile :8082                      ✅ LIVE     │
│       ├─ file :8083 + MinIO (small)              ✅ LIVE     │
│       ├─ content :8084                           ✅ LIVE     │
│       ├─ career :8085                            ✅ LIVE     │
│       ├─ finance :8086                           ✅ LIVE     │
│       ├─ chat (peer) :8087 + STOMP /ws           ✅ LIVE     │
│       ├─ notification :8088                      ✅ LIVE     │
│       ├─ map :8090                               ✅ LIVE*    │
│       └─ ai-service :8089                        ✅ LIVE     │
│              │                                               │
│              ├─ Vithey AI chatbot → TOPIC STUB (no GDCE)     │
│              └─ CV generate → ai_core :8100                  │
│                                   │                          │
│                          DeepSeek API (cloud)                │
│                          auth: DEEPSEEK_API_KEY              │
│                                                              │
│  Shared: 1× Postgres · Redis · RabbitMQ · Eureka · Config    │
│  * map needs GOOGLE_PLACES_API_KEY; else fail softly         │
└──────────────────────────────────────────────────────────────┘
```

**Rules:**

1. Flutter **never** calls `ai_core` or DeepSeek directly — always Gateway → Java → Python → API.
2. Java owns auth, aggregation, envelope, Flutter DTO mapping, and **Vithey AI chat stubs**.
3. `ai_core` stays a thin CV engine (no JWT, no user DB); only secret is `DEEPSEEK_API_KEY`.
4. **No GDCE RAG** — chatbot uses built-in topic stubs (`vithey.ai.chat.mode=stub`).
5. **All Vithey domain services are live** for the demo; Flutter turns mocks off module-by-module after health checks.
6. Keep **tight heaps / RAM limits** so the full stack still fits a laptop (see §3).



## 3. Resource configuration (your PC / 10 users / Profile M — all live)



### 3.1 Target machine (local demo)


| Spec    | Minimum                                                       | Comfortable     |
| ------- | ------------------------------------------------------------- | --------------- |
| RAM     | **16 GB** system (stack ~10–12 GB)                            | **32 GB** nicer |
| CPU     | 4–6 cores                                                     | 8 cores         |
| Disk    | **20–30 GB** free (images + volumes)                          | 40 GB           |
| Network | Stable internet (**required** for DeepSeek + optional Places) | —               |


If PC has **only 12 GB RAM**: still Profile M with **strict caps** below; run Flutter on a **physical phone**, close browsers, and do not run Android emulator + Docker together.

If PC has **only 8 GB RAM**: Profile M will struggle — upgrade RAM or accept swap thrash / start fewer tabs; **do not** also run a heavy emulator.

### 3.2 Demo profile — **M LOCKED (all services live)**


| Profile               | Status     | Approx RAM             | What runs                                                                                                                                                                                         |
| --------------------- | ---------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| S — Slim              | Not used   | ~6–8 GB                | (superseded — you want all live)                                                                                                                                                                  |
| **M — Full app live** | **LOCKED** | **~10–12 GB**          | Infra + **all** Java domain services (auth, profile, file, content, career, finance, peer-chat, notification, map, ai-service) + gateway + `ai_core`. **Still OFF:** GDCE / general-service only. |
| L                     | Avoid      | 16 GB+ unlimited heaps | Not needed                                                                                                                                                                                        |


**Flutter for Profile M:** after backend healthy, set mocks off for auth, posts, profile, jobs, finance, peer chat, notifications, map, AI — module by module. Keep mock only where an endpoint is still missing.

### 3.3 Memory / CPU caps (Docker Compose — to add)

Apply `deploy.resources.limits` (or `mem_limit` on Compose v2) so one service cannot eat the PC.


| Container             | RAM limit      | JVM / notes                                       |
| --------------------- | -------------- | ------------------------------------------------- |
| postgres              | 512 MB         | `shared_buffers=128MB`, `max_connections=40`      |
| redis                 | 64–128 MB      | `maxmemory 64mb`, `allkeys-lru`                   |
| rabbitmq              | 256 MB         | Disable unused plugins if possible                |
| minio                 | 256 MB         | 1 bucket, small files only                        |
| eureka-server         | 256 MB         | `-Xmx128m`                                        |
| config-server         | 256 MB         | `-Xmx128m`                                        |
| each Spring app       | **384–512 MB** | `-Xms128m -Xmx256m` (gateway maybe `-Xmx384m`)    |
| ai_core (Python)      | 256–384 MB     | 1 uvicorn worker only                             |
| **Total (Profile M)** | **~10–12 GB**  | All services + caps; leaves OS + Flutter headroom |


**JVM env for every Java service (demo):**

```bash
JAVA_TOOL_OPTIONS=-XX:+UseSerialGC -Xms128m -Xmx256m -XX:MaxMetaspaceSize=128m
```

Gateway:

```bash
JAVA_TOOL_OPTIONS=-XX:+UseSerialGC -Xms128m -Xmx384m -XX:MaxMetaspaceSize=160m
```



### 3.4 Postgres — one instance, small DBs

Keep **one Postgres** with multiple databases (already in `init-databases.sql`). Do **not** run one Postgres container per service for demo.

Extra demo settings:

```text
max_connections = 40
shared_buffers = 128MB
work_mem = 4MB
effective_cache_size = 512MB
```

Data retention for demo:

- AI chat sessions: keep last **50 messages / user** or **7 days**
- Uploaded files: cap **20 MB / user**, delete old demo uploads when needed
- No analytics warehouses



### 3.5 ai_core / DeepSeek API key — cheap & small

**Auth to LLM:** local file `ai_core/.env` (never commit):

```bash
DEEPSEEK_API_KEY=sk-...your-key...
DEEPSEEK_BASE_URL=https://api.deepseek.com
DEEPSEEK_MODEL=deepseek-v4-flash
```


| Setting                     | Demo value               | Why                       |
| --------------------------- | ------------------------ | ------------------------- |
| `DEEPSEEK_API_KEY`          | **Required** on your PC  | Only way AI runs for demo |
| `DEEPSEEK_MODEL`            | `deepseek-v4-flash`      | Cost + speed              |
| `MAX_POSTS_PER_BUILD`       | **20** (not 100)         | Less tokens / RAM         |
| `MAX_CONTENT_CHARS`         | **2000**                 | Truncate long posts       |
| `MAX_TOKENS`                | **1500–2000**            | Smaller CV replies        |
| `TIMEOUT_SECONDS`           | **45**                   | Mobile-friendly           |
| `API_RATE_LIMIT_PER_MINUTE` | **20**                   | Protect key with 10 users |
| Uvicorn workers             | **1**                    | One process               |
| Cache                       | On, `CACHE_MAX_SIZE=128` | Avoid repeat LLM spend    |


**Concurrency guard (10 users):**

- Java: max **2–3** in-flight CV generates globally (queue or 429 `AI_BUSY`).  
- Per user: **1** CV generate at a time.  
- Chatbot: **stub only** — no DeepSeek calls for chat (saves key cost + RAM).



### 3.6 Disk / “no big spaces”


| Action                           | Detail                                                  |
| -------------------------------- | ------------------------------------------------------- |
| Prefer `alpine` images           | Already used for postgres/redis/rabbitmq                |
| MinIO data                       | Named volume OK; **do not** mount huge host folders     |
| Build cache                      | Periodic `docker builder prune` / `docker system prune` |
| Logs                             | `json-file` max-size **10m**, max-file **2**            |
| Skip map-service                 | No Google Places bill / extra JVM                       |
| Run all Vithey services          | Profile M — still use small heaps                       |
| Skip GDCE / general-service only | No second AI stack on disk or RAM                       |
| Skip local LLM                   | No Ollama / GGUF — API key only                         |




### 3.7 Optional: run without Docker for AI-only day

If Docker is too heavy, a **dev day** mode:

1. Infra only in Docker: Postgres + Redis (+ Eureka/Config if required).
2. Run **ai-service** + **gateway** + **auth/profile/content** as local JAR/`mvn spring-boot:run` with small heaps.
3. Run `ai_core` with `python main.py serve --port 8100`.

Document exact commands in build phase — choose one approach and stick to it for the demo.

---



## 4. Backend work — what to build (AI-focused)



### 4.1 P0 — Auto-Create CV (must have for demo)

**New endpoint (Spring ai-service):**

`POST /api/v1/ai/cv/generate`

**Flow:**

1. Gateway validates JWT → `X-User-Id`.
2. ai-service loads:
  - Profile from user-profile (`/users/me` internal or existing client).  
  - Recent posts from content (limit **20**, text-only).
3. If profile too empty → return Flutter-friendly `incomplete_profile` draft (no LLM call).
4. Else call `ai_core` `POST /api/v1/cv/generate` with `{ posts, profile, target_role?, language }`.
5. Map `StandardCV` → Flutter `AiCvDraft` (flat lists/strings).
6. Optionally store last generate meta in `ai_db` (request id, quality score) — keep table tiny.
7. Return Vithey envelope `{ data: AiCvDraft-shaped JSON, meta }`.

**Mapper rules (StandardCV → AiCvDraft):**


| Flutter field             | From StandardCV                                               |
| ------------------------- | ------------------------------------------------------------- |
| `full_name`               | `contact.full_name`                                           |
| `summary`                 | `summary`                                                     |
| `skills`                  | flatten skill groups → list of strings                        |
| `education`               | each item → one display string                                |
| `experience`              | each item → one display string                                |
| `projects`                | each item → one display string                                |
| `contact`                 | email / phone / links joined string                           |
| `incomplete_profile`      | true when inputs insufficient                                 |
| `quality` (optional meta) | `quality.score` / `grade` in `meta`, not required by UI today |


**Also:**

- Config: `AI_CORE_BASE_URL=http://ai-core:8100` (Docker) / `http://localhost:8100` (local).  
- Health: degrade gracefully if `ai_core` down → clear error code `AI_CORE_UNAVAILABLE`.  
- Keep `POST /ai/cv/suggest` on **stub** for demo (no GDCE).  
- Fail clearly if `DEEPSEEK_API_KEY` missing on `ai_core` (`AI_KEY_MISSING` / degraded health).

**Flutter (after backend ready):**

- Wire `AiRepository.generateCvDraft()` to `POST /ai/cv/generate`.  
- Set `USE_MOCK_AI=false` only when gateway + ai-service + `ai_core` + API key are up.



### 4.2 P1 — Vithey AI chatbot stub (NO GDCE RAG)

**Note:** Peer **chat-service** is **live**. This section is only the **Vithey AI** assistant inside `ai-service`.

**Locked:** Vithey AI does **not** call DeepSeek or GDCE. Spring `ai-service` returns short Markdown stubs by `topic` (`CV`, `JOB`, `INTERVIEW`, `STUDENT`, `FINANCE`) so the AI screen still demos sessions/history.


| Item                         | Action                                                                     |
| ---------------------------- | -------------------------------------------------------------------------- |
| Disable RAG client           | Config: no `GENERAL_SERVICE_URL` / feature flag `vithey.ai.chat.mode=stub` |
| Non-stream chat              | `POST /ai/chat` → stub reply + persist session/message                     |
| Sessions list/delete         | Keep working against Postgres `ai_db`                                      |
| Stream / regenerate / cancel | Optional; stream can fake token-chunk the stub text                        |
| Rate limit                   | Soft ~30 chat req/min/user                                                 |
| Cost                         | **$0** LLM for chatbot (API key used only by `ai_core` CV)                 |




### 4.3 P2 — Light product AI (only if time)

Keep **rule-based** (no new LLM cost) so PC stays light:


| Endpoint                          | Logic (demo)                                                              |
| --------------------------------- | ------------------------------------------------------------------------- |
| `POST /ai/jobs/{jobPostId}/match` | Overlap applicant skills vs job post skills → score 0–100 + gaps          |
| `GET /ai/skills/score`            | Score from profile skills + post activity counts                          |
| `GET /ai/feed/recommendations`    | Simple ranking: follow graph + skill tags (or skip and keep Flutter mock) |




### 4.4 Supporting backend — all services live (Profile M)

Every Vithey domain service runs for the demo. Roles:


| Service              | Why live                                 |
| -------------------- | ---------------------------------------- |
| api-gateway          | Single entry for Flutter                 |
| auth-service         | Login → JWT, student verify              |
| user-profile-service | Profile, skills, settings, people search |
| file-service + MinIO | Avatars, post media, CV files            |
| content-service      | Feed, posts, jobs posts, comments        |
| career-service       | Job applications + CV metadata           |
| finance-service      | Fees / payments (STUDENT)                |
| chat-service         | Peer messaging + STOMP `/ws`             |
| notification-service | Inbox (+ FCM optional)                   |
| map-service          | Nearby places (needs Places key)         |
| ai-service           | Vithey AI stub chat + CV generate facade |
| ai_core              | DeepSeek CV pipeline (API key)           |


**Must stay down (only):** GDCE / `general-service` (not a Vithey service).

### 4.5 Auth / seed data for 10 users

- Create **10 seed accounts** (script or SQL) with sample posts + filled profiles.  
- At least **2–3 profiles** rich enough to generate a good CV.  
- 1 “empty profile” user to demo incomplete-profile path.  
- Demo passwords only; **never commit** secrets.  
- Put `DEEPSEEK_API_KEY` only in local `ai_core/.env` (and optionally a gitignored backend env) on **your computer**.

---



## 5. Phased delivery (backend first)



### Phase 0 — Review & freeze (this file)

**Owner:** You  
**Exit:** Plan approved; Profile M (all live) + API key + no-GDCE locked.

Deliverables:

- [x] Profile **M** — all Vithey services live  
- [x] Finance / peer-chat / notification / map **ON**  
- [x] No GDCE RAG — Vithey AI chat stub  
- [x] AI = DeepSeek **API key** on local PC  
- [ ] Confirm key exists in `ai_core/.env` before Phase 2 smoke  
- [ ] Confirm PC RAM ≥ 16 GB (or accept tight 12 GB caps)  
- [ ] Final sign-off §14 to start Phase 1  

---



### Phase 1 — Demo infra full pack (Profile M on your PC)

**Owner:** Backend / DevOps  
**Exit:** **All** Vithey services + `ai_core` boot on **your computer** under memory caps; healthchecks green; **no GDCE**.

Tasks:

1. Add `docker-compose.demo.yml` (or override) with memory limits from §3.3 for **every** container.
2. Profile M service list: auth, profile, file, content, career, finance, chat, notification, map, ai-service, gateway + `ai_core` (`DEEPSEEK_API_KEY` via env).
3. Explicitly **exclude only** GDCE / `general-service`.
4. Shared Postgres tuning (`max_connections` high enough for all apps, still ≤ ~80) + log rotation.
5. Document: `docker compose -f docker-compose.yml -f docker-compose.demo.yml up` from `backend/`.
6. Smoke: each service `/actuator/health`, Eureka registrations, Gateway `:8080`, `ai_core` `/health`.

**Do not** start Flutter integration yet.

---



### Phase 2 — Wire `ai_core` into Java ai-service (P0)

**Owner:** Backend  
**Exit:** Authenticated `POST /api/v1/ai/cv/generate` returns `AiCvDraft` JSON via gateway.

Tasks:

1. Add `AiCoreClient` (WebClient/RestClient) + config properties.
2. Add aggregate helpers (profile + posts) — prefer existing internal HTTP clients; timeout short (2–3s).
3. Implement generate use-case + mapper + incomplete-profile path.
4. Global semaphore (2–3 concurrent generates).
5. Unit/integration tests with mocked `ai_core` (no real DeepSeek in CI).
6. Manual Postman: login → generate CV for seed user.
7. Update outdated docs (`INTEGRATION.md`: Java is ai-service; Python is `ai_core` engine).

**API contract sketch:**

Request (demo — server loads posts if omitted):

```json
{
  "target_role": "Intern Software Engineer",
  "language": "en",
  "template_id": null
}
```

Response `data`:

```json
{
  "full_name": "Sok Dara",
  "summary": "...",
  "skills": ["Flutter", "Java"],
  "education": ["RUPP — BSc IT (2022–2026)"],
  "experience": ["ACLEDA — Intern (2025)"],
  "projects": ["Recycling Pickup App — ..."],
  "contact": "dara@aub.edu.kh | 012...",
  "template_id": null,
  "incomplete_profile": false,
  "incomplete_message": null
}
```

`meta` may include `quality_score`, `quality_grade`, `request_id`.

---



### Phase 3 — Chat stub mode (P1, no GDCE)

**Owner:** Backend  
**Exit:** Chatbot works through gateway with **stub replies only**; no call to `general-service`.

Tasks:

1. Add config `vithey.ai.chat.mode=stub` (default for demo).
2. Implement topic-based Markdown stubs; disable / do not start `GeneralRetrievalClient` in demo profile.
3. Verify `POST /ai/chat` + sessions with JWT through gateway.
4. Optional: lower session history size for demo DB.
5. Postman collection for AI module (CV generate + stub chat).

---



### Phase 4 — Flutter live switch (integration)

**Owner:** Frontend (after backend demo works)  
**Exit:** Auto-Create CV screen uses live API; chatbot optional live.

Tasks:

1. Add/confirm endpoint constant `/ai/cv/generate`.
2. Implement live `generateCvDraft()` parsing.
3. `.env` for emulator: `API_BASE_URL=http://10.0.2.2:8080/api/v1`, `USE_MOCK_AI=false`.
4. Demo script: login seed user → AI Create CV → edit → (optional) apply.

---



### Phase 5 — Optional P2 rule-based AI

Only if Phases 1–4 are stable and time remains.

---



## 6. Integration contract (Flutter ↔ Backend ↔ ai_core)


| Caller     | Callee                 | Path                          | Notes                         |
| ---------- | ---------------------- | ----------------------------- | ----------------------------- |
| Flutter    | Gateway                | `POST /api/v1/ai/cv/generate` | JWT required                  |
| Gateway    | ai-service             | same path                     | `lb://ai-service`             |
| ai-service | user-profile / content | internal fetch                | aggregate inputs              |
| ai-service | ai_core                | `POST /api/v1/cv/generate`    | no user JWT                   |
| ai_core    | DeepSeek API           | HTTPS                         | `DEEPSEEK_API_KEY`            |
| Flutter    | Gateway                | `POST /api/v1/ai/chat`        | stub reply                    |
| ai-service | *(none)*               | —                             | **No GDCE / general-service** |


**Envelope:** `{ data, meta?, error? }`, snake_case — Vithey standard.  
**ai_core envelope:** `{ success, data, meta }` — Java adapts to Vithey envelope for Flutter.

---



## 7. Demo day runbook (10 users)



### 7.1 Boot order

1. Postgres, Redis, RabbitMQ, MinIO
2. Eureka, Config Server
3. auth → profile → file → content → career → ai-service
4. `ai_core` (`python main.py serve --port 8100` or container)
5. api-gateway last
6. Flutter with live `.env`



### 7.2 Pre-demo checks

```text
[ ] Running on YOUR PC only (Profile M compose — all Vithey services)
[ ] GDCE / general-service NOT running
[ ] auth, profile, file, content, career, finance, chat, notification, map, ai all healthy
[ ] Gateway health 8080
[ ] Login seed user works
[ ] GET /users/me returns profile
[ ] User has ≥3 posts with real text
[ ] Finance / peer-chat / notifications smoke OK
[ ] ai_core/.env has DEEPSEEK_API_KEY
[ ] POST /ai/cv/generate returns draft < 60s
[ ] Vithey AI POST /ai/chat returns STUB reply (no RAG)
[ ] docker stats — total RAM under Profile M budget (~10–12 GB stack)
```



### 7.3 During demo (10 users)

- Prefer **one CV generate at a time** on stage; others use stub chatbot / browse feed.  
- If `AI_BUSY` / 429 → show friendly “AI is busy, try again”.  
- Demo Finance, peer Chat, Notifications, Map as live backend features.  
- Do not run Android emulator + full Docker on ≤12 GB RAM machine — use a phone.



### 7.4 Tear down

```bash
docker compose -f docker-compose.yml -f docker-compose.demo.yml down
# optional: docker compose down -v   # wipes demo data volumes
```

---



## 8. Out of scope (demo — do not build now)

- **GDCE stack /** `general-service` **RAG** (locked out)  
- Kubernetes / multi-node / autoscaling / cloud deploy for demo  
- Local LLM (Ollama, vLLM, GPU) — **API key only**  
- Using DeepSeek for Vithey AI chatbot (chatbot = stub; key reserved for CV)  
- Skipping Vithey domain services (Profile S) — **not allowed**; all must run  
- PDF/OCR CV parsing  
- Real production FCM scale, HA Redis/Postgres  
- Google OAuth / 2FA  
- map-service Google Places  
- Full feed ML recommendations  
- Expanding `ai_core` into chat/RAG  
- Per-service Postgres containers  
- Large MinIO / media stress tests

---



## 9. Success criteria


| #   | Criterion                                             | Pass                                |
| --- | ----------------------------------------------------- | ----------------------------------- |
| 1   | Full Profile M stack runs on your PC without thrash   | RAM stable 15+ min                  |
| 2   | 10 users can login and browse                         | No mass 500s                        |
| 3   | Seed user generates CV via live API                   | Draft matches profile/posts         |
| 4   | Empty profile returns incomplete message              | No wasted LLM call                  |
| 5   | Concurrent CV capped                                  | Extra requests get clear busy error |
| 6   | Chatbot answers **stub** reply (no GDCE)              | Demo path works                     |
| 7   | Flutter Auto-Create CV works with `USE_MOCK_AI=false` | End-to-end                          |


---



## 10. Risk & mitigations


| Risk                                         | Mitigation                                                                    |
| -------------------------------------------- | ----------------------------------------------------------------------------- |
| PC OOM / freeze                              | Profile M + **strict** memory limits + SerialGC small heaps; prefer 16 GB+ PC |
| DeepSeek slow/down / bad key                 | Timeouts, clear errors, check `.env` before demo                              |
| Token cost                                   | flash model, max 20 posts, rate limits; **Vithey AI chat = stub (no tokens)** |
| Someone starts GDCE by habit                 | Compose demo file omits it; docs say stub-only                                |
| Too many JVMs                                | Cap each service 256–384m heap; one shared Postgres                           |
| Microservice complexity                      | Still one compose; all services required                                      |
| Schema mismatch Flutter vs StandardCV        | Explicit mapper in Java + contract test                                       |
| Docs say Python is ai-service / RAG required | Fix docs in Phase 2–3                                                         |


---



## 11. File / module touch list (when build starts)


| Area             | Paths                                                                             |
| ---------------- | --------------------------------------------------------------------------------- |
| Plan (this file) | `plan.md`                                                                         |
| Demo compose     | `backend/docker-compose.demo.yml` (new)                                           |
| ai-service       | `backend/services/ai-service/...` (client, controller, mapper, config, chat stub) |
| Config           | `backend/infrastructure/config-repo/ai-service.yml`                               |
| ai_core          | demo `.env` limits + `DEEPSEEK_API_KEY`                                           |
| Flutter          | `ai_repository.dart`, `ai_service.dart`, `api_endpoints.dart`, `.env`             |
| Docs             | `prompt/.../ai-service/INTEGRATION.md`, Postman AI collection                     |
| Seeds            | SQL or script under `backend/infrastructure/scripts/`                             |
| Chat stub        | `vithey.ai.chat.mode=stub` (no GDCE client)                                       |
| Secrets          | `ai_core/.env` with `DEEPSEEK_API_KEY` (gitignored, on your PC only)              |


---


|     |
| --- |


---



## 13. Decisions log (answered)


| #   | Question                                  | Answer (locked)                               |
| --- | ----------------------------------------- | --------------------------------------------- |
| 1   | Where to run?                             | **Your local computer**                       |
| 2   | Which services live?                      | **All Vithey services** → **Profile M**       |
| 3   | Finance / peer-chat / notification / map? | **Yes — live**                                |
| 4   | GDCE `general-service` RAG?               | **No** → Vithey AI **chat stub**              |
| 5   | How does AI authenticate?                 | **DeepSeek API key** in local `.env`          |
| 6   | DeepSeek model                            | `deepseek-v4-flash` (default)                 |
| 7   | CV language                               | `en` **first**; add `km` only if needed later |
| 8   | Ready for Phase 1?                        | Pending your final ✅ in §14                   |


---



## 14. Approval


| Role          | Name | Date | Sign-off                                            |
| ------------- | ---- | ---- | --------------------------------------------------- |
| Product / you |      |      | [x] Build started (Phases 1-4)                      |
| Backend       |      |      | [x] Profile **M** — all services live agreed        |
| AI            |      |      | [x] API key + `ai_core` limits + **no GDCE** agreed |


**Landed:** demo compose + ai_core Dockerfile + `POST /ai/cv/generate` + chat stub + Flutter CV wire-up.

**Your next step:** set `DEEPSEEK_API_KEY` in `ai_core/.env`, then from `backend/` run `.\scripts\docker-up-demo.ps1`.