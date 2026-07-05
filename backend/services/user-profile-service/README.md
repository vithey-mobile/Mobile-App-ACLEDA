# User Profile Service

Spring Boot service for Vithey user profiles, app settings, avatar references, and user search.

## Run

```bash
mvn -pl services/user-profile-service -am spring-boot:run
```

Default port: `8082`

Swagger: `http://localhost:8082/swagger-ui.html`

Health: `http://localhost:8082/actuator/health`

## Environment

| Variable | Default |
| --- | --- |
| `USER_DB_URL` | `jdbc:postgresql://localhost:5432/user_db` |
| `USER_DB_USERNAME` | `postgres` |
| `USER_DB_PASSWORD` | `postgres` |
| `VITHEY_JWT_SECRET` | local development secret |
| `CONFIG_SERVER_URL` | `http://localhost:8888` |
| `EUREKA_URL` | `http://localhost:8761/eureka/` |
| `EUREKA_CLIENT_ENABLED` | `false` |
| `RABBITMQ_HOST` | `localhost` |

## Build

```bash
mvn -pl services/user-profile-service -am clean verify
```

## Docker

```powershell
cd "D:\project\Acleda Mobile App\backend\services\user-profile-service"
copy .env.example .env
docker compose up -d --build
```

Requires shared infrastructure:

```powershell
cd "D:\project\Acleda Mobile App\backend\infrastructure"
docker compose up -d --build
```

Verify:

```powershell
Invoke-RestMethod http://localhost:8082/actuator/health
docker compose -f docker-compose.user-profile-service.yml ps
```

## Notes

- Consumes `user.registered` events from RabbitMQ to create default profiles.
- Avatar updates validate files through `file-service` via OpenFeign.
- Stop other local stacks first if ports `8761`, `8888`, `5432`, or `5672` are already in use.
