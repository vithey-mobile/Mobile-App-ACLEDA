# Career Service

Spring Boot service for job applications, applicant review, and saved CV references.

## Run

```bash
mvn -pl services/career-service -am spring-boot:run
```

Default port: `8085`

Swagger: `http://localhost:8085/swagger-ui.html`

Health: `http://localhost:8085/actuator/health`

## Environment

| Variable | Default |
| --- | --- |
| `CAREER_DB_URL` | `jdbc:postgresql://localhost:5432/career_db` |
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
cd "D:\project\Acleda Mobile App\backend\services\career-service"
copy .env.example .env
docker compose up -d --build
```

## Build

```bash
mvn -pl services/career-service -am clean verify
```
