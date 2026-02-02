#!/bin/bash
# IXV-Agents bootstrap script
# Usage:
#   ./scripts/boot.sh                        # start tmux + agents (opencode)
#   ./scripts/boot.sh --claude-code          # use Claude Code instead
#   ./scripts/boot.sh --model <model_name>   # specify model
#   ./scripts/boot.sh -s                     # setup only (no CLI)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Display banner
"${SCRIPT_DIR}/banner.sh"
echo ""
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_DIR="${ROOT_DIR}/workspace"
cd "$ROOT_DIR"

SETUP_ONLY=false
CLI_NAME="opencode"
CLI_CMD="OPENCODE_PERMISSION='{\"permission\":{\"*\":\"allow\"}}' opencode"
MODEL=""

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
    --model)
      MODEL="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: ./scripts/boot.sh [--setup-only] [--claude-code] [--model <model_name>]"
      echo "  --setup-only    Setup tmux sessions without launching CLI"
      echo "  --claude-code   Use Claude Code instead of OpenCode (default)"
      echo "  --model <name>  Specify model (e.g., sonnet, opus, anthropic/claude-sonnet-4-5)"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Append model option if specified
if [ -n "$MODEL" ]; then
  CLI_CMD="$CLI_CMD --model $MODEL"
fi

log() {
  echo "[ixv] $1"
}

# Check if workspace exists
if [ ! -d "$WORKSPACE_DIR" ]; then
  log "Workspace not found. Running setup_workspace.sh first..."
  "${SCRIPT_DIR}/setup_workspace.sh" --no-backup
fi

log "Stopping existing sessions if present..."
tmux kill-session -t ixv-manage 2>/dev/null || true
tmux kill-session -t ixv-dev 2>/dev/null || true

# ═══════════════════════════════════════════════════════════════════════════════
# ixv-manage: 管理層（PO + SM、縦2分割）
# ═══════════════════════════════════════════════════════════════════════════════
log "Creating ixv-manage session (PO + SM, vertical split)..."
tmux new-session -d -s ixv-manage -n "manage" -x 200 -y 50

# Split vertically: PO (top) + SM (bottom)
tmux split-window -v -t "ixv-manage:0"

# Set titles and prompts
# Pane layout: 0=PO (top), 1=SM (bottom)
tmux select-pane -t "ixv-manage:0.0" -T "PO"
tmux send-keys -t "ixv-manage:0.0" "cd $WORKSPACE_DIR && export PS1='(PO) \\w\\$ ' && clear" Enter

tmux select-pane -t "ixv-manage:0.1" -T "SM"
tmux send-keys -t "ixv-manage:0.1" "cd $WORKSPACE_DIR && export PS1='(SM) \\w\\$ ' && clear" Enter

# ═══════════════════════════════════════════════════════════════════════════════
# ixv-dev: 開発層（Dev1-3、横3分割）
# ═══════════════════════════════════════════════════════════════════════════════
log "Creating ixv-dev session (Dev1-3, horizontal 3-split)..."
tmux new-session -d -s ixv-dev -n "dev" -x 200 -y 50

# Split horizontally into 3 panes
tmux split-window -h -t "ixv-dev:0"
tmux split-window -h -t "ixv-dev:0.1"

# Set titles and prompts
# Pane layout: 0=Dev1, 1=Dev2, 2=Dev3
DEV_TITLES=("Dev1" "Dev2" "Dev3")
for i in {0..2}; do
  tmux select-pane -t "ixv-dev:0.$i" -T "${DEV_TITLES[$i]}"
  tmux send-keys -t "ixv-dev:0.$i" "cd $WORKSPACE_DIR && export PS1='(${DEV_TITLES[$i]}) \\w\\$ ' && clear" Enter
done

