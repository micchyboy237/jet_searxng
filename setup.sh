#!/usr/bin/env bash
set -euo pipefail

INSTANCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$INSTANCE_DIR")"
SETTINGS_PATH="$INSTANCE_DIR/settings.yml"
VENV_DIR="$REPO_ROOT/.venv"

echo "SearXNG — Instance Setup (.venv in repo root)"
echo "================================================================="
echo "Instance dir : $INSTANCE_DIR"
echo "Repo root    : $REPO_ROOT"
echo "Settings     : $SETTINGS_PATH"
echo "Virtual env  : $VENV_DIR"
echo "================================================================="
echo

[[ -f "$SETTINGS_PATH" ]] || { echo "ERROR: settings.yml missing"; exit 1; }

echo "Recreating virtual environment..."
rm -rf "$VENV_DIR"
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo "Upgrading pip..."
pip install --quiet -U pip

echo "Installing build essentials..."
pip install --quiet setuptools wheel

echo "Pre-installing critical deps..."
pip install --quiet msgspec lxml pyyaml

echo "Installing SearXNG (editable)..."
pip install --quiet --no-deps --no-build-isolation -e "$REPO_ROOT"

echo "Installing full dependencies..."
pip install --quiet searxng

echo "Installing gunicorn..."
pip install --quiet gunicorn

echo
echo "Setup complete!"
echo "Now run: ./start-server.sh"
echo "     or: ./start-server.sh prod"
echo