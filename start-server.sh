#!/usr/bin/env bash
# =============================================================================
# start-server.sh — Final, 100% working version (macOS + LAN access)
# =============================================================================

set -euo pipefail

INSTANCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="/Users/jethroestrada/Desktop/External_Projects/AI/apps/searxng"
SETTINGS_PATH="$INSTANCE_DIR/settings.yml"
VENV_DIR="$REPO_ROOT/.venv"

MODE="${1:-dev}"
HOST="0.0.0.0"
PORT="8888"

source "$VENV_DIR/bin/activate"
export SEARXNG_SETTINGS_PATH="$SETTINGS_PATH"

# Get your local IP the macOS way (Wi-Fi = en0, Ethernet = en1)
LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "?.?.?.?")

echo "SearXNG — Starting ($MODE mode)"
echo "================================================================="
echo "Local access   → http://127.0.0.1:8888"
echo "LAN access     → http://$LOCAL_IP:8888"
echo "Settings       → $SETTINGS_PATH"
echo "================================================================="
echo

case "$MODE" in
  dev|development|debug)
    exec flask --app searx.webapp run --debug --host="$HOST" --port="$PORT"
    ;;

  prod|production|gunicorn)
    # Auto-scale workers for your M1 (e.g. 8-core → 17 workers)
    WORKERS="$(( 2 * $(sysctl -n hw.logicalcpu) + 1 ))"
    echo "Starting gunicorn with $WORKERS workers..."
    exec gunicorn \
      -w "$WORKERS" \
      -b "$HOST:$PORT" \
      --access-logfile - \
      --error-logfile - \
      --log-level info \
      "searx.webapp:init(); searx.webapp.application"
    ;;

  *)
    echo "Usage: $0 [dev|prod]"
    exit 1
    ;;
esac