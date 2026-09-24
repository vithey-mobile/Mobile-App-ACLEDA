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
import termios
import tty
import socket
import subprocess
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

# Paths
SCRIPT_DIR = Path(__file__).resolve().parent
BACKEND_DIR = SCRIPT_DIR.parent
ROOT_DIR = BACKEND_DIR.parent
LOG_DIR = BACKEND_DIR / ".logs"
SH_RUNNER = SCRIPT_DIR / "start-dev-host.sh"

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
    try:
        cpu = subprocess.check_output(["sysctl", "-n", "machdep.cpu.brand_string"], text=True).strip()
    except Exception:
        cpu = "Host CPU"
    try:
        cores = subprocess.check_output(["sysctl", "-n", "hw.ncpu"], text=True).strip()
    except Exception:
        cores = str(os.cpu_count() or 4)
    try:
        mem_bytes = int(subprocess.check_output(["sysctl", "-n", "hw.memsize"], text=True).strip())
        mem_gb = round(mem_bytes / (1024**3), 1)
    except Exception:
        mem_gb = "Host"
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
        subprocess.run(cmd_args, cwd=str(BACKEND_DIR))
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


def run_live_monitor(target_args):
    """
    Real-time dynamic resource & health monitor for running services.
    target_args: list of 'name:port:pid' strings
    """
    targets = []
    for item in target_args:
        parts = item.split(":")
        if len(parts) >= 3:
            targets.append({
                "name": parts[0],
                "port": int(parts[1]),
                "mvn_pid": int(parts[2]),
            })

    if not targets:
        print("No services to monitor.")
        return

    first_render = True
    num_rendered_lines = 0

    try:
        while True:
            def probe_target(t):
                svc_pid = t["mvn_pid"]
                try:
                    pids_out = subprocess.check_output(["lsof", "-ti", f":{t['port']}"], text=True).strip()
                    if pids_out:
                        svc_pid = int(pids_out.split()[0])
                except Exception:
                    try:
                        child = subprocess.check_output(["pgrep", "-P", str(t["mvn_pid"])], text=True).strip()
                        if child:
                            svc_pid = int(child.split()[0])
                    except Exception:
                        pass

                is_up = probe_http(f"http://localhost:{t['port']}/actuator/health")
                is_open = probe_port(t["port"]) if not is_up else True

                is_alive = is_open or is_up
                if not is_alive:
                    try:
                        os.kill(svc_pid, 0)
                        is_alive = True
                    except OSError:
                        try:
                            os.kill(t["mvn_pid"], 0)
                            is_alive = True
                            svc_pid = t["mvn_pid"]
                        except OSError:
                            pass

                cpu = 0.0
                rss_mb = 0.0
                if is_alive:
                    try:
                        ps_out = subprocess.check_output(["ps", "-o", "%cpu,rss", "-p", str(svc_pid)], text=True)
                        lines = ps_out.strip().splitlines()
                        if len(lines) > 1:
                            parts = lines[1].split()
                            cpu = float(parts[0])
                            rss_mb = round(int(parts[1]) / 1024, 1)
                    except Exception:
                        pass

                if is_up:
                    raw_status = "UP"
                    color = B_GREEN
                elif is_open:
                    raw_status = "STARTING"
                    color = B_YELLOW
                elif is_alive:
                    raw_status = "BOOTING"
                    color = B_YELLOW
                else:
                    raw_status = "DOWN"
                    color = RED

                return {
                    "name": t["name"],
                    "port": t["port"],
                    "raw_status": raw_status,
                    "color": color,
                    "is_up": is_up,
                    "is_open": is_open,
                    "is_alive": is_alive,
                    "rss_mb": rss_mb,
                    "cpu": cpu,
                }

            with ThreadPoolExecutor(max_workers=len(targets)) as pool:
                rows = list(pool.map(probe_target, targets))

            total_rss_mb = sum(r["rss_mb"] for r in rows)
            total_cpu = sum(r["cpu"] for r in rows)
            total_gb = round(total_rss_mb / 1024, 2)
            all_up = all(r["is_up"] for r in rows)

            try:
                mem_bytes = int(subprocess.check_output(["sysctl", "-n", "hw.memsize"], text=True).strip())
                sys_ram_gb = round(mem_bytes / (1024**3), 1)
                ram_pct = round((total_rss_mb / (sys_ram_gb * 1024)) * 100, 1)
            except Exception:
                sys_ram_gb = 24.0
                ram_pct = round((total_rss_mb / (24.0 * 1024)) * 100, 1)

            w1, w2, w3, w4, w5 = 23, 7, 10, 11, 17
            out_lines = []
            top_line = "─" * 72
            out_lines.append(f"{B_CYAN}┌{top_line}┐{RESET}")

            title = "VITHEY LIVE RUNTIME MONITOR"
            refresh = "[Refresh: 2s]"
            inner_title = f" {BOLD}{title:<56}{RESET}{DIM}{refresh:>14}{RESET} "
            out_lines.append(f"{B_CYAN}│{RESET}{inner_title}{B_CYAN}│{RESET}")

            inner_hw = f" {DIM}Hardware: {SYSTEM_SPECS:<60}{RESET} "
            out_lines.append(f"{B_CYAN}│{RESET}{inner_hw}{B_CYAN}│{RESET}")

            up_count = sum(1 for r in rows if r['is_up'])
            status_summary = f"ALL {len(rows)} SERVICES UP" if all_up else f"BOOTING ({up_count}/{len(rows)} UP)"
            stack_text = f"Stack: {status_summary} | Total RAM: {total_gb} GB ({ram_pct}%) | CPU: {total_cpu:.1f}%"
            color_summary = B_GREEN if all_up else B_YELLOW
            inner_stack = f" {BOLD}{color_summary}{stack_text:<70}{RESET} "
            out_lines.append(f"{B_CYAN}│{RESET}{inner_stack}{B_CYAN}│{RESET}")

            hdr_sep = f"├{'─'*w1}┬{'─'*w2}┬{'─'*w3}┬{'─'*w4}┬{'─'*w5}┤"
            out_lines.append(f"{B_CYAN}{hdr_sep}{RESET}")

            hdr_cols = f"│ {BOLD}{'SERVICE':<21}{RESET} │ {BOLD}{'PORT':<5}{RESET} │ {BOLD}{'STATUS':<8}{RESET} │ {BOLD}{'RAM (RSS)':<9}{RESET} │ {BOLD}{'CPU':<15}{RESET} │"
            out_lines.append(f"{B_CYAN}{hdr_cols}{RESET}")

            mid_sep = f"├{'─'*w1}┼{'─'*w2}┼{'─'*w3}┼{'─'*w4}┼{'─'*w5}┤"
            out_lines.append(f"{B_CYAN}{mid_sep}{RESET}")

            for r in rows:
                status_styled = f"{r['color']}{r['raw_status']:<8}{RESET}"
                ram_str = f"{r['rss_mb']} MB" if r['rss_mb'] > 0 else "-"
                cpu_str = f"{r['cpu']}%" if r['cpu'] > 0 else "-"
                port_str = f":{r['port']}"
                row_str = f"│ {r['name']:<21} │ {port_str:<5} │ {status_styled} │ {ram_str:<9} │ {cpu_str:<15} │"
                out_lines.append(f"{B_CYAN}{row_str}{RESET}")

            bot_sep = f"└{'─'*w1}┴{'─'*w2}┴{'─'*w3}┴{'─'*w4}┴{'─'*w5}┘"
            out_lines.append(f"{B_CYAN}{bot_sep}{RESET}")
            out_lines.append(f" {CYAN}Gateway:{RESET}  {B_CYAN}http://localhost:8080/api/v1/...{RESET}")
            out_lines.append(f" {CYAN}Logs:{RESET}     {DIM}tail -f backend/.logs/*.log{RESET}")
            out_lines.append(f" {CYAN}Control:{RESET}  {YELLOW}Press Ctrl+C to terminate all services.{RESET}")

            # Cursor to top-left, overwrite each line with line clear, clear remaining lines
            sys.stdout.write("\033[H")
            for line in out_lines:
                sys.stdout.write("\033[2K" + line + "\n")
            sys.stdout.write("\033[J")
            sys.stdout.flush()

            time.sleep(2)

    except KeyboardInterrupt:
        sys.stdout.write("\n")
        sys.stdout.flush()


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
        elif arg1 == "--monitor":
            run_live_monitor(sys.argv[2:])
            sys.exit(0)
        else:
            subprocess.run([str(SH_RUNNER)] + sys.argv[1:], cwd=str(BACKEND_DIR))
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
