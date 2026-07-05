# File Service

Spring Boot service for Vithey file uploads, downloads, and MinIO-backed storage.

## Run

```bash
mvn -pl services/file-service -am spring-boot:run
```

Default port: `8083`

Swagger: `http://localhost:8083/swagger-ui.html`

Health: `http://localhost:8083/actuator/health`

## Environment

| Variable | Default |
| --- | --- |
| `FILE_DB_URL` | `jdbc:postgresql://localhost:5432/file_db` |
| `MINIO_ENDPOINT` | `http://localhost:9000` |
| `MINIO_ACCESS_KEY` | `minioadmin` |
| `MINIO_SECRET_KEY` | `minioadmin` |
| `CONFIG_SERVER_URL` | `http://localhost:8888` |
| `EUREKA_URL` | `http://localhost:8761/eureka/` |

## Docker

Requires shared infrastructure first:

```powershell
cd "D:\project\Acleda Mobile App\backend\infrastructure"
docker compose up -d --build
```

Then run the service:

```powershell
cd "D:\project\Acleda Mobile App\backend\services\file-service"
copy .env.example .env
docker compose up -d --build
```

## Build

```bash
mvn -pl services/file-service -am clean verify
```
