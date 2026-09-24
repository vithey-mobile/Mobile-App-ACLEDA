#!/usr/bin/env python3
"""
Vithey Microservices Dev TUI / CLI
===================================
A terminal user interface for managing Vithey backend microservices.
Runs shared infrastructure in Docker and Spring Boot services on the host JVM.
Zero external pip dependencies (uses Python standard library).
"""

import os
import sys
import time
import shutil
import termios
import tty
import subprocess
import urllib.request
import json
from pathlib import Path

# Paths
SCRIPT_DIR = Path(__file__).resolve().parent
BACKEND_DIR = SCRIPT_DIR.parent
ROOT_DIR = BACKEND_DIR.parent
LOG_DIR = BACKEND_DIR / ".logs"
SH_RUNNER = SCRIPT_DIR / "start-dev-host.sh"

# ANSI Colors & Styles
C_RESET = "\033[0m"
C_BOLD = "\033[1m"
C_DIM = "\033[2m"
C_CYAN = "\033[36m"
C_BRIGHT_CYAN = "\033[96m"
C_GREEN = "\033[32m"
C_BRIGHT_GREEN = "\033[92m"
C_YELLOW = "\033[33m"
C_BRIGHT_YELLOW = "\033[93m"
C_RED = "\033[31m"
C_BRIGHT_RED = "\033[91m"
C_BLUE = "\033[34m"
C_MAGENTA = "\033[35m"
C_WHITE = "\033[37m"
C_BG_BLUE = "\033[44m"
C_BG_DARK = "\033[40m"

# Services metadata
SERVICES = [
    {
        "name": "api-gateway",
        "port": 8080,
        "desc": "Spring Cloud Gateway (Main Entrypoint)",
        "icon": "🌐",
    },
    {
        "name": "auth-service",
        "port": 8081,
        "desc": "Authentication, JWT, & Student Verification",
        "icon": "🔐",
    },
    {
        "name": "user-profile-service",
        "port": 8082,
        "desc": "Student Profiles, Bios, & Avatars",
        "icon": "👤",
    },
    {
        "name": "file-service",
        "port": 8083,
        "desc": "MinIO Media & File Storage",
        "icon": "📁",
    },
    {
        "name": "content-service",
        "port": 8084,
        "desc": "Social Feed, Posts, Comments, & Stories",
        "icon": "📰",
    },
    {
        "name": "career-service",
        "port": 8085,
        "desc": "Jobs, Internships, Applications, & CVs",
        "icon": "💼",
    },
    {
        "name": "finance-service",
        "port": 8086,
        "desc": "Student Financials, Balances, & History",
        "icon": "💳",
    },
    {
        "name": "chat-service",
        "port": 8087,
        "desc": "Real-time Peer Chat & WebSockets",
        "icon": "💬",
    },
    {
        "name": "notification-service",
        "port": 8088,
        "desc": "Push Notifications & Announcements",
        "icon": "🔔",
    },
    {
        "name": "map-service",
        "port": 8090,
        "desc": "Campus Map & Google Places (Opt-in)",
        "icon": "🗺️",
    },
]

INFRA_CONTAINERS = [
    {"name": "vithey-postgres", "port": 15432, "desc": "PostgreSQL 16 DB"},
    {"name": "vithey-redis", "port": 16379, "desc": "Redis 7 Cache"},
    {"name": "vithey-rabbitmq", "port": 5672, "desc": "RabbitMQ Broker"},
    {"name": "vithey-minio", "port": 19000, "desc": "MinIO S3 Storage"},
    {"name": "vithey-eureka-server", "port": 8761, "desc": "Eureka Registry"},
    {"name": "vithey-config-server", "port": 8888, "desc": "Config Server"},
    {"name": "vithey-ai-core", "port": 8100, "desc": "Python AI Engine"},
]


def clear_screen():
    sys.stdout.write("\033[2J\033[H")
    sys.stdout.flush()


def get_terminal_width():
    return min(shutil.get_terminal_size((80, 24)).columns, 90)


def print_banner():
    w = get_terminal_width()
    border = "═" * (w - 2)
    print(f"{C_BRIGHT_CYAN}╔{border}╗{C_RESET}")
    title = "🌟 VITHEY MICROSERVICES DEV RUNNER 🌟"
    print(f"{C_BRIGHT_CYAN}║{C_BOLD}{title.center(w - 2)}{C_RESET}{C_BRIGHT_CYAN}║{C_RESET}")
    subtitle = "Lightweight Docker Infra  •  Host JVM Code Execution  •  macOS / Linux"
    print(f"{C_BRIGHT_CYAN}║{C_DIM}{subtitle.center(w - 2)}{C_RESET}{C_BRIGHT_CYAN}║{C_RESET}")
    print(f"{C_BRIGHT_CYAN}╚{border}╝{C_RESET}")


