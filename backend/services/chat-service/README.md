# Chat Service

Spring Boot service for private conversations, message requests, and real-time STOMP chat.

## Run

```bash
mvn -pl services/chat-service -am spring-boot:run
```

Default port: `8087`

Swagger: `http://localhost:8087/swagger-ui.html`

Health: `http://localhost:8087/actuator/health`

WebSocket: `ws://localhost:8087/ws/chat`

## Docker

Requires shared infrastructure first:

```powershell
cd "D:\project\Acleda Mobile App\backend\infrastructure"
docker compose up -d --build
```

Then run the service:

```powershell
cd "D:\project\Acleda Mobile App\backend\services\chat-service"
copy .env.example .env
docker compose up -d --build
```

## Build

```bash
mvn -pl services/chat-service -am clean verify
```
