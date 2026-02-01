#!/bin/bash
# IXV-Agents stop script
# Usage:
#   ./scripts/stop.sh           # stop all ixv sessions
#   ./scripts/stop.sh --all-tmux  # stop all tmux sessions (kill-server)
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

KILL_ALL=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --all-tmux)
      KILL_ALL=true
      shift
      ;;
    -h|--help)
      echo "Usage: ./scripts/stop.sh [--all-tmux]"
      echo "  --all-tmux  Stop all tmux sessions (kill-server)"
      echo ""
      echo "By default, only ixv-po and ixv-agents sessions are stopped."
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

if [ "$KILL_ALL" = true ]; then
  log "Stopping all tmux sessions..."
  tmux kill-server 2>/dev/null && log_success "All tmux sessions stopped" || log_warn "No tmux server running"
else
  # Stop ixv-po session
  if tmux has-session -t ixv-po 2>/dev/null; then
    tmux kill-session -t ixv-po
    log_success "ixv-po session stopped"
  else
    log_warn "ixv-po session not found"
  fi

  # Stop ixv-agents session
  if tmux has-session -t ixv-agents 2>/dev/null; then
    tmux kill-session -t ixv-agents
    log_success "ixv-agents session stopped"
  else
    log_warn "ixv-agents session not found"
  fi
fi

echo ""
log "Remaining sessions:"
tmux list-sessions 2>/dev/null || echo "  (no sessions)"
echo ""
