#!/usr/bin/env bash
# ==============================================================================
# Vithey Host-Dev Runner (macOS / Linux)
# ==============================================================================
# ONE COMMAND TO RUN EVERYTHING:
#   ./run-backend-dev.sh
#
# Runs required infrastructure (Postgres, Redis, RabbitMQ, MinIO, Eureka, Config,
# AI Core) inside Docker containers, and boots all Spring Boot microservices
# directly on the host JVM (instant compilation, live logs, no container bloat).
#
# Usage:
#   ./run-backend-dev.sh                     # ONE COMMAND: Runs all needed containers & services
#   ./run-backend-dev.sh content-service     # Run a single service in foreground
#   ./run-backend-dev.sh auth-service gateway# Run a specific subset
#   ./run-backend-dev.sh --infra-only        # Start only required Docker containers
#   ./run-backend-dev.sh --stop              # Stop everything (services & containers)
#   ./run-backend-dev.sh --status            # Check health of containers & services
#   ./run-backend-dev.sh --list              # List available services
#   ./run-backend-dev.sh --menu              # Interactive selection menu
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${BACKEND_DIR}/.logs"

cd "${BACKEND_DIR}"

# ANSI colors
BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# ── Auto-detect JDK 21 and Maven on macOS / Linux ─────────────────────────────
detect_java() {
    if [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/java" ]; then
        if "$JAVA_HOME/bin/java" -version 2>&1 | grep -q '"21'; then
            return 0
        fi
    fi

    local candidate_paths=(
        "/opt/homebrew/opt/openjdk@21"
        "/usr/local/opt/openjdk@21"
        "/opt/homebrew/opt/openjdk"
        "/usr/local/opt/openjdk"
    )

    for p in "${candidate_paths[@]}"; do
        if [ -d "$p" ] && [ -x "$p/bin/java" ]; then
            export JAVA_HOME="$p"
            export PATH="$JAVA_HOME/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
            return 0
        fi
    done

    if command -v /usr/libexec/java_home >/dev/null 2>&1; then
        local jh
        jh=$(/usr/libexec/java_home -v 21 2>/dev/null || true)
        if [ -n "$jh" ] && [ -d "$jh" ]; then
            export JAVA_HOME="$jh"
            export PATH="$JAVA_HOME/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
            return 0
        fi
    fi

    if command -v java >/dev/null 2>&1; then
        return 0
    fi

    echo -e "${RED}❌ Java 21 is required but could not be located.${NC}"
    echo -e "   Please install it via: ${CYAN}brew install openjdk@21 maven${NC}"
    exit 1
}

if ! command -v mvn >/dev/null 2>&1; then
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
fi

detect_java

# Available services
ALL_SERVICES=(
    "auth-service"
    "user-profile-service"
    "file-service"
    "content-service"
    "career-service"
    "finance-service"
    "chat-service"
    "notification-service"
    "api-gateway"
    "map-service"
)

# Default services to run when launching ALL
DEFAULT_SERVICES=(
    "auth-service"
    "user-profile-service"
    "file-service"
    "content-service"
    "career-service"
    "finance-service"
    "chat-service"
    "notification-service"
    "api-gateway"
)

# Docker Compose files & required infra containers
COMPOSE_FILES=("-f" "docker-compose.yml" "-f" "docker-compose.demo.yml")
INFRA_CONTAINERS=("postgres" "redis" "rabbitmq" "minio" "eureka-server" "config-server" "ai-core")

# Get service port
get_service_port() {
    case "$1" in
        "api-gateway"|"gateway") echo "8080" ;;
        "auth-service") echo "8081" ;;
        "user-profile-service") echo "8082" ;;
        "file-service") echo "8083" ;;
        "content-service") echo "8084" ;;
        "career-service") echo "8085" ;;
        "finance-service") echo "8086" ;;
        "chat-service") echo "8087" ;;
        "notification-service") echo "8088" ;;
        "map-service") echo "8090" ;;
        *) echo "8080" ;;
    esac
}

show_list() {
    echo -e "${BOLD}Available Vithey Services:${NC}"
    for s in "${ALL_SERVICES[@]}"; do
        echo -e "  - ${CYAN}$s${NC} (Port $(get_service_port "$s"))"
    done
}

stop_all() {
    echo -e "${YELLOW}Stopping all running host services and Docker containers...${NC}"
    # Kill any lingering spring-boot runs from this project
    pkill -f "vithey-backend" 2>/dev/null || true
    pkill -f "spring-boot:run" 2>/dev/null || true
    docker compose "${COMPOSE_FILES[@]}" stop "${INFRA_CONTAINERS[@]}" 2>/dev/null || true
    echo -e "${GREEN}✅ All services and infra stopped.${NC}"
}

