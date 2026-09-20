# Local Development

Repo root on this machine: `D:\Projects\Mobile\Mobile-App-ACLEDA`

## Preferred: full stack

```powershell
cd D:\Projects\Mobile\Mobile-App-ACLEDA\backend
.\scripts\start-all.ps1
```

This starts infra + all Java services + `ai_core`, sets `MINIO_PUBLIC_ENDPOINT` to your LAN IP, and updates `vithey_app/.env` API/WS URLs.

Verify:

```powershell
.\scripts\verify-docker.ps1
Invoke-RestMethod http://localhost:8080/actuator/health
Invoke-RestMethod http://localhost:8100/health
```

## Incremental (optional)

### 1. Shared infrastructure only

```powershell
cd D:\Projects\Mobile\Mobile-App-ACLEDA\backend
.\scripts\start-all.ps1 -InfraOnly
# or:
cd D:\Projects\Mobile\Mobile-App-ACLEDA\backend\infrastructure
docker compose up -d --build
```

### 2. One Java service

```powershell
cd D:\Projects\Mobile\Mobile-App-ACLEDA\backend
.\scripts\docker-build-service.ps1 auth-service -Up
```

Available names: see `_shared/SERVICE_REGISTRY.md`.

## Flutter app

```powershell
cd D:\Projects\Mobile\Mobile-App-ACLEDA\vithey_app
flutter pub get
flutter run
```

- Emulator: `API_BASE_URL=http://10.0.2.2:8080/api/v1`
- Physical phone: use LAN IP (written by `start-all.ps1`)
- Feature flags live in `.env` → `FeatureFlags` (`USE_MOCK_*`, `ENABLE_GOOGLE_AUTH`, etc.)

## Stop

```powershell
cd D:\Projects\Mobile\Mobile-App-ACLEDA\backend
.\scripts\start-all.ps1 -Down
```

## Build without Docker (Java)

```powershell
cd D:\Projects\Mobile\Mobile-App-ACLEDA\backend
mvn clean install
mvn -pl services/auth-service spring-boot:run
```

Non-Docker JVM runs still need shared infrastructure containers on localhost (or `start-dev-host.ps1`).
