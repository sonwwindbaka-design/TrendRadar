#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs"
LOCK_DIR="$LOG_DIR/trendradar.lock"

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.cargo/bin"
export TRENDRADAR_OPEN_BROWSER="${TRENDRADAR_OPEN_BROWSER:-false}"

mkdir -p "$LOG_DIR"

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') TrendRadar is already running; skipping this launch."
  exit 0
fi
trap 'rmdir "$LOCK_DIR"' EXIT

cd "$PROJECT_ROOT"

set -a
if [ -f "$PROJECT_ROOT/.env" ]; then
  # shellcheck disable=SC1091
  . "$PROJECT_ROOT/.env"
fi
if [ -f "$PROJECT_ROOT/.env.local" ]; then
  # shellcheck disable=SC1091
  . "$PROJECT_ROOT/.env.local"
fi
set +a

if ! command -v uv >/dev/null 2>&1; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') uv is not available on PATH."
  exit 127
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') Starting TrendRadar."
uv run python -m trendradar
echo "$(date '+%Y-%m-%d %H:%M:%S') TrendRadar finished."
