# Finance Service

Spring Boot service for verified-student payments, fees, invoices, and payment alerts.

## Run

```bash
mvn -pl services/finance-service -am spring-boot:run
```

Default port: `8086`

Swagger: `http://localhost:8086/swagger-ui.html`

Health: `http://localhost:8086/actuator/health`

## Access

All endpoints require JWT with the `STUDENT` role and a linked finance account (created on `student.verified` event).

## Docker

Requires shared infrastructure first:

```powershell
cd "D:\project\Acleda Mobile App\backend\infrastructure"
docker compose up -d --build
```

Then run the service:

```powershell
cd "D:\project\Acleda Mobile App\backend\services\finance-service"
copy .env.example .env
docker compose up -d --build
```

## Build

```bash
mvn -pl services/finance-service -am clean verify
```
