# Auth Service

Spring Boot service for Vithey account registration, login, JWT issuing, refresh token rotation, password reset, and AUB student verification.

## Run

```bash
mvn -pl services/auth-service -am spring-boot:run
```

Default port: `8081`

Swagger: `http://localhost:8081/swagger-ui.html`

Health: `http://localhost:8081/actuator/health`

## Environment

| Variable | Default |
| --- | --- |
| `AUTH_DB_URL` | `jdbc:postgresql://localhost:5432/auth_db` |
| `AUTH_DB_USERNAME` | `postgres` |
| `AUTH_DB_PASSWORD` | `postgres` |
| `VITHEY_JWT_SECRET` | local development secret |
| `CONFIG_SERVER_URL` | `http://localhost:8888` |
| `EUREKA_URL` | `http://localhost:8761/eureka/` |
| `EUREKA_CLIENT_ENABLED` | `false` |
| `RABBITMQ_HOST` | `localhost` |

## Build

```bash
mvn -pl services/auth-service -am clean verify
```

## Docker

Run this service with its own containers:

```powershell
cd "D:\project\Acleda Mobile App\backend\services\auth-service"
copy .env.example .env
docker compose up -d --build
```

Requires shared infrastructure and the external Docker network `vithey-network`:

```powershell
cd "D:\project\Acleda Mobile App\backend\infrastructure"
docker compose up -d --build
```

Verify:

```powershell
Invoke-RestMethod http://localhost:8081/actuator/health
docker compose ps
```
