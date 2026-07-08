#!/usr/bin/env bash
# =============================================================================
# stop-server.sh — Gracefully stop SearXNG server
# =============================================================================
set -euo pipefail

PORT="8888"

echo "Stopping SearXNG server on port $PORT..."

# Find PIDs using the port
PIDS=$(lsof -ti tcp:$PORT || true)

if [[ -z "${PIDS}" ]]; then
  echo "No running server found."
  exit 0
fi

echo "Sending SIGTERM..."
kill -15 $PIDS || true

sleep 2

# Force kill if still alive
REMAINING=$(lsof -ti tcp:$PORT || true)
if [[ -n "${REMAINING}" ]]; then
  echo "Force killing remaining processes..."
  kill -9 $REMAINING || true
fi

echo "Server stopped."
