# AI Service (Java) — Vithey chatbot + GDCE general

Spring Boot service that connects Vithey chatbot to GDCE **`general-service`** only.

## Architecture

```text
Flutter → API Gateway :8080 → ai-service :8089 → general-service :8005
```

**Not required:** orchestrator, api-layer, retrieval (8003).

## Run

```powershell
# 1 GDCE general (chatbot brain)
cd "D:\GDCE-chatbot\chatbot_review\services_version2\general"
docker network create gdce-network
docker compose up -d --build

# 2 Stop other GDCE AI containers (optional)
cd "D:\project\Acleda Mobile App\backend\services\ai-service"
.\scripts\stop-other-gdce-services.ps1

# 3 Vithey ai-service (needs infrastructure + gateway on vithey-network)
docker network create vithey-network
copy .env.example .env
docker compose up -d --build
```

## Maven build (local)

```powershell
cd "D:\project\Acleda Mobile App\backend"
mvn clean package -DskipTests -pl services/ai-service -am
```

## Key Java files

| File | Role |
| --- | --- |
| `client/GeneralRetrievalClient.java` | Calls GDCE `POST /retrieval/retrieve` |
| `service/AiChatService.java` | Chat + sessions |
| `service/CvSuggestionService.java` | CV suggest via general |
| `controller/AiChatController.java` | Vithey API |

## Docs

- `API.md` — API contract
- `INTEGRATION-GENERAL.md` — Full integration guide
