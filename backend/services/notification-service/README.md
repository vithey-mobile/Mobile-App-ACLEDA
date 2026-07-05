# Notification Service

Spring Boot service for in-app notifications, unread counts, and optional FCM push delivery.

## Run

```bash
mvn -pl services/notification-service -am spring-boot:run
```

Default port: `8088`

Swagger: `http://localhost:8088/swagger-ui.html`

Health: `http://localhost:8088/actuator/health`

## Docker

Requires shared infrastructure first:

```powershell
cd "D:\project\Acleda Mobile App\backend\infrastructure"
docker compose up -d --build
```

Then run the service:

```powershell
cd "D:\project\Acleda Mobile App\backend\services\notification-service"
copy .env.example .env
docker compose up -d --build
```

## Build

```bash
mvn -pl services/notification-service -am clean verify
```

## FCM

Set `FIREBASE_CREDENTIALS_PATH` to a Firebase service-account JSON file to enable push delivery. When empty, in-app notifications are still persisted.
