# 08 — Monitoring & Observability Prompt

Implement **Docker Compose–based monitoring** for Vithey App using Prometheus, Grafana, Loki, and Promtail.

**Do NOT use:** Kubernetes, Helm, Terraform, OpenTelemetry.

## Goal

Add a self-contained `monitoring/` stack that:

- Scrapes metrics from every Spring Boot microservice via Actuator + Micrometer
- Collects Docker container logs into Loki
- Exposes Grafana dashboards for services, infrastructure, and Docker
- Defines Prometheus alert rules for downtime, CPU, memory, HTTP errors, and DB connections

## Read First

1. `Prompt Devops/COMMON_CONTEXT.md`
2. `_shared/SERVICE_REGISTRY.md` — ports and Eureka names (link; do not copy table)
3. `Prompt Devops/v1/06-per-service-docker-compose-prompt.md` — `vithey-network` model
4. `Prompt Devops/DOCKER.md` — how services are started locally

## Prerequisites

- Shared infra running: `backend/infrastructure/docker-compose.yml`
- Business services running on `vithey-network` (per-service compose files)
- Docker Compose v2 (`docker compose`)

## Output Structure

```text
monitoring/
├── docker-compose.yml
├── .env.example
├── prometheus/
│   ├── prometheus.yml
│   └── alerts.yml
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/
│   │   │   └── datasource.yml
│   │   └── dashboards/
│   │       └── dashboard.yml
│   └── dashboards/
│       ├── spring-boot-microservices.json
│       ├── infrastructure.json
│       ├── docker-containers.json
│       ├── chat-service.json
│       └── ai-service.json
├── loki/
│   └── loki-config.yml
├── promtail/
│   └── promtail-config.yml
└── README.md
```

Operational docs stay in `monitoring/README.md`. Do **not** add markdown under `backend/`.

## Docker Compose Services

Create `monitoring/docker-compose.yml` with:

| Service | Image | Host port | Purpose |
| --- | --- | --- | --- |
| `prometheus` | `prom/prometheus:latest` | `9090` | Metrics collection |
| `grafana` | `grafana/grafana:latest` | `3000` | Dashboards + log UI |
| `loki` | `grafana/loki:latest` | `3100` | Log storage |
| `promtail` | `grafana/promtail:latest` | — | Ship Docker logs → Loki |
| `node-exporter` | `prom/node-exporter:latest` | `9100` | Host CPU, RAM, disk, network |
| `cadvisor` | `gcr.io/cadvisor/cadvisor:latest` | `8090` | Per-container CPU, memory, network (host port; avoids conflict with ai-service `8089`) |

### Compose rules

- Join external network `vithey-network` so Prometheus can scrape `vithey-*` containers by DNS name
- Use named volumes for Prometheus and Grafana persistence
- Load secrets from `.env` (copy from `.env.example`) — **never hardcode passwords**
- Mount config files read-only
- Promtail needs Docker socket + container log directory:

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock:ro
  - /var/lib/docker/containers:/var/lib/docker/containers:ro
```

- cAdvisor needs similar host mounts (`/`, `/var/run`, `/sys`, `/var/lib/docker`)

### Grafana admin credentials

`.env.example`:

```env
GRAFANA_USER=admin
GRAFANA_PASSWORD=admin123
```

Wire via `GF_SECURITY_ADMIN_USER` and `GF_SECURITY_ADMIN_PASSWORD` in compose.

## Spring Boot Actuator Setup

Apply to **every** microservice under `backend/services/`:

### Maven (`pom.xml`)

Add if missing:

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

### `application.yml` (all profiles)

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,metrics,prometheus,info
  endpoint:
    health:
      show-details: when_authorized
  metrics:
    tags:
      application: ${spring.application.name}
```

Prometheus scrape path: `/actuator/prometheus`

### Optional custom metrics (implement in service code when building dashboards)

| Service | Metric examples |
| --- | --- |
| `chat-service` | `vithey.chat.websocket.connections`, `vithey.chat.messages.sent` |
| `ai-service` | `vithey.ai.requests.total`, `vithey.ai.requests.duration` |

Use Micrometer `Counter`, `Timer`, and `Gauge` in the service layer; tag with `application` and `status`.

## Prometheus Configuration

`prometheus/prometheus.yml`:

- Global scrape interval: **15s**
- Scrape path: `/actuator/prometheus`
- Load rules from `alerts.yml`

### Scrape targets (DNS on `vithey-network`)

| Job label | Target | Port |
| --- | --- | --- |
| `api-gateway` | `vithey-api-gateway` | `8080` |
| `auth-service` | `vithey-auth-service` | `8081` |
| `user-profile-service` | `vithey-user-profile-service` | `8082` |
| `file-service` | `vithey-file-service` | `8083` |
| `content-service` | `vithey-content-service` | `8084` |
| `career-service` | `vithey-career-service` | `8085` |
| `finance-service` | `vithey-finance-service` | `8086` |
| `chat-service` | `vithey-chat-service` | `8087` |
| `notification-service` | `vithey-notification-service` | `8088` |
| `ai-service` | `vithey-ai-service` | `8089` |

Also scrape:

| Job | Target |
| --- | --- |
| `prometheus` | `localhost:9090` |
| `node-exporter` | `node-exporter:9100` |
| `cadvisor` | `cadvisor:8080` |

Add `metric_relabel_configs` or `relabel_configs` so `instance` labels stay readable.

## Grafana Provisioning

### Datasources (`grafana/provisioning/datasources/datasource.yml`)

