#!/usr/bin/env bash
# ==============================================================================
# Vithey Host-Dev Runner (macOS / Linux)
# ==============================================================================
# Runs shared infrastructure (Postgres, Redis, RabbitMQ, MinIO, Eureka, Config)
# inside lightweight Docker containers, while running your selected Spring Boot
# microservice(s) directly on the host JVM for instant compilation & fast iteration.
#
# Usage:
#   ./scripts/start-dev-host.sh content-service              # Run single service in foreground
#   ./scripts/start-dev-host.sh auth-service user-profile-service api-gateway  # Run multiple
#   ./scripts/start-dev-host.sh --infra-only                 # Start only required Docker containers
#   ./scripts/start-dev-host.sh --stop                      # Stop infra containers
#   ./scripts/start-dev-host.sh --status                    # Check infra & service health
#   ./scripts/start-dev-host.sh --list                      # List available services
#   ./scripts/start-dev-host.sh                             # Interactive selection menu
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
    # If JAVA_HOME is already set and valid for Java 21, keep it
    if [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/java" ]; then
        if "$JAVA_HOME/bin/java" -version 2>&1 | grep -q '"21'; then
            return 0
        fi
    fi

    # Check Homebrew OpenJDK 21 on macOS Apple Silicon or Intel
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

    # Try macOS /usr/libexec/java_home
    if command -v /usr/libexec/java_home >/dev/null 2>&1; then
        local jh
        jh=$(/usr/libexec/java_home -v 21 2>/dev/null || true)
        if [ -n "$jh" ] && [ -d "$jh" ]; then
            export JAVA_HOME="$jh"
            export PATH="$JAVA_HOME/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
            return 0
        fi
    fi

    # Fallback: check if java in PATH is Java 21
    if command -v java >/dev/null 2>&1; then
        return 0
    fi

    echo -e "${RED}❌ Java 21 is required but could not be located.${NC}"
    echo -e "   Please install it via: ${CYAN}brew install openjdk@21 maven${NC}"
    exit 1
}

# Ensure PATH contains Maven
if ! command -v mvn >/dev/null 2>&1; then
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
fi

detect_java

# Available services
ALL_SERVICES=(
    "api-gateway"
    "auth-service"
    "user-profile-service"
    "content-service"
    "career-service"
    "chat-service"
    "file-service"
    "finance-service"
    "notification-service"
    "map-service"
)

# Shared compose configuration
COMPOSE_FILES=("-f" "docker-compose.yml" "-f" "docker-compose.demo.yml")
INFRA_CONTAINERS=("postgres" "redis" "rabbitmq" "minio" "eureka-server" "config-server")

# ── Helper functions ──────────────────────────────────────────────────────────
show_list() {
    echo -e "${BOLD}Available Vithey Services:${NC}"
    for s in "${ALL_SERVICES[@]}"; do
        echo -e "  - ${CYAN}$s${NC}"
    done
}

