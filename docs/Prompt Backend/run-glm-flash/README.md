# GLM 5.3 Flash — 10 terminals (one service each)

Copy **one prompt per new GLM chat**. Run all **10 in parallel**. Same style as `Prompt Frontend/run-glm-flash/`.

Learn first: [`../LEARNING.md`](../LEARNING.md)

## 10 terminals = 10 domain services

| Terminal | Prompt | Port | Job |
|----------|--------|------|-----|
| 1 | [`01-auth-service.md`](01-auth-service.md) | 8081 | Upgrade — change password |
| 2 | [`02-user-profile-service.md`](02-user-profile-service.md) | 8082 | Complete — do not add startup API |
| 3 | [`03-file-service.md`](03-file-service.md) | 8083 | Complete / verify |
| 4 | [`04-content-service.md`](04-content-service.md) | 8084 | Upgrade — delete comment |
| 5 | [`05-career-service.md`](05-career-service.md) | 8085 | Upgrade — CV preview |
| 6 | [`06-finance-service.md`](06-finance-service.md) | 8086 | Complete / verify STUDENT gate |
| 7 | [`07-chat-service.md`](07-chat-service.md) | 8087 | Complete / verify REST + STOMP |
| 8 | [`08-notification-service.md`](08-notification-service.md) | 8088 | Upgrade — UI inbox contract |
| 9 | [`09-ai-service.md`](09-ai-service.md) | 8089 | Upgrade — stream / regenerate / cancel |
| 10 | [`10-map-service.md`](10-map-service.md) | 8090 | **Create** (no Java yet) + own wiring |

Gateway (`8080`) and infra (Eureka `8761`, Config `8888`) already exist. **Do not** give them an 11th GLM chat that edits every service.

## How to run (parallel)

1. Open **10 new Cursor / GLM chats** (10 Agent tabs).
2. In each chat, copy **everything below the `---` line** in that numbered file.
3. Start all 10. Do not wait for one to finish.

Or open 10 Windows Terminal tabs that print the file path:

```powershell
cd "D:\project\Acleda Mobile App\prompt\Prompt Backend\run-glm-flash"
.\open-10-terminals.ps1
```

## Parallel safety (so they do not fight)

Each chat may edit **only**:

```text
backend/services/<this-service>/**
prompt/Prompt Backend/services/<this-service>/**
```

| Shared file | Who may edit |
|-------------|--------------|
| `backend/pom.xml` | **Terminal 10 only** (add `map-service` module) |
| `backend/infrastructure/scripts/init-databases.sql` | **Terminal 10 only** (`map_db`) |
| `backend/infrastructure/config-repo/map-service.yml` | **Terminal 10 only** |
| `backend/infrastructure/config-repo/api-gateway.yml` | **Terminal 10 only** (`/places/**`) |
| `backend/services/api-gateway/**` | **Terminal 10 only** (places route in `application.yml`) |
| `integration-contract.md` | **Nobody** in this pack |
| `vithey_app/**` | **Nobody** |

After all 10 merge, run sequential pack Prompt 3 if contract/DevOps/Postman still need a pass: `../run-complete/03-wire-gateway-contract-devops.md`.

## Do not create

No `search-service`, `jobs-service`, Google OAuth, or startup-onboarding API.