| Name | Type | URL |
| --- | --- | --- |
| `Prometheus` | prometheus | `http://prometheus:9090` |
| `Loki` | loki | `http://loki:3100` |

Set both as default where appropriate (Prometheus for metrics panels; Loki for log panels).

### Dashboard provider (`grafana/provisioning/dashboards/dashboard.yml`)

- Provider name: `Vithey`
- Folder: `Vithey App`
- Path: `/etc/grafana/dashboards` (mount `grafana/dashboards/`)

## Grafana Dashboards

Create JSON dashboards under `grafana/dashboards/`:

### 1. Spring Boot Microservices (`spring-boot-microservices.json`)

Panels (filter by `application` tag):

- HTTP request rate — `rate(http_server_requests_seconds_count[5m])`
- Response time (p95) — `histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m]))`
- HTTP 5xx rate — filter `status=~"5.."`
- JVM heap used — `jvm_memory_used_bytes{area="heap"}`
- JVM CPU — `process_cpu_usage`
- Live threads — `jvm_threads_live`
- GC pause rate — `rate(jvm_gc_pause_seconds_count[5m])`

### 2. Infrastructure (`infrastructure.json`)

From `node-exporter`:

- CPU — `100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`
- Memory — `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes`
- Disk — `node_filesystem_avail_bytes / node_filesystem_size_bytes`
- Network — `rate(node_network_receive_bytes_total[5m])`, transmit

### 3. Docker Containers (`docker-containers.json`)

From `cAdvisor`:

- Container CPU — `rate(container_cpu_usage_seconds_total{name=~"vithey.*"}[5m])`
- Container memory — `container_memory_usage_bytes{name=~"vithey.*"}`
- Container running — `container_last_seen{name=~"vithey.*"}`

### 4. Chat Service (`chat-service.json`)

- WebSocket / STOMP connections (custom gauge or proxy metric)
- Message rate — custom counter or HTTP + messaging metrics
- Redis — `lettuce_command_completion_seconds_count` or pool metrics
- JVM + HTTP panels scoped to `application="chat-service"`

### 5. AI Service (`ai-service.json`)

- Request count — `vithey_ai_requests_total` or `http_server_requests_seconds_count{application="ai-service"}`
- Latency p95 — timer histogram
- Error rate — `status=~"5.."` or custom error counter

## Logging Pipeline

```text
Docker containers → Promtail → Loki → Grafana (Explore / dashboards)
```

`promtail/promtail-config.yml`:

- `docker_sd_configs` on unix socket
- Relabel `container_name` → label `service` (strip `vithey-` prefix)
- Push to `http://loki:3100/loki/api/v1/push`

`loki/loki-config.yml`:

- Single-binary local config
- Filesystem storage under `/loki`
- Retention ~7 days for local dev (configurable)

Grafana log queries:

```logql
{service="chat-service"} |= "ERROR"
{service=~"auth-service|api-gateway"} | json
```

## Prometheus Alerts (`prometheus/alerts.yml`)

| Alert | Condition | `for` |
| --- | --- | --- |
| `ServiceDown` | `up{job=~".*-service|api-gateway"} == 0` | `1m` |
| `HighCpuUsage` | Host CPU > 80% | `5m` |
| `HighMemoryUsage` | Host memory used > 85% | `5m` |
| `HighHttp5xxRate` | 5xx / total requests > 5% per service | `5m` |
| `DatabaseConnectionsHigh` | `hikaricp_connections_active / hikaricp_connections_max > 0.85` | `5m` |

Reference `alerts.yml` from `prometheus.yml` via `rule_files`.

> Alertmanager is optional for local dev; rules still appear on Prometheus **Alerts** page.

## Security

- Credentials only in `monitoring/.env` (gitignored)
- Commit `monitoring/.env.example` with placeholders
- Do not expose Actuator prometheus endpoint publicly in production without auth (document in README; gateway can block `/actuator/**` externally)

## Run Commands

Document in `monitoring/README.md`:

```powershell
# Start backend stack first
cd backend/infrastructure
docker compose up -d

cd ..\services\auth-service
docker compose up -d
# ... other services ...

# Start monitoring
cd ..\..\..\monitoring
copy .env.example .env
docker compose up -d
```

```powershell
docker compose ps
docker compose logs -f grafana
docker compose down
```

### Access URLs

| UI | URL |
| --- | --- |
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |
| Loki | http://localhost:3100/ready |

## Verification

```powershell
curl http://localhost:9090/-/healthy
curl http://localhost:3100/ready
curl http://localhost:3000/api/health

# Targets should be UP when services are running
start http://localhost:9090/targets

# Sample metric from a running service
curl http://localhost:8081/actuator/prometheus | Select-String "jvm_memory"
```

Check Grafana:

1. **Explore → Prometheus** — query `up`
2. **Explore → Loki** — query `{service="auth-service"}`
3. **Dashboards → Vithey App** — all five dashboards load

## Out of Scope

- Kubernetes / Helm / Terraform
- OpenTelemetry collectors
- Alertmanager notification channels (Slack, email) — add in a later prompt
- Production TLS / reverse proxy for Grafana

## Depends On

- `v1/06-per-service-docker-compose-prompt.md` (services on `vithey-network`)
- All microservices expose `/actuator/prometheus`

## Next Steps (optional follow-up prompts)

- `09-alertmanager-notifications-prompt.md` — Slack/email routing
- Per-service SLO dashboards
- Postgres / Redis / RabbitMQ exporters
