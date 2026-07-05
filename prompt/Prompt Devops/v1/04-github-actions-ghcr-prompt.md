# 04 - GitHub Actions GHCR Publish Prompt

Build **GitHub Actions workflow** to build Docker images and push to **GitHub Container Registry (ghcr.io)**.

## Goal
On merge to `main` (and manual dispatch), build all service images and publish to GHCR with proper tags.

## Depends On
- `02-dockerfiles-prompt.md`
- `03-github-actions-ci-prompt.md` passing

## Must Create
```text
.github/
└── workflows/
    └── docker-publish.yml
```

## GHCR Image Naming
```
ghcr.io/<github.repository_owner>/vithey-<service-name>:<tag>
```
Examples:
- `ghcr.io/kimheang-code-it/vithey-auth-service:latest`
- `ghcr.io/kimheang-code-it/vithey-auth-service:sha-a1b2c3d`
- `ghcr.io/kimheang-code-it/vithey-auth-service:v1.0.0`

## Workflow: `docker-publish.yml`

### Triggers
```yaml
on:
  push:
    branches: [main]
    paths:
      - 'vithey-backend/**'
      - '.github/workflows/docker-publish.yml'
  workflow_dispatch:
    inputs:
      services:
        description: 'Comma-separated services or "all"'
        default: 'all'
```

### Permissions
```yaml
permissions:
  contents: read
  packages: write
```

### Environment Variables
```yaml
env:
  REGISTRY: ghcr.io
  IMAGE_PREFIX: ghcr.io/${{ github.repository_owner }}/vithey
```

### Jobs

#### Job 1: `build-and-push` (matrix)
```yaml
strategy:
  matrix:
    include:
      - service: api-gateway
        context: vithey-backend/services/api-gateway
        port: 8080
      - service: auth-service
        context: vithey-backend/services/auth-service
        port: 8081
      # ... all services
      - service: eureka-server
        context: vithey-backend/eureka-server
        port: 8761
      - service: config-server
        context: vithey-backend/config-server
        port: 8888
```

#### Steps per matrix item
1. `actions/checkout@v4`
2. `docker/setup-buildx-action@v3`
3. `docker/login-action@v3` with:
   ```yaml
   registry: ghcr.io
   username: ${{ github.actor }}
   password: ${{ secrets.GITHUB_TOKEN }}
   ```
4. `docker/metadata-action@v5` for tags:
   - `type=raw,value=latest,enable={{is_default_branch}}`
   - `type=sha,prefix=sha-`
   - `type=ref,event=tag` (for releases)
5. `docker/build-push-action@v5`:
   ```yaml
   context: ${{ matrix.context }}
   push: true
   tags: ${{ steps.meta.outputs.tags }}
   labels: ${{ steps.meta.outputs.labels }}
   build-args: SERVICE_PORT=${{ matrix.port }}
   cache-from: type=gha
   cache-to: type=gha,mode=max
   ```

#### Job 2: `summary`
- Write job summary with list of pushed image URIs

## Package Visibility
Document how to set GHCR package to private:
- GitHub → Packages → Package settings → Change visibility

## Pull Image (for team)
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
docker pull ghcr.io/<owner>/vithey-auth-service:latest
```

## Path-Filtered Builds (optimization)
Only build services with changes in `vithey-backend/services/<name>/**` unless `workflow_dispatch` with `all`.

Use `dorny/paths-filter` output to skip unchanged services.

## Rules
- Use `GITHUB_TOKEN` — no extra PAT unless cross-repo.
- Lowercase image names (GHCR requirement).
- Do not push on PR — only `main` and tags.
- Sign images with `cosign` — optional, not required v1.

## Output
Working GHCR publish workflow + `docs/DEPLOYMENT.md` section on pulling images.
