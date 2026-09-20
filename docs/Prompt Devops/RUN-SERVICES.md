# Run Vithey — Service Start Order

> **Moved:** full commands are in [DOCKER.md](DOCKER.md).  
> **Registry:** [_shared/SERVICE_REGISTRY.md](../_shared/SERVICE_REGISTRY.md)

## Quick reference

1. Prefer one command: `backend/scripts/start-all.ps1` (infra + domain services + **ai_core** + gateway)
2. Incremental alternative: `backend/infrastructure/` first, then domain services in registry order, gateway last
3. map-service is **opt-in** (Compose profile `map`)

## Start all

```powershell
cd backend
.\scripts\start-all.ps1
```

## Verify

```powershell
.\scripts\verify-docker.ps1
.\scripts\smoke-api.ps1
```

See [DOCKER-VERIFY.md](DOCKER-VERIFY.md) for fixes.
