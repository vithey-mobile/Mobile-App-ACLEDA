# Vithey App — Monitoring & Observability

Docker Compose stack for metrics (Prometheus + Grafana) and logs (Loki + Promtail).

**Prompt:** `prompt/Prompt Devops/v1/08-monitoring-observability-prompt.md`

## Stack

| Service | URL | Purpose |
| --- | --- | --- |
| Grafana | http://localhost:3000 | Dashboards + log search |
| Prometheus | http://localhost:9090 | Metrics + alerts |
| Loki | http://localhost:3100 | Log storage |
| Node Exporter | http://localhost:9100/metrics | Host CPU, RAM, disk, network |
| cAdvisor | http://localhost:8090 | Container CPU, memory |

## Prerequisites

1. `vithey-network` exists (start `backend/infrastructure/docker-compose.yml` first)
2. Microservices running with Actuator + Micrometer Prometheus registry
3. Each service exposes `/actuator/prometheus`

## Quick Start

```powershell
cd monitoring
copy .env.example .env
docker compose up -d
docker compose ps
```

## Stop

```powershell
docker compose down
```

## Grafana Login

Credentials come from `.env` (default in `.env.example`):

- User: `GRAFANA_USER`
- Password: `GRAFANA_PASSWORD`

## Dashboards

Folder **Vithey App** in Grafana:

| Dashboard | Contents |
| --- | --- |
| Spring Boot Microservices | Request rate, latency, 5xx, JVM memory/CPU, threads, GC |
| Infrastructure | Host CPU, RAM, disk, network |
| Docker Containers | Per-container CPU, memory, status |
| Chat Service | WebSocket, message rate, Redis, error logs |
| AI Service | Request rate, latency, errors, error logs |

## Log Search (Grafana Explore → Loki)

```logql
{service="auth-service"}
{service="chat-service"} |= "ERROR"
{service=~"api-gateway|auth-service"}
```

Promtail labels Docker containers matching `vithey-*` as `service` (prefix stripped).

## Prometheus Targets

Open http://localhost:9090/targets — microservice jobs show **UP** only when containers are running on `vithey-network`.

## Alerts

Rules in `prometheus/alerts.yml`:

| Alert | Trigger |
| --- | --- |
| ServiceDown | Microservice scrape target down 1m |
| HighCpuUsage | Host CPU > 80% for 5m |
| HighMemoryUsage | Host memory > 85% for 5m |
| HighHttp5xxRate | 5xx > 5% of requests for 5m |
| DatabaseConnectionsHigh | HikariCP pool > 85% for 5m |

View on Prometheus → **Alerts** tab.

## Spring Boot Setup (per microservice)

### Maven (`pom.xml`)

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
  <groupId>io.micrometer</groupId>
  <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

### `application.yml`

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,metrics,prometheus,info
  metrics:
    tags:
      application: ${spring.application.name}
```

Verify locally:

```powershell
curl http://localhost:8081/actuator/prometheus
```

## Architecture

```text
Spring Boot services (/actuator/prometheus)
        │
        ▼
   Prometheus ──► Grafana
        │
   node-exporter / cAdvisor

Docker container logs
        │
        ▼
    Promtail ──► Loki ──► Grafana
```

## Troubleshooting

| Issue | Fix |
| --- | --- |
| `vithey-network` not found | `cd backend/infrastructure && docker compose up -d` |
| Targets DOWN | Start the matching service compose under `backend/services/` |
| No logs in Loki | Ensure Promtail has Docker socket access; container name starts with `vithey-` |
| Empty JVM panels | Add `micrometer-registry-prometheus` and rebuild service images |

## Security Notes

- Do not commit `monitoring/.env`
- Restrict Grafana port in production; use strong passwords
- Block public access to `/actuator/**` via API Gateway in production
