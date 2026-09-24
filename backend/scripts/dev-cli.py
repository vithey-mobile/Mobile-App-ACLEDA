#!/usr/bin/env python3
"""
Vithey Microservices Dev CLI / TUI
===================================
A high-performance, minimalist terminal interface for Vithey microservices.
Zero external dependencies (uses standard library only).
"""

import os
import sys
import time
import shutil
import socket
import subprocess
import platform
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

# Cross-platform keyboard handling
IS_WINDOWS = sys.platform == "win32"
if IS_WINDOWS:
    import msvcrt
else:
    import termios
    import tty

# Paths
SCRIPT_DIR = Path(__file__).resolve().parent
BACKEND_DIR = SCRIPT_DIR.parent
ROOT_DIR = BACKEND_DIR.parent
LOG_DIR = BACKEND_DIR / ".logs"
SH_RUNNER = SCRIPT_DIR / "start-dev-host.sh"
PS_RUNNER = SCRIPT_DIR / "start-dev-host.ps1"

# ANSI Styles
RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[2m"
CYAN = "\033[36m"
B_CYAN = "\033[96m"
GREEN = "\033[32m"
B_GREEN = "\033[92m"
YELLOW = "\033[33m"
B_YELLOW = "\033[93m"
RED = "\033[31m"
WHITE = "\033[37m"

# Services metadata
SERVICES = [
    {"name": "api-gateway", "port": 8080},
    {"name": "auth-service", "port": 8081},
    {"name": "user-profile-service", "port": 8082},
    {"name": "file-service", "port": 8083},
    {"name": "content-service", "port": 8084},
    {"name": "career-service", "port": 8085},
    {"name": "finance-service", "port": 8086},
    {"name": "chat-service", "port": 8087},
    {"name": "notification-service", "port": 8088},
    {"name": "map-service", "port": 8090},
]

INFRA_CONTAINERS = [
    {"name": "vithey-postgres", "port": 15432},
    {"name": "vithey-redis", "port": 16379},
    {"name": "vithey-rabbitmq", "port": 5672},
    {"name": "vithey-minio", "port": 19000},
    {"name": "vithey-eureka-server", "port": 8761},
    {"name": "vithey-config-server", "port": 8888},
    {"name": "vithey-ai-core", "port": 8100},
]


def get_system_specs():
    cpu = "Host CPU"
    if sys.platform == "darwin":
        try:
            cpu = subprocess.check_output(["sysctl", "-n", "machdep.cpu.brand_string"], text=True).strip()
        except Exception:
            cpu = platform.processor() or "Apple Silicon"
    elif sys.platform.startswith("linux"):
        try:
            with open("/proc/cpuinfo") as f:
                for line in f:
                    if "model name" in line:
                        cpu = line.split(":", 1)[1].strip()
                        break
        except Exception:
            cpu = platform.processor() or "Linux CPU"
    elif sys.platform == "win32":
        cpu = platform.processor() or "Windows CPU"

    cores = os.cpu_count() or 4

    try:
        if sys.platform == "darwin":
            mem_bytes = int(subprocess.check_output(["sysctl", "-n", "hw.memsize"], text=True).strip())
        elif sys.platform.startswith("linux"):
            mem_bytes = os.sysconf("SC_PAGE_SIZE") * os.sysconf("SC_PHYS_PAGES")
        else:
            mem_bytes = 16 * (1024**3)
        mem_gb = round(mem_bytes / (1024**3), 1)
    except Exception:
        mem_gb = 16.0

    return f"{cpu} ({cores} cores) | {mem_gb} GB RAM"


SYSTEM_SPECS = get_system_specs()


def clear_screen():
    sys.stdout.write("\033[2J\033[H")
    sys.stdout.flush()


def print_banner():
    w = 58
    inner = w - 2
    line = "─" * inner
    print(f"{B_CYAN}┌{line}┐{RESET}")
    print(f"{B_CYAN}│{BOLD}{'VITHEY RUNNER':^{inner}}{RESET}{B_CYAN}│{RESET}")
    print(f"{B_CYAN}│{DIM}{SYSTEM_SPECS:^{inner}}{RESET}{B_CYAN}│{RESET}")
    print(f"{B_CYAN}└{line}┘{RESET}")


def get_key():
    """Read a single keypress or escape sequence from stdin across all operating systems."""
    if not sys.stdin.isatty():
        line = sys.stdin.readline()
        return line.strip() if line else "QUIT"

    if IS_WINDOWS:
        try:
            ch = msvcrt.getch()
            if ch in (b"\x00", b"\xe0"):
                ch2 = msvcrt.getch()
                if ch2 == b"H":
                    return "UP"
                elif ch2 == b"P":
                    return "DOWN"
                elif ch2 == b"K":
                    return "LEFT"
                elif ch2 == b"M":
                    return "RIGHT"
            elif ch in (b"\r", b"\n"):
                return "ENTER"
            elif ch == b"\x03":
                return "QUIT"
            elif ch == b" ":
                return "SPACE"
            return ch.decode("utf-8", errors="ignore")
        except Exception:
            return ""
    else:
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


def probe_port(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(0.12)
        return s.connect_ex(("localhost", port)) == 0


def probe_http(url):
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "vithey-cli"})
        with urllib.request.urlopen(req, timeout=0.25) as resp:
            return resp.status == 200
    except Exception:
        return False


