#!/bin/bash
set -e

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$APP_DIR"

# Ensure .env exists
if [ ! -f .env ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
fi

# Detect Mac Local LAN IPv4 address (en0 = Wi-Fi, en1 = Ethernet / Thunderbolt)
LAN_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "")

if [ -n "$LAN_IP" ]; then
    echo "📡 Detected Mac LAN IP: $LAN_IP"
    # Update API_BASE_URL and WS_BASE_URL in .env
    sed -i '' "s|^API_BASE_URL=.*|API_BASE_URL=http://${LAN_IP}:8080/api/v1|" .env
    sed -i '' "s|^WS_BASE_URL=.*|WS_BASE_URL=ws://${LAN_IP}:8080/ws|" .env
    echo "✅ Synchronized vithey_app/.env -> http://${LAN_IP}:8080/api/v1"
    echo "   (This URL works on Android Emulators, iOS Simulators, AND Physical Devices on the same Wi-Fi)"
else
    echo "⚠️  Could not detect LAN IP, keeping existing .env settings."
fi

if [ "$1" = "--sync-only" ]; then
    exit 0
fi

# Automatically reverse Gateway (8080) and MinIO (19000) for connected USB Android devices
ADB_BIN="$(command -v adb 2>/dev/null || echo "$HOME/Library/Android/sdk/platform-tools/adb")"
if [ -x "$ADB_BIN" ]; then
    "$ADB_BIN" reverse tcp:8080 tcp:8080 2>/dev/null || true
    "$ADB_BIN" reverse tcp:19000 tcp:19000 2>/dev/null || true
fi

echo ""
echo "🚀 Launching Flutter..."
flutter run "$@"