stop_infra() {
    echo -e "${YELLOW}Stopping host-dev infra containers...${NC}"
    docker compose "${COMPOSE_FILES[@]}" stop "${INFRA_CONTAINERS[@]}"
    echo -e "${GREEN}✅ Infra containers stopped.${NC}"
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

# Stop Docker container for a service if it's running, to prevent port & Eureka conflict
ensure_no_container_conflict() {
    local svc="$1"
    # Check if a container for this service is running
    local running
    running=$(docker compose "${COMPOSE_FILES[@]}" ps -q "$svc" 2>/dev/null || true)
    if [ -n "$running" ]; then
        echo -e "${YELLOW}Stopping docker container '$svc' to prevent port conflict with host JVM...${NC}"
        docker compose "${COMPOSE_FILES[@]}" stop "$svc" >/dev/null 2>&1 || true
    fi
}

# Export environment variables for host execution
set_host_env() {
    local svc="$1"

    # Common platform variables
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

    # Service-specific Postgres DB URL mapping (host port is 15432)
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

# Run a single service in foreground
run_single_service() {
    local svc="$1"
    ensure_no_container_conflict "$svc"
    set_host_env "$svc"

    local jvm_args="-Xms64m -Xmx256m -XX:+UseSerialGC -XX:MaxMetaspaceSize=128m -Dspring.jmx.enabled=false"

    echo -e "${GREEN}🚀 Starting ${BOLD}${svc}${NC}${GREEN} on host JVM (code execution)...${NC}"
    echo -e "${GRAY}   Press Ctrl+C to stop.${NC}"
    echo ""

    mvn -pl "services/${svc}" spring-boot:run -Dspring-boot.run.jvmArguments="${jvm_args}"
}

# Run multiple services as background processes with centralized trap cleanup
run_multiple_services() {
    local services=("$@")
    mkdir -p "${LOG_DIR}"

    local pids=()
    cleanup() {
        echo -e "\n${YELLOW}🛑 Shutting down host services...${NC}"
        for pid in "${pids[@]}"; do
            kill "$pid" 2>/dev/null || true
        done
        wait 2>/dev/null || true
        echo -e "${GREEN}All host services stopped.${NC}"
        exit 0
    }
    trap cleanup SIGINT SIGTERM

    echo -e "${GREEN}🚀 Launching ${#services[@]} services on host...${NC}"
    for svc in "${services[@]}"; do
        ensure_no_container_conflict "$svc"
        (
            set_host_env "$svc"
            local jvm_args="-Xms64m -Xmx192m -XX:+UseSerialGC -XX:MaxMetaspaceSize=96m -Dspring.jmx.enabled=false"
            mvn -pl "services/${svc}" spring-boot:run -Dspring-boot.run.jvmArguments="${jvm_args}" > "${LOG_DIR}/${svc}.log" 2>&1
        ) &
        local pid=$!
        pids+=("$pid")
        echo -e "   Started ${BOLD}${svc}${NC} (PID ${pid}) -> Log: ${CYAN}.logs/${svc}.log${NC}"
    done

    echo ""
    echo -e "${BOLD}All requested services are running in background.${NC}"
    echo -e "Logs directory: ${CYAN}${LOG_DIR}/${NC}"
    echo -e "View live logs with: ${CYAN}tail -f .logs/*.log${NC}"
    echo -e "Press ${BOLD}Ctrl+C${NC} to stop all services."
    echo ""

    # Keep script alive and stream logs
    wait
}

# ── Argument Parsing ──────────────────────────────────────────────────────────
if [ "$1" = "--list" ] || [ "$1" = "-l" ]; then
    show_list
    exit 0
fi

if [ "$1" = "--stop" ] || [ "$1" = "--down" ]; then
    stop_infra
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
    echo "  $0 <service-name>               Run single service in foreground (e.g. content-service)"
    echo "  $0 <svc1> <svc2> ...            Run multiple services on host with logs in .logs/"
    echo "  $0 --infra-only                 Start only required Docker infra (Postgres, Redis, Eureka, etc.)"
    echo "  $0 --stop                       Stop Docker infra containers"
    echo "  $0 --status                     Show health of containers and services"
    echo "  $0 --list                       List all available service names"
    exit 0
fi

# If no arguments provided, show an interactive menu
if [ $# -eq 0 ]; then
    echo -e "${BOLD}================================================${NC}"
    echo -e "${BOLD}      🌟 Vithey Microservices Host-Dev Runner   ${NC}"
    echo -e "${BOLD}================================================${NC}"
    echo "Select an option:"
    echo "  1) Start minimal infra containers only (Docker)"
    echo "  2) Run content-service (Feed, Posts, Comments, Stories)"
    echo "  3) Run auth-service + user-profile-service + api-gateway"
    echo "  4) Run career-service (Job Applications, CV)"
    echo "  5) Run chat-service"
    echo "  6) Run api-gateway only"
    echo "  7) Check status & health"
    echo "  8) Stop infra containers"
    echo "  9) Custom service name"
    echo "  0) Exit"
    echo ""
    read -rp "Enter choice [1-9]: " choice

    case "$choice" in
        1)
            start_infra
            exit 0
            ;;
        2)
            set -- "content-service"
            ;;
        3)
            set -- "auth-service" "user-profile-service" "api-gateway"
            ;;
        4)
            set -- "career-service"
            ;;
        5)
            set -- "chat-service"
            ;;
        6)
            set -- "api-gateway"
            ;;
        7)
            check_status
            exit 0
            ;;
        8)
            stop_infra
            exit 0
            ;;
        9)
            read -rp "Enter service name (e.g. file-service): " custom_svc
            if [ -n "$custom_svc" ]; then
                set -- "$custom_svc"
            else
                echo "No service entered. Exiting."
                exit 1
            fi
            ;;
        *)
            echo "Exiting."
            exit 0
            ;;
    esac
fi

# Start the required Docker infrastructure first
start_infra

# Dispatch to single or multiple runner
if [ $# -eq 1 ]; then
    run_single_service "$1"
else
    run_multiple_services "$@"
fi