def probe_infra(infra):
    is_open = probe_port(infra["port"])
    return (infra["name"], infra["port"], is_open)


def probe_service(svc):
    port = svc["port"]
    url = f"http://localhost:{port}/actuator/health"
    is_up = probe_http(url)
    is_open = probe_port(port) if not is_up else True
    ram_mb = 0.0
    cpu = 0.0
    if is_open:
        try:
            pid_out = subprocess.check_output(["lsof", "-ti", f":{port}"], text=True).strip()
            if pid_out:
                p = int(pid_out.split()[0])
                ps_out = subprocess.check_output(["ps", "-o", "%cpu,rss", "-p", str(p)], text=True)
                lines = ps_out.strip().splitlines()
                if len(lines) > 1:
                    parts = lines[1].split()
                    cpu = float(parts[0])
                    ram_mb = round(int(parts[1]) / 1024, 1)
        except Exception:
            pass
    return (svc["name"], port, is_up, is_open, ram_mb, cpu)


def render_menu(options, selected_idx, prompt="Select command:"):
    clear_screen()
    print_banner()
    print()
    print(f" {BOLD}{prompt}{RESET}")
    print()

    for idx, opt in enumerate(options):
        is_sel = idx == selected_idx
        num = f"[{idx + 1}]" if idx < len(options) - 1 else "[q]"
        title = opt["label"]
        hint = opt.get("hint", "")

        if is_sel:
            hint_str = f"  {DIM}{hint}{RESET}" if hint else ""
            print(f"  {B_CYAN}>{RESET} {BOLD}{B_GREEN}{num:<4} {title:<24}{RESET}{hint_str}")
        else:
            hint_str = f"  {DIM}{hint}{RESET}" if hint else ""
            print(f"    {num:<4} {title:<24}{hint_str}")

    print()
    print(f" {DIM}[↑/↓] Navigate  •  [Enter] Select  •  [q] Quit{RESET}")
    print()


def interactive_select(options, prompt="Select command:"):
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
        if IS_WINDOWS and cmd_args and cmd_args[0].endswith(".sh"):
            translated = ["powershell", "-ExecutionPolicy", "Bypass", "-File", str(PS_RUNNER)] + cmd_args[1:]
            subprocess.run(translated, cwd=str(BACKEND_DIR))
        else:
            if cmd_args and cmd_args[0].endswith(".sh"):
                run_cmd = ["bash"] + cmd_args
            else:
                run_cmd = cmd_args
            subprocess.run(run_cmd, cwd=str(BACKEND_DIR))
    except KeyboardInterrupt:
        print(f"\n{YELLOW}Interrupted.{RESET}")
    print(f"\n{DIM}Press any key to return to menu...{RESET}")
    get_key()


