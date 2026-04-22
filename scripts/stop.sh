#!/bin/bash
# IXV-Agents stop script
# Usage:
#   ./scripts/stop.sh           # stop all ixv sessions (graceful)
#   ./scripts/stop.sh --force   # force kill opencode processes + sessions
#   ./scripts/stop.sh -h        # show help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$ROOT_DIR"

# 色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
  echo -e "[ixv] $1"
}

log_success() {
  echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

FORCE_KILL=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -f | --force)
      FORCE_KILL=true
      shift
      ;;
    -h | --help)
      echo "Usage: ./scripts/stop.sh [--force]"
      echo "  -f, --force  Force kill opencode/claude processes and sessions"
      echo ""
      echo "By default, sends Ctrl+C to gracefully stop CLI, then kills sessions."
      echo "Use --force if processes remain after normal stop."
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo ""
echo "  ┌──────────────────────────────────────────────────────────────┐"
echo "  │  IXV-Agents Stop                                             │"
echo "  └──────────────────────────────────────────────────────────────┘"
echo ""

# Send Ctrl+C to all panes to gracefully stop CLI
send_ctrl_c() {
  log "Sending Ctrl+C to all panes..."

  if tmux has-session -t ixv-agents 2> /dev/null; then
    # PO (0.0), SM (0.1), Dev1 (0.2), Dev2 (0.3), Dev3 (0.4)
    for i in {0..4}; do
      tmux send-keys -t "ixv-agents:0.$i" C-c 2> /dev/null || true
    done
  fi

  log "Waiting for CLI to exit..."
  sleep 3
}

# Kill sessions
kill_sessions() {
  if tmux has-session -t ixv-agents 2> /dev/null; then
    tmux kill-session -t ixv-agents
    log_success "ixv-agents session stopped"
  else
    log_warn "ixv-agents session not found"
  fi
}

if [ "$FORCE_KILL" = true ]; then
  # opencode/claude プロセスは ixv-agents tmux セッション上で起動されるため、
  # セッションを kill すれば子プロセスも終了する。pgrep/pkill による個別 kill は不要。
  kill_sessions
else
  # Graceful stop: send Ctrl+C first, then kill sessions
  send_ctrl_c
  kill_sessions
fi

echo ""
log "Remaining sessions:"
tmux list-sessions 2> /dev/null || echo "  (no sessions)"
echo ""
