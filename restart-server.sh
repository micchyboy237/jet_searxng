#!/usr/bin/env bash
# =============================================================================
# restart-server.sh — Restart SearXNG server
# =============================================================================
set -euo pipefail

INSTANCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MODE="${1:-dev}"

echo "Restarting SearXNG..."

"$INSTANCE_DIR/stop-server.sh"

sleep 1

"$INSTANCE_DIR/start-server.sh" "$MODE"
