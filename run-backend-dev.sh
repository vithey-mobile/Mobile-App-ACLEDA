#!/usr/bin/env bash
# Vithey Backend Dev Runner Shortcut
# Forwards all arguments to backend/scripts/start-dev-host.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${ROOT_DIR}/backend/scripts/start-dev-host.sh" "$@"