check_status() {
    echo -e "${BOLD}── Infra Containers (Docker) ──${NC}"
    docker compose "${COMPOSE_FILES[@]}" ps "${INFRA_CONTAINERS[@]}" || true
    echo ""
    echo -e "${BOLD}── Service Health / Discovery ──${NC}"
    echo -n "Config Server (:8888): "
    curl -sf http://localhost:8888/actuator/health | grep -q "UP" && echo -e "${GREEN}UP${NC}" || echo -e "${RED}DOWN${NC}"
    echo -n "Eureka Server (:8761): "
    curl -sf http://localhost:8761/actuator/health | grep -q "UP" && echo -e "${GREEN}UP${NC}" || echo -e "${RED}DOWN${NC}"
    echo -n "AI Core       (:8100): "
    curl -sf http://localhost:8100/health | grep -q "ok" && echo -e "${GREEN}UP${NC}" || echo -e "${RED}DOWN${NC}"
    echo -n "API Gateway   (:8080): "
    curl -sf http://localhost:8080/actuator/health | grep -q "UP" && echo -e "${GREEN}UP${NC}" || echo -e "${GRAY}NOT RUNNING${NC}"
}

start_infra() {
    echo -e "${CYAN}🐳 Ensuring required infra containers are running in Docker...${NC}"
    echo -e "   (${INFRA_CONTAINERS[*]})${NC}"
    docker compose "${COMPOSE_FILES[@]}" up -d "${INFRA_CONTAINERS[@]}"

    echo -e "${GRAY}Waiting for config-server (:8888) and eureka-server (:8761)...${NC}"
    local max_retries=45
    local config_up=false
    local eureka_up=false

    for ((i=1; i<=max_retries; i++)); do
        if [ "$config_up" = false ] && curl -sf http://localhost:8888/actuator/health | grep -q "UP" 2>/dev/null; then
            config_up=true
        fi
        if [ "$eureka_up" = false ] && curl -sf http://localhost:8761/actuator/health | grep -q "UP" 2>/dev/null; then
            eureka_up=true
        fi
        if [ "$config_up" = true ] && [ "$eureka_up" = true ]; then
            echo -e "${GREEN}✅ Config Server and Eureka are healthy and ready.${NC}"
            return 0
        fi
        sleep 2
    done

    echo -e "${YELLOW}⚠️  Timed out waiting for full health. Proceeding anyway...${NC}"
}

ensure_no_container_conflict() {
    local svc="$1"
    local running
    running=$(docker compose "${COMPOSE_FILES[@]}" ps -q "$svc" 2>/dev/null || true)
    if [ -n "$running" ]; then
        echo -e "${YELLOW}Stopping docker container '$svc' to prevent port conflict with host JVM...${NC}"
        docker compose "${COMPOSE_FILES[@]}" stop "$svc" >/dev/null 2>&1 || true
    fi
}

