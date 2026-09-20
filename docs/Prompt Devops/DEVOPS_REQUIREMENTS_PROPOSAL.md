# Vithey App — DevOps Plan & Build Requirements

**Project:** Vithey App  
**Document type:** DevOps plan + requirements to build  
**Date:** 30 July 2026  
**Share with:** Technical / DevOps team  

---

## 1. Deployment strategy (fixed)


| Environment     | Platform           | Purpose                                                        |
| --------------- | ------------------ | -------------------------------------------------------------- |
| **Development** | **Docker Compose** | Local laptop / team machines — full stack in one command       |
| **Production**  | **Kubernetes**     | Demo / live API — Deployments, Services, Ingress, Secrets, PVC |


Same container images for both. Develop and test with Docker; promote the same GHCR images into Kubernetes for production.

```text
  Developer laptop                    Production cluster
  ─────────────────                   ──────────────────
  docker compose up -d                kubectl apply / Helm
        │                                    │
        │         same images                │
        └──────── ghcr.io/.../vithey-* ──────┘
```

Mobile Flutter app is built separately; DevOps focuses on **backend services + infra**.

---

## 2. Goal

1. **Dev:** run all microservices locally with Docker Compose
2. **CI/CD:** test → build images → push to GHCR
3. **Prod:** deploy those images on **Kubernetes** with HTTPS Ingress
4. **Observability:** metrics + logs (Compose for local; Prometheus/Grafana in cluster for prod)

---

## 3. DevOps Plan (what we will build)

### Phase 1 — Development (Docker Compose)


| Item                        | Description                                                 |
| --------------------------- | ----------------------------------------------------------- |
| Dockerfiles                 | Multi-stage image per microservice (Java 21)                |
| `docker-compose.yml`        | Full stack: Postgres, Redis, RabbitMQ, MinIO + all services |
| Env templates               | `.env.example` for local secrets                            |
| Run scripts                 | `start-all.ps1` / documented commands                       |
| Local monitoring (optional) | Prometheus + Grafana + Loki via Compose                     |


**Dev command:**

```bash
cd backend
docker compose up -d --build
```

### Phase 2 — CI/CD (shared for Dev & Prod)


| Item               | Description                                          |
| ------------------ | ---------------------------------------------------- |
| GitHub Actions     | Backend tests + Flutter analyze/test                 |
| Image build & push | All services → `ghcr.io/<owner>/vithey-<service>`    |
| Tags               | `latest`, `sha-<commit>`, optional `v*` release tags |


Images built in CI are what Kubernetes pulls in production.

### Phase 3 — Production (Kubernetes)


| Item                     | Description                                     |
| ------------------------ | ----------------------------------------------- |
| Manifests or Helm chart  | Deployment + Service per microservice           |
| Namespace                | e.g. `vithey`                                   |
| Ingress + TLS            | Public HTTPS → `api-gateway` only               |
| ConfigMaps / Secrets     | JWT, DB, RabbitMQ, MinIO, FCM, AI keys          |
| PVC / managed DB         | Postgres (in-cluster or Cloud SQL), MinIO or S3 |
| Health probes            | `/actuator/health` liveness + readiness         |
| Resource requests/limits | CPU / memory per pod                            |
| Deploy runbook           | `DEPLOYMENT.md` (apply, rollback, scale)        |


### Phase 4 — Production observability


| Item       | Description                            |
| ---------- | -------------------------------------- |
| Prometheus | Scrape Actuator metrics in cluster     |
| Grafana    | Service / JVM / cluster dashboards     |
| Logs       | Loki or cluster-standard log stack     |
| Alerts     | ServiceDown, high 5xx, high CPU/memory |


```text
Plan flow:

  Code push
      │
      ▼
  GitHub Actions (test → build → push GHCR)
      │
      ├──────────────────────┐
      ▼                      ▼
  Development              Production
  Docker Compose           Kubernetes
  (local full stack)       (Ingress → Gateway)
      │                      │
      └──── same images ─────┘
```

---

## 4. What must be deployed (build scope)

