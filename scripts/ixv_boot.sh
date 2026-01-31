#!/bin/bash
# IXV-Agents bootstrap script
# Usage:
#   ./scripts/ixv_boot.sh              # start tmux + agents (opencode)
#   ./scripts/ixv_boot.sh --claude-code # use Claude Code instead
#   ./scripts/ixv_boot.sh -s           # setup only (no CLI)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$ROOT_DIR"

SETUP_ONLY=false
CLI_NAME="opencode"
CLI_CMD="OPENCODE_PERMISSION='{\"permission\":{\"*\":{\"*\":\"allow\"}}}' opencode"

while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--setup-only)
      SETUP_ONLY=true
      shift
      ;;
    --claude-code)
      CLI_NAME="claude"
      CLI_CMD="claude --dangerously-skip-permissions"
      shift
      ;;
    -h|--help)
      echo "Usage: ./scripts/ixv_boot.sh [--setup-only] [--claude-code]"
      echo "  --setup-only    Setup tmux sessions without launching CLI"
      echo "  --claude-code   Use Claude Code instead of OpenCode (default)"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

log() {
  echo "[ixv] $1"
}

log "Stopping existing sessions if present..."
tmux kill-session -t ixv-management 2>/dev/null || true
tmux kill-session -t ixv-dev 2>/dev/null || true
tmux kill-session -t ixv-qa 2>/dev/null || true

log "Creating ixv-management session (PO/SM)..."
tmux new-session -d -s ixv-management -n "management" -x 200 -y 50
tmux split-window -v -t "ixv-management:0"
tmux select-pane -t "ixv-management:0.0" -T "PO"
tmux select-pane -t "ixv-management:0.1" -T "SM"
tmux send-keys -t "ixv-management:0.0" "cd $ROOT_DIR && export PS1='(PO) \\w\\$ ' && clear" Enter
tmux send-keys -t "ixv-management:0.1" "cd $ROOT_DIR && export PS1='(SM) \\w\\$ ' && clear" Enter

log "Creating ixv-dev session (Dev1-Dev8)..."
tmux new-session -d -s ixv-dev -n "dev" -x 200 -y 50
tmux split-window -h -t "ixv-dev:0"
tmux split-window -h -t "ixv-dev:0"
tmux split-window -h -t "ixv-dev:0"

for p in 0 1 2 3; do
  tmux select-pane -t "ixv-dev:0.$p"
  tmux split-window -v -t "ixv-dev:0.$p"
done

DEV_TITLES=("Dev1" "Dev2" "Dev3" "Dev4" "Dev5" "Dev6" "Dev7" "Dev8")
for i in {0..7}; do
  tmux select-pane -t "ixv-dev:0.$i" -T "${DEV_TITLES[$i]}"
  tmux send-keys -t "ixv-dev:0.$i" "cd $ROOT_DIR && export PS1='(${DEV_TITLES[$i]}) \\w\\$ ' && clear" Enter
done

log "Creating ixv-qa session (QA1-QA2)..."
tmux new-session -d -s ixv-qa -n "qa" -x 200 -y 50
tmux split-window -v -t "ixv-qa:0"
tmux select-pane -t "ixv-qa:0.0" -T "QA1"
tmux select-pane -t "ixv-qa:0.1" -T "QA2"
tmux send-keys -t "ixv-qa:0.0" "cd $ROOT_DIR && export PS1='(QA1) \\w\\$ ' && clear" Enter
tmux send-keys -t "ixv-qa:0.1" "cd $ROOT_DIR && export PS1='(QA2) \\w\\$ ' && clear" Enter

if [ "$SETUP_ONLY" = false ]; then
  log "Launching $CLI_NAME in all panes..."
  tmux send-keys -t "ixv-management:0.0" "$CLI_CMD" Enter
  tmux send-keys -t "ixv-management:0.1" "$CLI_CMD" Enter
  for i in {0..7}; do
    tmux send-keys -t "ixv-dev:0.$i" "$CLI_CMD" Enter
  done
  tmux send-keys -t "ixv-qa:0.0" "$CLI_CMD" Enter
  tmux send-keys -t "ixv-qa:0.1" "$CLI_CMD" Enter

  sleep 8

  # CLIツール起動時にターミナルタイトルが上書きされることがある。
  # フロントエンドはペインタイトルをキーとして表示するため、
  # 全ペインが同じタイトルだと1件に集約されてしまう。
  # そのため、CLI起動完了後にタイトルを再設定する。
  # FIXME: ターミナルタイトルに依存しない方式に変更する
  log "Re-setting pane titles (after $CLI_NAME overwrites them)..."
  tmux select-pane -t "ixv-management:0.0" -T "PO"
  tmux select-pane -t "ixv-management:0.1" -T "SM"
  for i in {0..7}; do
    tmux select-pane -t "ixv-dev:0.$i" -T "Dev$((i+1))"
  done
  tmux select-pane -t "ixv-qa:0.0" -T "QA1"
  tmux select-pane -t "ixv-qa:0.1" -T "QA2"

  log "Sending role instructions..."
  tmux send-keys -t "ixv-management:0.0" "instructions/po.md を読んで役割を理解せよ。" Enter
  tmux send-keys -t "ixv-management:0.1" "instructions/sm.md を読んで役割を理解せよ。" Enter
  for i in {0..7}; do
    tmux send-keys -t "ixv-dev:0.$i" "instructions/dev.md を読んで役割を理解せよ。汝は Dev$((i+1)) である。" Enter
  done
  tmux send-keys -t "ixv-qa:0.0" "instructions/qa.md を読んで役割を理解せよ。汝は QA1 である。" Enter
  tmux send-keys -t "ixv-qa:0.1" "instructions/qa.md を読んで役割を理解せよ。汝は QA2 である。" Enter
fi

log "Sessions ready:"
tmux list-sessions