set_host_env() {
    local svc="$1"

    export CONFIG_SERVER_URL="http://localhost:8888"
    export EUREKA_URL="http://localhost:8761/eureka/"
    export EUREKA_CLIENT_ENABLED="true"
    export VITHEY_JWT_SECRET="${VITHEY_JWT_SECRET:-change-me-to-a-strong-256-bit-secret-for-local-dev}"
    export RABBITMQ_HOST="localhost"
    export RABBITMQ_PORT="5672"
    export RABBITMQ_USERNAME="guest"
    export RABBITMQ_PASSWORD="guest"
    export REDIS_HOST="localhost"
    export REDIS_PORT="16379"
    export MINIO_ENDPOINT="http://localhost:19000"
    export MINIO_PUBLIC_ENDPOINT="http://localhost:19000"
    export MINIO_ACCESS_KEY="minioadmin"
    export MINIO_SECRET_KEY="minioadmin"
    export MINIO_BUCKETS="avatars,cvs,posters,videos"

    case "$svc" in
        "auth-service")
            export AUTH_DB_URL="jdbc:postgresql://localhost:15432/auth_db"
            export AUTH_DB_USERNAME="postgres"
            export AUTH_DB_PASSWORD="postgres"
            ;;
        "user-profile-service")
            export USER_DB_URL="jdbc:postgresql://localhost:15432/user_db"
            export USER_DB_USERNAME="postgres"
            export USER_DB_PASSWORD="postgres"
            ;;
        "file-service")
            export FILE_DB_URL="jdbc:postgresql://localhost:15432/file_db"
            export FILE_DB_USERNAME="postgres"
            export FILE_DB_PASSWORD="postgres"
            ;;
        "content-service")
            export CONTENT_DB_URL="jdbc:postgresql://localhost:15432/content_db"
            export CONTENT_DB_USERNAME="postgres"
            export CONTENT_DB_PASSWORD="postgres"
            ;;
        "career-service")
            export CAREER_DB_URL="jdbc:postgresql://localhost:15432/career_db"
            export CAREER_DB_USERNAME="postgres"
            export CAREER_DB_PASSWORD="postgres"
            ;;
        "finance-service")
            export FINANCE_DB_URL="jdbc:postgresql://localhost:15432/finance_db"
            export FINANCE_DB_USERNAME="postgres"
            export FINANCE_DB_PASSWORD="postgres"
            ;;
        "chat-service")
            export CHAT_DB_URL="jdbc:postgresql://localhost:15432/chat_db"
            export CHAT_DB_USERNAME="postgres"
            export CHAT_DB_PASSWORD="postgres"
            ;;
        "notification-service")
            export NOTIFICATION_DB_URL="jdbc:postgresql://localhost:15432/notification_db"
            export NOTIFICATION_DB_USERNAME="postgres"
            export NOTIFICATION_DB_PASSWORD="postgres"
            ;;
        "map-service")
            export MAP_DB_URL="jdbc:postgresql://localhost:15432/map_db"
            export MAP_DB_USERNAME="postgres"
            export MAP_DB_PASSWORD="postgres"
            ;;
    esac
}

print_service_guide() {
    local svc="$1"
    local port
    port=$(get_service_port "$svc")

    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}🚀 Starting Service:${NC}  ${GREEN}${svc}${NC}"
    echo -e "  ${BOLD}📍 Direct URL:${NC}        ${CYAN}http://localhost:${port}${NC}"
    echo -e "  ${BOLD}🩺 Health URL:${NC}        ${CYAN}http://localhost:${port}/actuator/health${NC}"
    echo -e "  ${BOLD}🌐 Gateway Route:${NC}     ${CYAN}http://localhost:8080/api/v1/...${NC}"
    echo -e "  ${BOLD}🐳 Docker Infra:${NC}      Postgres (15432) • Redis (16379) • Eureka (8761) • AI Core (8100)"
    echo -e "  ${BOLD}💡 To Stop:${NC}           Press ${YELLOW}Ctrl+C${NC} anytime"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Run a single service in foreground
run_single_service() {
    local svc="$1"
    ensure_no_container_conflict "$svc"
    set_host_env "$svc"

    local jvm_args="-Xms64m -Xmx256m -XX:+UseSerialGC -XX:MaxMetaspaceSize=128m -Dspring.jmx.enabled=false"

    print_service_guide "$svc"

    mvn -pl "services/${svc}" spring-boot:run -Dspring-boot.run.jvmArguments="${jvm_args}"
}

