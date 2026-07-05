# 07 - Per-Service GitHub Actions CI Prompt

Create **one GitHub Actions CI workflow per backend service** so each service can be tested, packaged, and Docker-built independently.

## Goal

Each backend service has its own CI file:

```text
.github/workflows/<service>-ci.yml
```

Examples:

```text
.github/workflows/auth-service-ci.yml
.github/workflows/content-service-ci.yml
.github/workflows/ai-service-ci.yml
```

## Read First

1. `Prompt Devops/COMMON_CONTEXT.md`
2. `Prompt Backend/services/<service>/KICKOFF_PROMPT.md`
3. `Prompt Backend/services/<service>/FOLDER_STRUCTURE.md`
4. `Prompt Devops/services/<service>/DEVOPS_PROMPT.md`

## Workflow Requirements

Each service workflow must:

- Trigger only when that service or shared backend build files change.
- Run Java 21 with Maven cache.
- Run unit/integration tests for that service.
- Build the service jar.
- Build the service Docker image locally.
- Validate the service-specific Docker Compose file if it exists.
- Upload test reports on failure.
- Never push images; GHCR publishing remains in `docker-publish.yml`.

## Standard Workflow Shape

```yaml
name: auth-service CI

on:
  push:
    branches: [main, Prompt, develop]
    paths:
      - 'vithey-backend/services/auth-service/**'
      - 'vithey-backend/pom.xml'
      - 'vithey-backend/config-repo/auth-service.yml'
      - 'vithey-backend/infrastructure/docker-compose.auth-service.yml'
      - '.github/workflows/auth-service-ci.yml'
  pull_request:
    branches: [main, Prompt, develop]
    paths:
      - 'vithey-backend/services/auth-service/**'
      - 'vithey-backend/pom.xml'
      - 'vithey-backend/config-repo/auth-service.yml'
      - 'vithey-backend/infrastructure/docker-compose.auth-service.yml'
```

## Required Jobs

| Job | Purpose |
| --- | --- |
| `test` | Maven tests for one service |
| `docker-build` | Build local Docker image |
| `compose-validate` | `docker compose -f vithey-backend/infrastructure/docker-compose.<service>.yml config` |

## Maven Command

Prefer parent-module build when the backend parent POM exists:

```bash
mvn -B -f vithey-backend/pom.xml -pl services/<service> -am test
```

If the service is standalone:

```bash
mvn -B -f vithey-backend/services/<service>/pom.xml test
```

## Docker Build Command

```bash
docker build \
  --build-arg SERVICE_PORT=<port> \
  -t vithey-<service>:ci \
  vithey-backend/services/<service>
```

## Output

One independent workflow per service plus documentation in `vithey-backend/docs/LOCAL_DEV.md` explaining which workflow protects which service.

