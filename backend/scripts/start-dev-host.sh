#!/usr/bin/env bash
# ==============================================================================
# Vithey Host-Dev Runner (macOS / Linux)
# ==============================================================================
# Executes shared infrastructure in Docker (Postgres, Redis, RabbitMQ, MinIO,
# Eureka, Config Server, AI Core) while compiling and executing Spring Boot
# microservices directly on the host JVM for high speed and instant iteration.
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${BACKEND_DIR}/.logs"

cd "${BACKEND_DIR}"

# ANSI Colors
BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
B_GREEN='\033[1;32m'
CYAN='\033[0;36m'
B_CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m'

# Auto-detect JDK 21 and Maven on macOS / Linux
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

    echo -e "${RED}[ERROR] Java 21 required but not found in PATH.${NC}"
    echo -e "        Install via: ${CYAN}brew install openjdk@21 maven${NC}"
    exit 1
}

if ! command -v mvn >/dev/null 2>&1; then
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
fi

detect_java

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

COMPOSE_FILES=("-f" "docker-compose.yml" "-f" "docker-compose.demo.yml")
INFRA_CONTAINERS=("postgres" "redis" "rabbitmq" "minio" "eureka-server" "config-server" "ai-core")

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
    echo -e "${YELLOW}[STOP] Terminating host microservices and Docker containers...${NC}"
    pkill -f "vithey-backend" 2>/dev/null || true
    pkill -f "spring-boot:run" 2>/dev/null || true
    docker compose "${COMPOSE_FILES[@]}" stop "${INFRA_CONTAINERS[@]}" 2>/dev/null || true
    echo -e "${GREEN}[OK] All services and containers stopped.${NC}"
}

check_status() {
    echo -e "${BOLD}── Docker Infrastructure ──${NC}"
    docker compose "${COMPOSE_FILES[@]}" ps "${INFRA_CONTAINERS[@]}" || true
    echo ""
    echo -e "${BOLD}── Service Health ──${NC}"
    echo -n "Config Server (:8888): "
    curl -sf http://localhost:8888/actuator/health | grep -q "UP" && echo -e "${GREEN}[UP]${NC}" || echo -e "${RED}[DOWN]${NC}"
    echo -n "Eureka Server (:8761): "
    curl -sf http://localhost:8761/actuator/health | grep -q "UP" && echo -e "${GREEN}[UP]${NC}" || echo -e "${RED}[DOWN]${NC}"
    echo -n "AI Core       (:8100): "
    curl -sf http://localhost:8100/health | grep -qi "healthy" && echo -e "${GREEN}[UP]${NC}" || echo -e "${RED}[DOWN]${NC}"
    echo -n "API Gateway   (:8080): "
    curl -sf http://localhost:8080/actuator/health | grep -q "UP" && echo -e "${GREEN}[UP]${NC}" || echo -e "${GRAY}[DOWN]${NC}"
}

start_infra() {
    echo -e "${CYAN}[INFRA] Ensuring Docker infrastructure is running...${NC}"
    docker compose "${COMPOSE_FILES[@]}" up -d "${INFRA_CONTAINERS[@]}"

    local max_retries=30
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
            echo -e "${GREEN}[OK] Config Server and Eureka ready.${NC}"
            return 0
        fi
        sleep 1
    done

    echo -e "${YELLOW}[WARN] Infra startup check completed.${NC}"
}