### 4.1 Platform services


| Service       | Port | Need                                   |
| ------------- | ---- | -------------------------------------- |
| api-gateway   | 8080 | Only public API entry (Ingress target) |
| eureka-server | 8761 | Service discovery                      |
| config-server | 8888 | Central config                         |


### 4.2 Business microservices


| Service              | Port |
| -------------------- | ---- |
| auth-service         | 8081 |
| user-profile-service | 8082 |
| file-service         | 8083 |
| content-service      | 8084 |
| career-service       | 8085 |
| finance-service      | 8086 |
| chat-service         | 8087 |
| notification-service | 8088 |
| ai-service           | 8089 |


### 4.3 Shared infrastructure


| Component     | Dev (Docker)    | Prod (Kubernetes)                       |
| ------------- | --------------- | --------------------------------------- |
| PostgreSQL 16 | Compose service | PVC **or** managed DB (Cloud SQL / RDS) |
| Redis 7       | Compose service | Deployment + PVC **or** managed Redis   |
| RabbitMQ 3    | Compose service | Deployment + PVC **or** managed broker  |
| MinIO         | Compose service | PVC **or** S3-compatible bucket         |


---

## 5. Requirements needed to build this

### 5.1 Development (Docker)


| #   | Requirement                                 | Why                        |
| --- | ------------------------------------------- | -------------------------- |
| 1   | Docker Desktop / Docker Engine + Compose v2 | Local full stack           |
| 2   | ≥ **8–16 GB RAM** on laptop                 | Build & run all containers |
| 3   | GitHub repo (Actions enabled)               | CI/CD                      |
| 4   | Java 21 + Maven (optional)                  | Debug without Docker       |


### 5.2 Production (Kubernetes)


| #   | Requirement                                            | Why                |
| --- | ------------------------------------------------------ | ------------------ |
| 5   | Kubernetes cluster (GKE / OpenShift / k3s / kubeadm)   | Production runtime |
| 6   | `kubectl` + cluster access for deploy user             | Apply manifests    |
| 7   | Ingress controller (NGINX / Traefik / OpenShift Route) | HTTPS entry        |
| 8   | Domain + TLS certificate                               | Public API URL     |
| 9   | Cluster resources                                      | See sizing below   |
| 10  | Storage class for PVC (if DB/MinIO in-cluster)         | Persistence        |


### 5.3 Accounts & registry


| #   | Requirement                                            | Why                         |
| --- | ------------------------------------------------------ | --------------------------- |
| 11  | GHCR write (GitHub Packages)                           | Publish images from CI      |
| 12  | Cluster pull secret for GHCR (or mirror to Harbor/GCR) | K8s can pull private images |


### 5.4 Secrets / config (both envs; stronger in prod)


| #   | Secret / config                     | Used by            |
| --- | ----------------------------------- | ------------------ |
| 13  | `VITHEY_JWT_SECRET` (≥256-bit)      | Auth + Gateway     |
| 14  | Postgres credentials                | All DB services    |
| 15  | RabbitMQ credentials                | Event services     |
| 16  | MinIO / S3 keys                     | File service       |
| 17  | (Optional) Firebase service account | Push notifications |
| 18  | (Optional) OpenAI / Gemini API key  | AI service         |


### 5.5 Production cluster sizing (demo / competition)


| Resource      | Minimum               | Recommended          |
| ------------- | --------------------- | -------------------- |
| Worker nodes  | 2 × 2 vCPU / 8 GB     | 3 × 4 vCPU / 8–16 GB |
| Disk / PVC    | 40 GB+                | 80 GB+               |
| Public access | Ingress 443 → Gateway | Same                 |


### 5.6 Network


| #   | Requirement                              | Why                            |
| --- | ---------------------------------------- | ------------------------------ |
| 19  | Outbound HTTPS from cluster              | Pull GHCR images, FCM, AI APIs |
| 20  | Only Ingress / Gateway exposed publicly  | Security                       |
| 21  | DB, Eureka, Config, Redis ClusterIP only | No public ports             
