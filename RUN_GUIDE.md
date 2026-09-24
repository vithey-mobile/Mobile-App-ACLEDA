# 🚀 Vithey Dev Run Guide (Host JVM + Lightweight Docker Infra)

This guide explains how to run Vithey backend services with **minimum resources** by running shared infrastructure in lightweight Docker containers while compiling and running microservice code directly on your host machine (Mac/Linux).

---

## ⚡ One Command to Run Everything

From the project root:

```bash
./run-backend-dev.sh
```

**What this one command does automatically:**
1. Starts the needed Docker infrastructure containers (`postgres`, `redis`, `rabbitmq`, `minio`, `eureka-server`, `config-server`, `ai-core`).
2. Stops any conflicting Docker microservice containers.
3. Pre-compiles modules and launches all 9 Spring Boot microservices on your host JVM.
4. Shows live health status and provides centralized shutdown on `Ctrl+C`.

---

## 🎯 Run a Specific Single Service

If you only want to work on one service:

```bash
./run-backend-dev.sh content-service
```
*(Or `auth-service`, `career-service`, `chat-service`, `api-gateway`, etc.)*

---

## 📋 Common Run Commands

| Task | Command |
|---|---|
| **Run Feed & Social Service** | `./run-backend-dev.sh content-service` |
| **Run Auth & Login Service** | `./run-backend-dev.sh auth-service` |
| **Run Jobs & CV Service** | `./run-backend-dev.sh career-service` |
| **Run Chat Service** | `./run-backend-dev.sh chat-service` |
| **Run API Gateway** | `./run-backend-dev.sh api-gateway` |
| **Start Only Docker Containers** | `./run-backend-dev.sh --infra-only` |
| **Check Health & Status** | `./run-backend-dev.sh --status` |
| **Stop All Dev Containers** | `./run-backend-dev.sh --stop` |
| **List All Available Services** | `./run-backend-dev.sh --list` |

---

## 🐳 What Runs in Docker vs. Host Machine

| Component | Runs Where | Port / URL | Description |
|---|---|---|---|
| **PostgreSQL** | Docker | `localhost:15432` | Shared relational database (with all service DBs initialized) |
| **Redis** | Docker | `localhost:16379` | Cache and rate-limiting store |
| **RabbitMQ** | Docker | `localhost:5672` (UI: `15672`) | Event message broker |
| **MinIO** | Docker | `localhost:19000` (Console: `19001`) | Object storage for media, avatars, CVs |
| **Eureka Server** | Docker | `http://localhost:8761` | Service discovery registry |
| **Config Server** | Docker | `http://localhost:8888` | Central Spring Cloud config server |
| **Your Microservice** | **Host JVM** | `http://localhost:808X` | **Direct code execution via Java 21 / Maven** |

---

## 💡 Why Use Host-Dev Mode?

1. **Instant Feedback:** Edit Java code in VS Code/IntelliJ and run instantly without waiting for Docker image builds.
2. **Minimal Memory:** Avoids running 11 heavy containerized JVMs; only runs the infrastructure and the exact service you are developing.
3. **Live Logs:** Full colored terminal logs directly in your shell with instant `Ctrl+C` stopping.
4. **No Port Conflicts:** The script automatically shuts down matching Docker containers if they were previously running to prevent port or Eureka conflicts.

---

## 📱 Connecting Flutter to Backend

When running the mobile app:
```bash
cd vithey_app
./scripts/run-app.sh
```
- For **Android Emulator**: uses `http://10.0.2.2:8080/api/v1`
- For **Physical Phone**: auto-detects your Mac's LAN IP (`http://<LAN_IP>:8080/api/v1`) and auto-configures `adb reverse`.
