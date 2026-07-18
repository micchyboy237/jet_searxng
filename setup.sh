#!/usr/bin/env bash
# =============================================================================
# setup.sh — Fixed SearXNG local install (Mac M1, no Docker)
# =============================================================================
set -euo pipefail

INSTANCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="/Users/jethroestrada/Desktop/External_Projects/AI/apps/searxng"
SETTINGS_PATH="$INSTANCE_DIR/settings.yml"
VENV_DIR="$REPO_ROOT/.venv"

echo "SearXNG — Instance Setup (.venv in repo root)"
echo "================================================================="
echo "Instance dir : $INSTANCE_DIR"
echo "Repo root    : $REPO_ROOT"
echo "Settings     : $SETTINGS_PATH"
echo "Virtual env  : $VENV_DIR"
echo "Python       : $(which python3)"
echo "================================================================="
echo

[[ -f "$SETTINGS_PATH" ]] || { echo "ERROR: settings.yml missing"; exit 1; }

echo "🔄 Recreating virtual environment..."
rm -rf "$VENV_DIR"
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo "⬆️ Upgrading pip, setuptools, wheel..."
pip install --quiet -U pip setuptools wheel

echo "📦 Installing build & critical dependencies (including typing_extensions)..."
pip install --quiet \
    msgspec \
    lxml \
    pyyaml \
    typing-extensions \
    pybind11

echo "📥 Installing SearXNG (editable)..."
pip install --quiet --use-pep517 --no-build-isolation -e "$REPO_ROOT"

echo "📦 Installing remaining SearXNG dependencies..."
pip install --quiet searxng

echo "🛠️ Installing gunicorn..."
pip install --quiet gunicorn

echo
echo "✅ Setup complete!"
echo "   Run: ./start-server.sh          # dev mode (Flask)"
echo "   Run: ./start-server.sh prod     # production (gunicorn)"
echo "================================================================="