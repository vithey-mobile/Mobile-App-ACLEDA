# Content Service

Spring Boot service for Vithey social feed: posts, comments, reactions, and follows.

## Run

```bash
mvn -pl services/content-service -am spring-boot:run
```

Default port: `8084`

Swagger: `http://localhost:8084/swagger-ui.html`

Health: `http://localhost:8084/actuator/health`

## Environment

| Variable | Default |
| --- | --- |
| `CONTENT_DB_URL` | `jdbc:postgresql://localhost:5432/content_db` |
| `CONFIG_SERVER_URL` | `http://localhost:8888` |
| `EUREKA_URL` | `http://localhost:8761/eureka/` |
| `RABBITMQ_HOST` | `localhost` |
| `VITHEY_EVENTS_EXCHANGE` | `vithey.events` |

## Docker

Requires shared infrastructure first:

```powershell
cd "D:\project\Acleda Mobile App\backend\infrastructure"
docker compose up -d --build
```

Then run the service:

```powershell
cd "D:\project\Acleda Mobile App\backend\services\content-service"
copy .env.example .env
docker compose up -d --build
```

## Build

```bash
mvn -pl services/content-service -am clean verify
```