# Run multiple services as background processes with centralized cleanup & health monitoring
run_multiple_services() {
    local services=("$@")
    mkdir -p "${LOG_DIR}"

    echo -e "\n${CYAN}🔨 Pre-compiling backend modules to ensure instant startup...${NC}"
    mvn compile -DskipTests -q 2>/dev/null || mvn compile -DskipTests

    local pids=()
    cleanup() {
        echo -e "\n\n${YELLOW}🛑 Shutting down host microservices...${NC}"
        for pid in "${pids[@]}"; do
            kill "$pid" 2>/dev/null || true
        done
        wait 2>/dev/null || true
        echo -e "${GREEN}✅ All host microservices stopped cleanly.${NC}"
        exit 0
    }
    trap cleanup SIGINT SIGTERM

    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}🌟 Vithey Full Stack Running (Docker Infra + Host Services)${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}🐳 Docker Infra:${NC}      Postgres (15432) • Redis (16379) • RabbitMQ (5672)"
    echo -e "                         MinIO (19000) • Eureka (8761) • AI Core (8100)"
    echo -e "  ${BOLD}☕ Launching Host Microservices:${NC}"

    for svc in "${services[@]}"; do
        ensure_no_container_conflict "$svc"
        local port
        port=$(get_service_port "$svc")
        (
            set_host_env "$svc"
            local jvm_args="-Xms48m -Xmx160m -XX:+UseSerialGC -XX:MaxMetaspaceSize=80m -Dspring.jmx.enabled=false"
            mvn -pl "services/${svc}" spring-boot:run -Dspring-boot.run.jvmArguments="${jvm_args}" > "${LOG_DIR}/${svc}.log" 2>&1
        ) &
        local pid=$!
        pids+=("$pid")
        echo -e "     • ${GREEN}${svc}${NC} (Port ${port}, PID ${pid}) -> Log: ${GRAY}.logs/${svc}.log${NC}"
        sleep 0.8
    done

    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}🌐 Gateway Entrypoint:${NC} ${CYAN}http://localhost:8080/api/v1/...${NC}"
    echo -e "  ${BOLD}📁 Live Logs:${NC}          ${CYAN}tail -f .logs/*.log${NC}"
    echo -e "  ${BOLD}💡 To Stop Everything:${NC} Press ${YELLOW}Ctrl+C${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GRAY}Monitoring service health...${NC}"

    # Poll service health in background and notify when they become UP
    local pending=("${services[@]}")
    while [ ${#pending[@]} -gt 0 ]; do
        sleep 3
        local next_pending=()
        for svc in "${pending[@]}"; do
            local port
            port=$(get_service_port "$svc")
            if curl -sf "http://localhost:${port}/actuator/health" | grep -q "UP" 2>/dev/null; then
                echo -e "  ${GREEN}✔ ${svc} is UP${NC} (http://localhost:${port})"
            else
                next_pending+=("$svc")
            fi
        done
        pending=("${next_pending[@]}")
    done

    echo -e "\n${BOLD}${GREEN}🎉 All services are UP and ready!${NC}\n"

    # Keep alive until Ctrl+C
    wait
}

# ── Argument Parsing ──────────────────────────────────────────────────────────
if [ "$1" = "--list" ] || [ "$1" = "-l" ]; then
    show_list
    exit 0
fi

if [ "$1" = "--stop" ] || [ "$1" = "--down" ]; then
    stop_all
    exit 0
fi

if [ "$1" = "--status" ]; then
    check_status
    exit 0
fi

if [ "$1" = "--infra-only" ]; then
    start_infra
    echo -e "${GREEN}✅ Infra is ready! You can now run any service from source.${NC}"
    exit 0
fi

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo -e "${BOLD}Vithey Host-Dev Runner${NC}"
    echo ""
    echo "Usage:"
    echo "  $0                              ONE COMMAND: Run all needed containers & services"
    echo "  $0 all                          Run all needed containers & services"
    echo "  $0 <service-name>               Run single service in foreground (e.g. content-service)"
    echo "  $0 <svc1> <svc2> ...            Run specific services on host"
    echo "  $0 --infra-only                 Start only required Docker infra"
    echo "  $0 --stop                       Stop Docker infra & host services"
    echo "  $0 --status                     Show health of containers and services"
    echo "  $0 --list                       List all available service names"
    echo "  $0 --menu                       Interactive menu"
    exit 0
fi

# Interactive menu only if explicitly requested
if [ "$1" = "--menu" ] || [ "$1" = "-m" ]; then
    echo -e "${BOLD}================================================${NC}"
    echo -e "${BOLD}      🌟 Vithey Microservices Host-Dev Runner   ${NC}"
    echo -e "${BOLD}================================================${NC}"
    echo "Select an option:"
    echo "  1) Run ALL services + needed infra (Full Stack)"
    echo "  2) Run content-service (Feed, Posts, Comments, Stories)"
    echo "  3) Run auth-service + user-profile-service + api-gateway"
    echo "  4) Run career-service (Job Applications, CV)"
    echo "  5) Run chat-service"
    echo "  6) Run api-gateway only"
    echo "  7) Start minimal infra containers only (Docker)"
    echo "  8) Check status & health"
    echo "  9) Stop everything"
    echo "  0) Exit"
    echo ""
    read -rp "Enter choice [1-9]: " choice

    case "$choice" in
        1) set -- "all" ;;
        2) set -- "content-service" ;;
        3) set -- "auth-service" "user-profile-service" "api-gateway" ;;
        4) set -- "career-service" ;;
        5) set -- "chat-service" ;;
        6) set -- "api-gateway" ;;
        7) start_infra; exit 0 ;;
        8) check_status; exit 0 ;;
        9) stop_all; exit 0 ;;
        *) echo "Exiting."; exit 0 ;;
    esac
fi

# Start the required Docker infrastructure first
start_infra

# If no arguments passed or "all", run all services!
if [ $# -eq 0 ] || [ "$1" = "all" ] || [ "$1" = "--all" ]; then
    run_multiple_services "${DEFAULT_SERVICES[@]}"
elif [ $# -eq 1 ]; then
    run_single_service "$1"
else
    run_multiple_services "$@"
fi
