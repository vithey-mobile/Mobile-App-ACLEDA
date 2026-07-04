# 03 - GitHub Actions CI Prompt

Build **GitHub Actions CI** workflow for Vithey App — test and compile on every PR and push.

## Goal
Automated quality gate: Maven test + build for all backend services without publishing images yet.

## Depends On
- `02-dockerfiles-prompt.md`
- GitHub repo: `Kimheang-code-IT/Mobile-App-ACLEDA` (or org repo)

## Must Create
```text
.github/
└── workflows/
    ├── ci.yml
    └── <service>-ci.yml       # added by prompt 07 for independent service CI
```

## Workflow: `ci.yml`

### Triggers
```yaml
on:
  push:
    branches: [main, Prompt, develop]
    paths:
      - 'vithey-backend/**'
      - '.github/workflows/ci.yml'
  pull_request:
    branches: [main, Prompt, develop]
    paths:
      - 'vithey-backend/**'
```

### Permissions
```yaml
permissions:
  contents: read
```

### Jobs

#### Job 1: `detect-changes`
- Use `dorny/paths-filter` or manual path check
- Output which services changed for matrix

#### Job 2: `backend-test` (matrix)
```yaml
strategy:
  fail-fast: false
  matrix:
    service:
      - api-gateway
      - auth-service
      - user-profile-service
      - file-service
      - content-service
      - career-service
      - finance-service
      - chat-service
      - notification-service
      - ai-service
```
- Runs only if service path changed OR manual full build
- Steps:
  1. `actions/checkout@v4`
  2. `actions/setup-java@v4` with Java 21, Maven cache
  3. `mvn -B -f vithey-backend/services/${{ matrix.service }} test`
  4. Upload test reports artifact on failure

#### Job 3: `infrastructure-test`
- Build eureka-server + config-server
- `mvn -B test` if tests exist, else `mvn -B package -DskipTests`

#### Job 4: `compose-validate`
- Install Docker
- `docker compose -f vithey-backend/docker-compose.yml config`
- Fails if compose YAML invalid

#### Job 5: `flutter-analyze` (optional, if frontend in repo)
```yaml
- uses: subosito/flutter-action@v2
- run: flutter analyze
  working-directory: aub_connect_app
```
Only on `aub_connect_app/**` path changes.

## Environment for Tests
```yaml
env:
  JWT_SECRET: ci-test-secret-minimum-32-characters-long
  SPRING_PROFILES_ACTIVE: test
```

Use Testcontainers in service tests — GitHub hosted runners support Docker.

## Branch Protection Recommendation
Document in `docs/LOCAL_DEV.md`:
- Require `ci.yml` to pass before merge to `main`

## Rules
- No GHCR push in this workflow — that is prompt 04.
- Cache Maven: `actions/setup-java` with `cache: maven`
- Timeout: 15 min per job
- Concurrency: cancel in-progress on same PR
- Keep `ci.yml` as the full backend gate; prompt `07` creates one workflow per service for focused checks.

## Output
Working `ci.yml` that runs on push/PR.
