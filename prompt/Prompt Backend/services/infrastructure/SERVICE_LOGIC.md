# Infrastructure — Service Logic

## Ownership

Owns Spring Cloud infrastructure: Eureka Server, Config Server, shared config repo, and dev database initialization script.

Does not own domain REST APIs.

## Startup order

1. Start PostgreSQL, Redis, RabbitMQ, and MinIO from DevOps prompts.
2. Run `scripts/init-databases.sql`.
3. Start Eureka Server on port `8761`.
4. Start Config Server on port `8888`.
5. Start domain services; each loads config and registers with Eureka.
6. Start API Gateway last; gateway routes to `lb://service-name`.

## Config Server rules

- Use native profile for local dev.
- Search locations: `file:./config-repo` and `classpath:/config-repo`.
- Every service has one config file named after `spring.application.name`.
- Secrets must come from environment variables in production.

## Eureka rules

- Eureka Server does not register with itself.
- Domain services and gateway register as clients.
- Health checks must be visible from `/actuator/health`.

## Verification

- `curl http://localhost:8761/actuator/health`
- `curl http://localhost:8888/auth-service/default`
- Start one domain service and confirm it appears in Eureka dashboard.