def show_status_screen():
    clear_screen()
    print_banner()
    print()
    print(f" {BOLD}STATUS MATRIX{RESET}\n")

    with ThreadPoolExecutor(max_workers=16) as pool:
        infra_results = list(pool.map(probe_infra, INFRA_CONTAINERS))
        svc_results = list(pool.map(probe_service, SERVICES))

    print(f" {BOLD}{CYAN}Docker Infrastructure:{RESET}")
    for name, port, is_open in infra_results:
        status = f"{B_GREEN}[RUNNING]{RESET}" if is_open else f"{DIM}[STOPPED]{RESET}"
        print(f"   {status:<18} {BOLD}{name:<22}{RESET} :{port}")

    print()
    print(f" {BOLD}{CYAN}Host Microservices:{RESET}")
    for name, port, is_up, is_open, ram_mb, cpu in svc_results:
        metrics = f"  {DIM}({ram_mb} MB RAM, {cpu}% CPU){RESET}" if ram_mb > 0 else ""
        if is_up:
            status = f"{B_GREEN}[UP]{RESET}     "
            port_str = f":{port}{metrics}"
        elif is_open:
            status = f"{B_YELLOW}[BUSY]{RESET}   "
            port_str = f":{port} (starting/busy){metrics}"
        else:
            status = f"{DIM}[DOWN]{RESET}   "
            port_str = f":{port}"

        print(f"   {status} {BOLD}{name:<22}{RESET} {port_str}")

    print()
    if not sys.stdin.isatty():
        return

    print(f" {DIM}[r] Refresh  •  [b/q] Back{RESET}")
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
            "label": s["name"],
            "hint": f":{s['port']}",
            "value": s["name"]
        })
    opts.append({"label": "Back", "hint": "", "value": None})

    choice = interactive_select(opts, prompt="Select service to run:")
    if choice is not None and opts[choice]["value"] is not None:
        svc_name = opts[choice]["value"]
        run_command_interactive([str(SH_RUNNER), svc_name])


def show_log_viewer_menu():
    opts = []
    for s in SERVICES:
        log_file = LOG_DIR / f"{s['name']}.log"
        has_log = log_file.exists()
        size_str = f"{log_file.stat().st_size // 1024} KB" if has_log else "empty"
        opts.append({
            "label": s["name"],
            "hint": size_str,
            "value": s["name"]
        })
    opts.append({"label": "Back", "hint": "", "value": None})

    choice = interactive_select(opts, prompt="Select log to tail:")
    if choice is not None and opts[choice]["value"] is not None:
        svc_name = opts[choice]["value"]
        log_file = LOG_DIR / f"{svc_name}.log"
        clear_screen()
        if not log_file.exists():
            print(f"\n{YELLOW}Log file not found: {log_file}{RESET}")
            print(f"{DIM}Press any key to return...{RESET}")
            get_key()
            return
        print(f"{B_CYAN}Tailing {svc_name}.log (Ctrl+C to return)...{RESET}\n")
        try:
            subprocess.run(["tail", "-n", "50", "-f", str(log_file)])
        except KeyboardInterrupt:
            pass


def main():
    if len(sys.argv) > 1:
        arg1 = sys.argv[1]
        if arg1 in ("--help", "-h"):
            print_banner()
            print("""
Usage:
  ./run-backend-dev.sh                 Interactive TUI Dashboard
  ./run-backend-dev.sh all             Run all infra + all 9 host services
  ./run-backend-dev.sh <service-name>  Run single service in foreground (e.g. content-service)
  ./run-backend-dev.sh --infra-only    Start Docker infrastructure containers only
  ./run-backend-dev.sh --status        Print status table and exit
  ./run-backend-dev.sh --stop          Stop all services and containers
  ./run-backend-dev.sh --list          List available services
            """)
            sys.exit(0)
        elif arg1 == "--status":
            show_status_screen()
            sys.exit(0)
        else:
            if IS_WINDOWS and sys.argv[1:]:
                translated = ["powershell", "-ExecutionPolicy", "Bypass", "-File", str(PS_RUNNER)] + sys.argv[1:]
                subprocess.run(translated, cwd=str(BACKEND_DIR))
            else:
                subprocess.run(["bash", str(SH_RUNNER)] + sys.argv[1:], cwd=str(BACKEND_DIR))
            sys.exit(0)

    main_options = [
        {"label": "Launch Full Stack", "hint": "", "action": "full_stack"},
        {"label": "Run Single Service", "hint": "", "action": "single_service"},
        {"label": "Start Docker Infra", "hint": "", "action": "infra_only"},
        {"label": "Status Matrix", "hint": "", "action": "status"},
        {"label": "Tail Logs", "hint": "", "action": "logs"},
        {"label": "Stop All", "hint": "", "action": "stop"},
        {"label": "Quit", "hint": "", "action": "exit"}
    ]

    while True:
        choice = interactive_select(main_options, prompt="Select command:")
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
            print(f"\n{GREEN}Exited.{RESET}\n")
            break


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        clear_screen()
        print(f"\n{YELLOW}Exited.{RESET}\n")
        sys.exit(0)
