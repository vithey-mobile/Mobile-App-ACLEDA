# 02 - Dockerfiles Prompt

Create **multi-stage Dockerfiles** for every Vithey backend service and infrastructure module.

## Goal
Optimized, secure, consistent container images for local build and GHCR publish.

## Depends On
- `01-local-docker-compose-prompt.md`
- Maven projects exist per service

## Must Create
One `Dockerfile` per buildable module:
```text
vithey-backend/
├── eureka-server/Dockerfile
├── config-server/Dockerfile
└── services/
    ├── api-gateway/Dockerfile
    ├── auth-service/Dockerfile
    ├── user-profile-service/Dockerfile
    ├── file-service/Dockerfile
    ├── content-service/Dockerfile
    ├── career-service/Dockerfile
    ├── finance-service/Dockerfile
    ├── chat-service/Dockerfile
    ├── notification-service/Dockerfile
    └── ai-service/Dockerfile
```

## Standard Java Dockerfile Template
Apply to all Spring Boot services (adjust `EXPOSE` port per service):

```dockerfile
# syntax=docker/dockerfile:1

FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN apk add --no-cache maven && \
    mvn -B -q -DskipTests package && \
    mv target/*.jar app.jar

FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app
RUN apk add --no-cache wget && \
    addgroup -S vithey && adduser -S vithey -G vithey
USER vithey
COPY --from=build /build/app.jar app.jar

ARG SERVICE_PORT=8080
ENV SERVER_PORT=${SERVICE_PORT}
EXPOSE ${SERVICE_PORT}

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD wget -qO- "http://localhost:${SERVER_PORT}/actuator/health" | grep -q '"status":"UP"' || exit 1

ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-jar", "app.jar"]
```

## Per-Service EXPOSE Ports
| Service | SERVICE_PORT build-arg |
|---------|------------------------|
| api-gateway | 8080 |
| auth-service | 8081 |
| user-profile-service | 8082 |
| file-service | 8083 |
| content-service | 8084 |
| career-service | 8085 |
| finance-service | 8086 |
| chat-service | 8087 |
| notification-service | 8088 |
| ai-service | 8089 |
| eureka-server | 8761 |
| config-server | 8888 |

## `.dockerignore` Per Service
```
target/
.git/
.idea/
*.iml
.env
.env.*
**/*.md
```

## Optional: Parent POM Build
If monorepo parent POM exists, support:
```dockerfile
COPY pom.xml .
COPY services/auth-service/pom.xml services/auth-service/
RUN mvn -pl services/auth-service -am -DskipTests package
```

## Image Labels (OCI)
Add to each Dockerfile:
```dockerfile
LABEL org.opencontainers.image.source="https://github.com/Kimheang-code-IT/Mobile-App-ACLEDA"
LABEL org.opencontainers.image.title="vithey-auth-service"
LABEL org.opencontainers.image.vendor="Vithey App"
```

## Build Test Commands
```bash
docker build -t vithey-auth-service:local ./services/auth-service
docker run --rm -p 8081:8081 -e SPRING_PROFILES_ACTIVE=docker vithey-auth-service:local
```

## Rules
- Non-root user in runtime stage.
- No JDK in final image — JRE only.
- No secrets baked into images.
- Layer cache: copy `pom.xml` before `src/` for faster rebuilds.

## Output
All Dockerfiles build successfully with `docker compose build`.
