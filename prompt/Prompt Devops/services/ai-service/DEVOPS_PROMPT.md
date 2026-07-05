# AI Service — DevOps Prompt (Integration Only)

> Python chatbot/AI is built **outside** the Vithey Java repo.  
> No Maven module, no Java Docker image, no `ai-service-ci.yml` in Java repo.

## What Java DevOps provides

| Item | Location |
| --- | --- |
| Gateway route | `services/api-gateway` — `/api/v1/ai/**` → `lb://ai-service` |
| Eureka | `infrastructure/eureka-server` |
| Integration docs | `services/ai-service/INTEGRATION.md` |
| Network example | `services/ai-service/docker-compose.integration.example.yml` |

## What you do in your Python project

1. Docker image for your Python `ai-service`
2. `docker-compose.yml` joining `vithey-network` (and optionally `gdce-network`)
3. Register Eureka name `ai-service` on port 8089
4. CI with pytest in **your Python repo** (not Vithey Java CI)

## Verification

```powershell
# Vithey infrastructure + gateway running
curl http://localhost:8761/eureka/apps/AI-SERVICE
curl http://localhost:8089/actuator/health
curl -X POST http://localhost:8080/api/v1/ai/chat -H "Authorization: Bearer <token>" ...
```

## Optional: start your existing GDCE stack

```powershell
cd D:\GDCE-chatbot\chatbot_review\backend\api-layer\scripts
.\start-development.ps1 -SkipBuild
```

Your Python Vithey adapter must bridge `vithey-network` ↔ `gdce-network` if using GDCE upstream.