ensure_no_container_conflict() {
    local svc="$1"
    local running
    running=$(docker compose "${COMPOSE_FILES[@]}" ps -q "$svc" 2>/dev/null || true)
    if [ -n "$running" ]; then
        echo -e "${YELLOW}[DOCKER] Stopping container '$svc' to release host port...${NC}"
        docker compose "${COMPOSE_FILES[@]}" stop "$svc" >/dev/null 2>&1 || true
    fi

    # Release host port if an external process is holding it
    local port
    port=$(get_service_port "$svc")
    local pids
    pids=$(lsof -ti :"$port" 2>/dev/null || true)
    if [ -n "$pids" ]; then
        echo -e "${YELLOW}[PORT] Freeing port ${port} (PID: ${pids}) for ${svc}...${NC}"
        for p in $pids; do
            kill -9 "$p" 2>/dev/null || true
        done
        sleep 0.2
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

ensure_fast_dependencies() {
    local m2_parent="$HOME/.m2/repository/com/vithey/vithey-backend/0.0.1-SNAPSHOT/vithey-backend-0.0.1-SNAPSHOT.pom"
    local m2_test="$HOME/.m2/repository/com/vithey/vithey-test-support/0.0.1-SNAPSHOT/vithey-test-support-0.0.1-SNAPSHOT.jar"

    if [ ! -f "$m2_parent" ]; then
        mvn -N install -DskipTests -q 2>/dev/null || true
    fi
    if [ ! -f "$m2_test" ]; then
        mvn -pl shared/vithey-test-support install -DskipTests -q 2>/dev/null || true
    fi
}

print_service_guide() {
    local svc="$1"
    local port
    port=$(get_service_port "$svc")

    echo ""
    echo -e "${CYAN}┌────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}Service:${NC}        ${GREEN}${svc}${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}Direct URL:${NC}     ${B_CYAN}http://localhost:${port}${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}Health URL:${NC}     ${B_CYAN}http://localhost:${port}/actuator/health${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}Gateway:${NC}        ${B_CYAN}http://localhost:8080/api/v1/...${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}Infra (Docker):${NC} Postgres (15432) | Redis (16379) | Eureka (8761) | AI"
    echo -e "${CYAN}│${NC} ${BOLD}Control:${NC}        Press ${YELLOW}Ctrl+C${NC} to stop"
    echo -e "${CYAN}└────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# Run a single service in foreground
run_single_service() {
    local svc="$1"
    ensure_no_container_conflict "$svc"
    set_host_env "$svc"
    ensure_fast_dependencies

    local jvm_args="-Xms64m -Xmx256m -XX:+UseSerialGC -XX:MaxMetaspaceSize=128m -Dspring.jmx.enabled=false"

    print_service_guide "$svc"

    mvn -f "services/${svc}/pom.xml" spring-boot:run -Dspring-boot.run.jvmArguments="${jvm_args}"
}

# Run multiple services as background processes
run_multiple_services() {
    local services=("$@")
    mkdir -p "${LOG_DIR}"

    ensure_fast_dependencies

    local pids=()
    cleanup() {
        echo -e "\n\n${YELLOW}[STOP] Terminating host microservices...${NC}"
        for pid in "${pids[@]}"; do
            kill "$pid" 2>/dev/null || true
        done
        wait 2>/dev/null || true
        echo -e "${GREEN}[OK] All host microservices stopped cleanly.${NC}"
        exit 0
    }
    trap cleanup SIGINT SIGTERM

    echo ""
    echo -e "${CYAN}┌────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}VITHEY FULL STACK ACTIVE${NC}"
    echo -e "${CYAN}│${NC} ${DIM}Docker Infra:  Postgres (15432), Redis (16379), RabbitMQ, MinIO, AI    ${NC}"
    echo -e "${CYAN}│${NC} ${DIM}Host Services: Launching ${#services[@]} Spring Boot JVMs                      ${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────────────────────┘${NC}"

    for svc in "${services[@]}"; do
        ensure_no_container_conflict "$svc"
        local port
        port=$(get_service_port "$svc")
        (
            set_host_env "$svc"
            local jvm_args="-Xms48m -Xmx160m -XX:+UseSerialGC -XX:MaxMetaspaceSize=80m -Dspring.jmx.enabled=false"
            mvn -f "services/${svc}/pom.xml" spring-boot:run -Dspring-boot.run.jvmArguments="${jvm_args}" > "${LOG_DIR}/${svc}.log" 2>&1
        ) &
        local pid=$!
        pids+=("$pid")
        echo -e "  -> ${B_GREEN}${svc:<22}${NC} :${port:<5} (PID ${pid}) [Log: .logs/${svc}.log]"
        sleep 0.15
    done

    echo ""
    echo -e "${CYAN}Gateway:  ${B_CYAN}http://localhost:8080/api/v1/...${NC}"
    echo -e "${CYAN}Live Log: ${B_CYAN}tail -f .logs/*.log${NC}"
    echo -e "${DIM}Press Ctrl+C to terminate all services.${NC}"
    echo ""

    # Monitor health
    local pending=("${services[@]}")
    while [ ${#pending[@]} -gt 0 ]; do
        sleep 2
        local next_pending=()
        for svc in "${pending[@]}"; do
            local port
            port=$(get_service_port "$svc")
            if curl -sf "http://localhost:${port}/actuator/health" | grep -q "UP" 2>/dev/null; then
                echo -e "  [UP] ${B_GREEN}${svc}${NC} (http://localhost:${port})"
            else
                next_pending+=("$svc")
            fi
        done
        pending=("${next_pending[@]}")
    done

    echo -e "\n${BOLD}${B_GREEN}All requested services are UP and operational.${NC}\n"

    wait
}

# ── Argument Dispatcher ───────────────────────────────────────────────────────
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
    echo -e "${GREEN}[OK] Infrastructure containers running.${NC}"
    exit 0
fi

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo -e "${BOLD}Vithey Host-Dev Runner${NC}"
    echo ""
    echo "Usage:"
    echo "  $0 all                          Run all infra + all 9 host services"
    echo "  $0 <service-name>               Run single service in foreground (e.g. content-service)"
    echo "  $0 <svc1> <svc2> ...            Run specific services on host"
    echo "  $0 --infra-only                 Start Docker infra containers only"
    echo "  $0 --stop                       Stop all services and containers"
    echo "  $0 --status                     Show health of containers and services"
    echo "  $0 --list                       List all available services"
    exit 0
fi

start_infra

if [ $# -eq 0 ] || [ "$1" = "all" ] || [ "$1" = "--all" ]; then
    run_multiple_services "${DEFAULT_SERVICES[@]}"
elif [ $# -eq 1 ]; then
    run_single_service "$1"
else
    run_multiple_services "$@"
fi
