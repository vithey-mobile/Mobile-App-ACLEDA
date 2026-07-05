# 05 - Production-Ready Prompt

Prepare Vithey App for **future production deployment** using GHCR images — without VPS, Nginx, SSL, or monitoring stacks.

## Goal
Production compose template, release workflow, secrets documentation, and image-based deployment guide. Any Docker-capable host can run the stack later.

## Depends On
- `04-github-actions-ghcr-prompt.md` (images on GHCR)

## Must Create
```text
vithey-backend/
├── docker-compose.prod.yml
├── .env.prod.example
└── docs/
    └── DEPLOYMENT.md          # update/complete

.github/
└── workflows/
    └── release.yml
```

## `docker-compose.prod.yml`
Uses **pre-built GHCR images** — no `build:` directives.

```yaml
services:
  api-gateway:
    image: ghcr.io/${GHCR_OWNER}/vithey-api-gateway:${IMAGE_TAG:-latest}
    restart: unless-stopped
    env_file: .env
    ports:
      - "${GATEWAY_PORT:-8080}:8080"
    depends_on:
      - auth-service
    # ... healthcheck, networks
```

### Differences from Local Compose
| Aspect | Local (`docker-compose.yml`) | Prod (`docker-compose.prod.yml`) |
|--------|------------------------------|----------------------------------|
| Images | `build:` local | `image:` from GHCR |
| Postgres | Container included | Env var `DATABASE_URL` — external DB OK |
| Secrets | `.env` dev values | Strong secrets, never committed |
| Logging | Console | JSON to stdout (host captures) |
| Restart | default | `unless-stopped` |
| Ports | All exposed | Only gateway exposed externally |

### External Database Option
Document switching `SPRING_DATASOURCE_URL` to managed PostgreSQL (Railway, Supabase, AWS RDS) — no compose postgres service needed.

## `.env.prod.example`
```env
# Image source
GHCR_OWNER=your-github-username
IMAGE_TAG=latest

# Gateway (only public port)
GATEWAY_PORT=8080

# JWT — generate: openssl rand -base64 48
JWT_SECRET=

# Database (external or container)
POSTGRES_HOST=postgres
POSTGRES_USER=
POSTGRES_PASSWORD=

# Message broker
RABBITMQ_HOST=rabbitmq
RABBITMQ_USER=
RABBITMQ_PASS=

# Object storage (MinIO or S3-compatible)
MINIO_ENDPOINT=http://minio:9000
MINIO_ACCESS_KEY=
MINIO_SECRET_KEY=

# AI
AI_PROVIDER=openai
AI_API_KEY=

# FCM (base64 encoded service account JSON)
FIREBASE_CREDENTIALS_BASE64=

# CORS — mobile app domain
CORS_ORIGINS=https://your-app-domain.com
```

## Workflow: `release.yml`
```yaml
on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  release:
    # Reuse docker-publish matrix
    # Tag images with semver from git tag (v1.0.0 → 1.0.0)
    # Create GitHub Release with changelog template
```

### Release Tags on GHCR
- `v1.0.0` push → images tagged `1.0.0`, `1.0`, `1`, `latest`

## `docs/DEPLOYMENT.md` Contents
1. **Prerequisites** — Docker Engine 24+, docker compose v2, GHCR read access
2. **Pull images** — login + pull commands
3. **Configure** — copy `.env.prod.example` → `.env`, fill secrets
4. **Run** — `docker compose -f docker-compose.prod.yml up -d`
5. **Verify** — health check URL
6. **Update** — change `IMAGE_TAG`, `docker compose pull`, `up -d`
7. **Rollback** — set `IMAGE_TAG=sha-abc123` or previous semver
8. **Mobile app** — set production `API_BASE_URL` to gateway public URL

### Explicitly NOT Covered (link to future work)
- Server provisioning (VPS/cloud VM)
- Reverse proxy (Nginx)
- SSL certificates (Certbot)
- Metrics (Prometheus/Grafana)
- Log aggregation (Loki/ELK)

State: "Add these in a future DevOps phase when production host is chosen."

## GitHub Environments (optional)
Create `production` environment in GitHub with:
- Required reviewers for `release.yml`
- Secrets: `JWT_SECRET`, `AI_API_KEY`, `FIREBASE_CREDENTIALS_BASE64`

## Backup Notes (document only)
- Postgres: `pg_dump` cron example (no implementation required)
- MinIO: bucket replication note for future

## Smoke Test Script
`scripts/smoke-test.sh`:
```bash
#!/bin/sh
set -e
BASE_URL=${1:-http://localhost:8080}
curl -sf "$BASE_URL/actuator/health"
curl -sf -o /dev/null -w "%{http_code}" "$BASE_URL/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email_or_phone":"test","password":"test"}' | grep -E '401|400|200'
echo "Smoke test passed"
```

## Rules
- Prod compose must work with images only — no source build on server.
- All secrets via env — never in compose YAML values.
- Single public entry point: API Gateway port.
- Document Flutter `API_BASE_URL` for prod builds.

## Verification Checklist
- [ ] `docker compose -f docker-compose.prod.yml config` valid
- [ ] Pull GHCR images and start stack locally with prod compose
- [ ] `release.yml` tags images on `v*` git tag
- [ ] DEPLOYMENT.md complete without VPS/Nginx instructions

## Output
Production-ready image deployment path using GHCR + compose template.
