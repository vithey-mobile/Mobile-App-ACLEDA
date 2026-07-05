# Infrastructure Architecture

## Responsibility

Infrastructure owns shared platform services only:

- Service discovery (`eureka-server`)
- Centralized configuration (`config-server` + `config-repo`)
- Shared messaging (`rabbitmq`)
- Shared data/cache/object storage for local development (`postgres`, `redis`, `minio`)

It does not own business REST APIs or per-service databases.

## Network

All shared infrastructure and business services join one external Docker network:

```text
vithey-network
```

Business service compose files declare:

```yaml
networks:
  vithey-network:
    external: true
```

## Startup order

1. Start `backend/infrastructure/docker-compose.yml`
2. Start each business service from `backend/services/<service>/docker-compose.yml`
3. API Gateway should start after the services it routes to are registered in Eureka

## Config rules

- Every service has a config file in `config-repo/` named after `spring.application.name`
- Config Server serves native files from `infrastructure/config-repo`
- Production secrets must come from environment variables