def get_key():
    """Read a single keypress or escape sequence from stdin."""
    if not sys.stdin.isatty():
        line = sys.stdin.readline()
        return line.strip() if line else "QUIT"

    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        if ch == "\x1b":
            ch2 = sys.stdin.read(1)
            if ch2 == "[":
                ch3 = sys.stdin.read(1)
                if ch3 == "A":
                    return "UP"
                elif ch3 == "B":
                    return "DOWN"
                elif ch3 == "C":
                    return "RIGHT"
                elif ch3 == "D":
                    return "LEFT"
            return "ESC"
        elif ch in ("\r", "\n"):
            return "ENTER"
        elif ch == "\x03":  # Ctrl+C
            return "QUIT"
        elif ch == " ":
            return "SPACE"
        return ch
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)


def check_http_health(url, timeout=0.8):
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Vithey-CLI"})
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return resp.status == 200
    except Exception:
        return False


def check_port_open(port):
    import socket

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(0.3)
        return s.connect_ex(("localhost", port)) == 0


def render_menu(options, selected_idx, prompt="Select an action:"):
    clear_screen()
    print_banner()
    print()
    print(f" {C_BOLD}{C_WHITE}{prompt}{C_RESET}")
    print(f" {C_DIM}Use [↑/↓] or [j/k] to navigate, [Enter] to select, [q] to quit{C_RESET}")
    print()

    w = get_terminal_width()
    for idx, opt in enumerate(options):
        is_sel = idx == selected_idx
        prefix = f"{C_BRIGHT_CYAN}❯{C_RESET} " if is_sel else "  "
        title = opt.get("label", "")
        hint = opt.get("hint", "")

        if is_sel:
            line = f"{prefix}{C_BOLD}{C_BRIGHT_GREEN}▶ {title:<42}{C_RESET} {C_BRIGHT_CYAN}{hint}{C_RESET}"
        else:
            line = f"{prefix}  {title:<42} {C_DIM}{hint}{C_RESET}"
        print(f" {line}")
    print()


def interactive_select(options, prompt="Select an option:"):
    idx = 0
    while True:
        render_menu(options, idx, prompt)
        k = get_key()
        if k in ("UP", "k"):
            idx = (idx - 1) % len(options)
        elif k in ("DOWN", "j"):
            idx = (idx + 1) % len(options)
        elif k == "ENTER":
            return idx
        elif k in ("q", "QUIT", "ESC"):
            return None
        elif k.isdigit():
            val = int(k)
            if 1 <= val <= len(options):
                return val - 1


def run_command_interactive(cmd_args):
    clear_screen()
    try:
        subprocess.run(cmd_args, cwd=str(BACKEND_DIR))
    except KeyboardInterrupt:
        print(f"\n{C_YELLOW}Interrupted.{C_RESET}")
    print(f"\n{C_DIM}Press any key to return to menu...{C_RESET}")
    get_key()


def show_status_screen():
    clear_screen()
    print_banner()
    print()
    print(f" {C_BOLD}📊 REAL-TIME HEALTH & STATUS MATRIX{C_RESET}")
    print(f" {C_DIM}Checking Docker containers and host microservices...{C_RESET}\n")

    w = get_terminal_width()

    # 1. Docker Infra Table
    print(f" {C_BOLD}{C_CYAN}── 🐳 Docker Infrastructure Containers ──{C_RESET}")
    for infra in INFRA_CONTAINERS:
        name = infra["name"]
        port = infra["port"]
        desc = infra["desc"]
        is_open = check_port_open(port)
        if is_open:
            status_badge = f"{C_GREEN}● RUNNING{C_RESET}"
        else:
            status_badge = f"{C_RED}○ STOPPED{C_RESET}"
        print(f"   {status_badge}  {C_BOLD}{name:<23}{C_RESET} Port: {port:<6} {C_DIM}({desc}){C_RESET}")

    print()
    # 2. Microservices Table
    print(f" {C_BOLD}{C_CYAN}── ☕ Host Microservices (Spring Boot) ──{C_RESET}")
    for svc in SERVICES:
        name = svc["name"]
        port = svc["port"]
        icon = svc["icon"]
        url = f"http://localhost:{port}/actuator/health"
        is_healthy = check_http_health(url)

        if is_healthy:
            status_badge = f"{C_BRIGHT_GREEN}● UP{C_RESET}     "
            port_str = f"{C_GREEN}http://localhost:{port}{C_RESET}"
        elif check_port_open(port):
            status_badge = f"{C_YELLOW}▲ BUSY{C_RESET}   "
            port_str = f"{C_YELLOW}http://localhost:{port} (Starting/Port Busy){C_RESET}"
        else:
            status_badge = f"{C_DIM}○ DOWN{C_RESET}   "
            port_str = f"{C_DIM}http://localhost:{port}{C_RESET}"

        print(f"   {icon} {status_badge}  {C_BOLD}{name:<22}{C_RESET} {port_str}")

    print()
    if not sys.stdin.isatty():
        return
    print(f" {C_DIM}[r] Refresh  •  [b] Back to Main Menu{C_RESET}")
    while True:
        k = get_key()
        if k in ("r", "R"):
            show_status_screen()
            return
        elif k in ("b", "B", "q", "QUIT", "ESC", "ENTER"):
            return


