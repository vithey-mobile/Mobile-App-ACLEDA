#!/usr/bin/env bash
# Vithey Backend Dev Runner - Single universal script for all OS (macOS, Linux, Windows)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v python3 >/dev/null 2>&1; then
    exec python3 "${ROOT_DIR}/backend/scripts/dev-cli.py" "$@"
elif command -v python >/dev/null 2>&1; then
    exec python "${ROOT_DIR}/backend/scripts/dev-cli.py" "$@"
else
    exec "${ROOT_DIR}/backend/scripts/start-dev-host.sh" "$@"
fi