if [ "$SETUP_ONLY" = false ]; then
  log "Launching $CLI_NAME in all panes..."

  # ixv-manage: PO + SM
  tmux send-keys -t "ixv-manage:0.0" "$CLI_CMD"
  tmux send-keys -t "ixv-manage:0.0" Enter
  tmux send-keys -t "ixv-manage:0.1" "$CLI_CMD"
  tmux send-keys -t "ixv-manage:0.1" Enter

  # ixv-dev: Dev1-3
  for i in {0..2}; do
    tmux send-keys -t "ixv-dev:0.$i" "$CLI_CMD"
    tmux send-keys -t "ixv-dev:0.$i" Enter
  done

  log "Waiting for $CLI_NAME to start..."
  sleep 8

  log "Sending role instructions..."

  # PO (ixv-manage:0.0)
  tmux send-keys -t "ixv-manage:0.0" "roles/po.md を読んで役割を理解してください。"
  tmux send-keys -t "ixv-manage:0.0" Enter

  # SM (ixv-manage:0.1)
  tmux send-keys -t "ixv-manage:0.1" "roles/sm.md を読んで役割を理解してください。"
  tmux send-keys -t "ixv-manage:0.1" Enter

  # Dev1-Dev3 (ixv-dev:0.0-0.2)
  for i in {0..2}; do
    DEV_NUM=$((i + 1))
    tmux send-keys -t "ixv-dev:0.$i" "roles/dev.md を読んで役割を理解してください。あなたは Dev$DEV_NUM です。"
    tmux send-keys -t "ixv-dev:0.$i" Enter
  done
fi

# ═══════════════════════════════════════════════════════════════════════════════
# 完了メッセージ
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
log "Sessions ready:"
tmux list-sessions
echo ""

echo "  ┌──────────────────────────────────────────────────────────────┐"
echo "  │  IXV-Agents セッション構成                                    │"
echo "  └──────────────────────────────────────────────────────────────┘"
echo ""
echo "    作業ディレクトリ: $WORKSPACE_DIR"
echo ""
echo "    【ixv-manage】管理層（PO + SM）"
echo "    ┌─────────────────┐"
echo "    │  0.0: PO        │"
echo "    ├─────────────────┤"
echo "    │  0.1: SM        │"
echo "    └─────────────────┘"
echo ""
echo "    【ixv-dev】開発層（Dev1-3）"
echo "    ┌───────┬───────┬───────┐"
echo "    │  0.0  │  0.1  │  0.2  │"
echo "    │ Dev1  │ Dev2  │ Dev3  │"
echo "    └───────┴───────┴───────┘"
echo ""

if [ "$SETUP_ONLY" = true ]; then
  echo "  ⚠️  セットアップのみモード: CLIは未起動です"
  echo ""
  echo "  手動でCLIを起動するには:"
  echo "  ┌──────────────────────────────────────────────────────────────┐"
  echo "  │  # ixv-manage (PO + SM)                                     │"
  echo "  │  tmux send-keys -t ixv-manage:0.0 '$CLI_CMD' Enter          │"
  echo "  │  tmux send-keys -t ixv-manage:0.1 '$CLI_CMD' Enter          │"
  echo "  │                                                              │"
  echo "  │  # ixv-dev (Dev1-3)                                         │"
  echo "  │  for i in {0..2}; do                                        │"
  echo "  │    tmux send-keys -t ixv-dev:0.\$i '$CLI_CMD' Enter          │"
  echo "  │  done                                                       │"
  echo "  └──────────────────────────────────────────────────────────────┘"
  echo ""
fi

echo "  次のステップ:"
echo "  ┌──────────────────────────────────────────────────────────────┐"
echo "  │  管理層にアタッチして開発を開始:                              │"
echo "  │    tmux attach-session -t ixv-manage                         │"
echo "  │                                                              │"
echo "  │  開発チームを確認する:                                        │"
echo "  │    tmux attach-session -t ixv-dev                            │"
echo "  │                                                              │"
echo "  │  セッション一覧を確認:                                        │"
echo "  │    tmux ls                                                   │"
echo "  │                                                              │"
echo "  │  セッションをデタッチ:                                        │"
echo "  │    Ctrl+b d                                                  │"
echo "  │                                                              │"
echo "  │  IXVセッションを停止:                                          │"
echo "  │    ./scripts/stop.sh                                         │"
echo "  │                                                              │"
echo "  │  全tmuxセッションを停止:                                      │"
echo "  │    ./scripts/stop.sh --all-tmux                              │"
echo "  └──────────────────────────────────────────────────────────────┘"
echo ""