def show_single_service_menu():
    opts = []
    for s in SERVICES:
        opts.append({
            "label": f"{s['icon']} {s['name']}",
            "hint": f":{s['port']} - {s['desc']}",
            "value": s["name"]
        })
    opts.append({"label": "⬅️  Back to Main Menu", "hint": "", "value": None})

    choice = interactive_select(opts, prompt="Select a Microservice to Run on Host JVM:")
    if choice is not None and opts[choice]["value"] is not None:
        svc_name = opts[choice]["value"]
        run_command_interactive([str(SH_RUNNER), svc_name])


def show_log_viewer_menu():
    opts = []
    for s in SERVICES:
        log_file = LOG_DIR / f"{s['name']}.log"
        has_log = log_file.exists()
        size_str = f"({log_file.stat().st_size // 1024} KB)" if has_log else "(No log yet)"
        opts.append({
            "label": f"{s['icon']} {s['name']}",
            "hint": size_str,
            "value": s["name"]
        })
    opts.append({"label": "⬅️  Back to Main Menu", "hint": "", "value": None})

    choice = interactive_select(opts, prompt="Select a Microservice Log to View:")
    if choice is not None and opts[choice]["value"] is not None:
        svc_name = opts[choice]["value"]
        log_file = LOG_DIR / f"{svc_name}.log"
        clear_screen()
        if not log_file.exists():
            print(f"\n{C_YELLOW}No log file found at {log_file}. Run the service first.{C_RESET}")
            print(f"{C_DIM}Press any key to go back...{C_RESET}")
            get_key()
            return
        print(f"{C_CYAN}Streaming logs for {C_BOLD}{svc_name}{C_RESET} ({log_file})... Press Ctrl+C to exit.{C_RESET}\n")
        try:
            subprocess.run(["tail", "-n", "40", "-f", str(log_file)])
        except KeyboardInterrupt:
            pass


def main():
    # If arguments passed directly, forward to start-dev-host.sh (CLI mode)
    if len(sys.argv) > 1:
        arg1 = sys.argv[1]
        if arg1 in ("--help", "-h"):
            print_banner()
            print("""
Usage:
  ./run-backend-dev.sh                 Interactive TUI Dashboard (Menu, Status, Logs)
  ./run-backend-dev.sh all             Run all needed containers and all 9 host services
  ./run-backend-dev.sh <service-name>  Run single service in foreground (e.g. content-service)
  ./run-backend-dev.sh --infra-only    Start only Docker infrastructure containers
  ./run-backend-dev.sh --status        Print status table and exit
  ./run-backend-dev.sh --stop          Stop all services and containers
  ./run-backend-dev.sh --list          List available services
            """)
            sys.exit(0)
        elif arg1 == "--status":
            show_status_screen()
            sys.exit(0)
        else:
            # Forward directly to bash runner
            subprocess.run([str(SH_RUNNER)] + sys.argv[1:], cwd=str(BACKEND_DIR))
            sys.exit(0)

    # Main Interactive Loop
    main_options = [
        {
            "label": "🚀 1. Launch Full Stack",
            "hint": "Docker Infra + All 9 Host Microservices",
            "action": "full_stack"
        },
        {
            "label": "🎯 2. Run Single Service",
            "hint": "Choose 1 service to run with live foreground logs",
            "action": "single_service"
        },
        {
            "label": "🐳 3. Start Docker Infra Only",
            "hint": "Postgres, Redis, RabbitMQ, MinIO, Eureka, Config, AI Core",
            "action": "infra_only"
        },
        {
            "label": "📊 4. Health & Status Matrix",
            "hint": "View real-time UP/DOWN status of all ports",
            "action": "status"
        },
        {
            "label": "📜 5. Stream Service Logs",
            "hint": "View live tail logs from background runs",
            "action": "logs"
        },
        {
            "label": "🛑 6. Stop Everything",
            "hint": "Stop all running host services & Docker containers",
            "action": "stop"
        },
        {
            "label": "🚪 7. Exit",
            "hint": "Close runner",
            "action": "exit"
        }
    ]

    while True:
        choice = interactive_select(main_options, prompt="Vithey Dev Menu (Select an action):")
        if choice is None:
            break

        action = main_options[choice]["action"]
        if action == "full_stack":
            run_command_interactive([str(SH_RUNNER), "all"])
        elif action == "single_service":
            show_single_service_menu()
        elif action == "infra_only":
            run_command_interactive([str(SH_RUNNER), "--infra-only"])
        elif action == "status":
            show_status_screen()
        elif action == "logs":
            show_log_viewer_menu()
        elif action == "stop":
            run_command_interactive([str(SH_RUNNER), "--stop"])
        elif action == "exit":
            clear_screen()
            print(f"\n{C_BRIGHT_GREEN}👋 Happy Coding! Vithey runner exited.{C_RESET}\n")
            break


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        clear_screen()
        print(f"\n{C_YELLOW}Exited.{C_RESET}\n")
        sys.exit(0)
