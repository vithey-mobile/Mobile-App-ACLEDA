# Vithey Docker verification

Run after starting infrastructure + services.

```powershell
cd "D:\project\Acleda Mobile App\backend"
.\scripts\verify-docker.ps1
```

## Expected healthy stack

| Layer | Containers |
| --- | --- |
| Infrastructure | eureka, config, postgres, redis, rabbitmq, minio |
| Services | auth, user-profile, file, content, career, finance, chat, notification, api-gateway, ai-service |
| GDCE chatbot | general-service, qdrant-general, redis-general |

## Start order

See `RUN-SERVICES.md`.

## Common fixes

| Problem | Fix |
| --- | --- |
| Gateway unhealthy | `cd infrastructure && docker compose up -d redis` |
| file-service exited | Rebuild after MinioConfig fix |
| notification exited | Empty `FIREBASE_CREDENTIALS_PATH` is OK (push disabled) |
| Name conflict | `docker ps -a` then `docker rm -f <name>` |
| `vithey-network` not found | Start `infrastructure/` first |
