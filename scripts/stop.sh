#!/bin/bash
# IXV-Agents stop script
# Usage:
#   ./scripts/stop.sh           # stop all ixv sessions (graceful)
#   ./scripts/stop.sh --force   # force kill opencode processes + sessions
#   ./scripts/stop.sh -h        # show help

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$ROOT_DIR"

# 色定義
RED='\033[0;31m'
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
    -f|--force)
      FORCE_KILL=true
      shift
      ;;
    -h|--help)
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

  # ixv-manage: PO + SM
  if tmux has-session -t ixv-manage 2>/dev/null; then
    tmux send-keys -t "ixv-manage:0.0" C-c 2>/dev/null || true
    tmux send-keys -t "ixv-manage:0.1" C-c 2>/dev/null || true
  fi

  # ixv-dev: Dev1-3
  if tmux has-session -t ixv-dev 2>/dev/null; then
    for i in {0..2}; do
      tmux send-keys -t "ixv-dev:0.$i" C-c 2>/dev/null || true
    done
  fi

  log "Waiting for CLI to exit..."
  sleep 3
}

# Kill sessions
kill_sessions() {
  # Stop ixv-manage session (PO + SM)
  if tmux has-session -t ixv-manage 2>/dev/null; then
    tmux kill-session -t ixv-manage
    log_success "ixv-manage session stopped"
  else
    log_warn "ixv-manage session not found"
  fi

  # Stop ixv-dev session (Dev1-3)
  if tmux has-session -t ixv-dev 2>/dev/null; then
    tmux kill-session -t ixv-dev
    log_success "ixv-dev session stopped"
  else
    log_warn "ixv-dev session not found"
  fi
}

if [ "$FORCE_KILL" = true ]; then
  log "Force killing opencode/claude processes..."

  # Kill opencode processes
  if pgrep -f "opencode" > /dev/null 2>&1; then
    pkill -f "opencode" 2>/dev/null || true
    log_success "opencode processes killed"
  else
    log_warn "No opencode processes found"
  fi

  # Kill claude processes (if using --claude-code)
  if pgrep -f "claude --dangerously-skip-permissions" > /dev/null 2>&1; then
    pkill -f "claude --dangerously-skip-permissions" 2>/dev/null || true
    log_success "claude processes killed"
  else
    log_warn "No claude processes found"
  fi

  kill_sessions
else
  # Graceful stop: send Ctrl+C first, then kill sessions
  send_ctrl_c
  kill_sessions
fi

echo ""
log "Remaining sessions:"
tmux list-sessions 2>/dev/null || echo "  (no sessions)"
echo ""
