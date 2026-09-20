# Run Vithey — Service Start Order

> **Moved:** full commands are in [DOCKER.md](DOCKER.md).  
> **Registry:** [_shared/SERVICE_REGISTRY.md](../_shared/SERVICE_REGISTRY.md)

## Quick reference

1. `backend/infrastructure/` — shared infra (creates `vithey-network`)
2. Domain services in registry order (auth → … → notification → ai)
3. `backend/services/api-gateway/` — last

## Start all

```powershell
cd backend
.\scripts\start-all.ps1
```

## Verify

```powershell
.\scripts\verify-docker.ps1
```

See [DOCKER-VERIFY.md](DOCKER-VERIFY.md) for fixes.
