#!/usr/bin/env bash
# Vithey Backend Dev Runner (TUI & CLI)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v python3 >/dev/null 2>&1; then
    exec python3 "${ROOT_DIR}/backend/scripts/dev-cli.py" "$@"
else
    exec "${ROOT_DIR}/backend/scripts/start-dev-host.sh" "$@"
fi
