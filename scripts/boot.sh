#!/bin/bash
# IXV-Agents bootstrap script
# Usage:
#   ./scripts/boot.sh                        # start tmux + agents (opencode)
#   ./scripts/boot.sh --claude-code          # use Claude Code instead
#   ./scripts/boot.sh --model <model_name>   # specify model
#   ./scripts/boot.sh -s                     # setup only (no CLI)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
  log "Workspace not found. Running setup_workdir.sh first..."
  "${SCRIPT_DIR}/setup_workdir.sh" --no-backup
fi

log "Stopping existing sessions if present..."
tmux kill-session -t ixv-po 2>/dev/null || true
tmux kill-session -t ixv-agents 2>/dev/null || true

log "Creating ixv-po session (PO only)..."
tmux new-session -d -s ixv-po -n "po" -x 200 -y 50
tmux select-pane -t "ixv-po:0.0" -T "PO"
tmux send-keys -t "ixv-po:0.0" "cd $WORKSPACE_DIR && export PS1='(PO) \\w\\$ ' && clear" Enter

log "Creating ixv-agents session (SM + Dev1-Dev3, 2x2)..."
tmux new-session -d -s ixv-agents -n "agents" -x 200 -y 50

# Create 2x2 grid (SM + Dev1-Dev3 = 4 panes)
# Split horizontally into 2 columns
tmux split-window -h -t "ixv-agents:0"

# Split each column vertically into 2 rows
# After horizontal split, panes are: 0, 1 (left, right)
tmux split-window -v -t "ixv-agents:0.0"
tmux split-window -v -t "ixv-agents:0.2"

# Set titles and prompts
# Pane layout after splits (2x2):
#   0: SM    2: Dev2
#   1: Dev1  3: Dev3
AGENT_TITLES=("SM" "Dev1" "Dev2" "Dev3")
for i in {0..3}; do
  tmux select-pane -t "ixv-agents:0.$i" -T "${AGENT_TITLES[$i]}"
  tmux send-keys -t "ixv-agents:0.$i" "cd $WORKSPACE_DIR && export PS1='(${AGENT_TITLES[$i]}) \\w\\$ ' && clear" Enter
done

if [ "$SETUP_ONLY" = false ]; then
  log "Launching $CLI_NAME in all panes..."

  # PO
  tmux send-keys -t "ixv-po:0.0" "$CLI_CMD"
  tmux send-keys -t "ixv-po:0.0" Enter

  # SM + Dev1-Dev3
  for i in {0..3}; do
    tmux send-keys -t "ixv-agents:0.$i" "$CLI_CMD"
    tmux send-keys -t "ixv-agents:0.$i" Enter
  done

  log "Waiting for $CLI_NAME to start..."
  sleep 8

  log "Sending role instructions..."

  # PO
  tmux send-keys -t "ixv-po:0.0" "instructions/po.md を読んで役割を理解してください。"
  tmux send-keys -t "ixv-po:0.0" Enter

  # SM (pane 0)
  tmux send-keys -t "ixv-agents:0.0" "instructions/sm.md を読んで役割を理解してください。"
  tmux send-keys -t "ixv-agents:0.0" Enter

  # Dev1-Dev3 (panes 1-3)
  for i in {1..3}; do
    tmux send-keys -t "ixv-agents:0.$i" "instructions/dev.md を読んで役割を理解してください。あなたは Dev$i です。"
    tmux send-keys -t "ixv-agents:0.$i" Enter
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
echo "    【ixv-po】Product Owner"
echo "    ┌─────────────────┐"
echo "    │  Pane 0: PO     │"
echo "    └─────────────────┘"
echo ""
echo "    【ixv-agents】SM + Dev1-Dev3 (2x2)"
echo "    ┌──────┬──────┐"
echo "    │  SM  │ Dev2 │"
echo "    ├──────┼──────┤"
echo "    │ Dev1 │ Dev3 │"
echo "    └──────┴──────┘"
echo ""

if [ "$SETUP_ONLY" = true ]; then
  echo "  ⚠️  セットアップのみモード: CLIは未起動です"
  echo ""
  echo "  手動でCLIを起動するには:"
  echo "  ┌──────────────────────────────────────────────────────────────┐"
  echo "  │  # 全ペインに一括でCLIを起動                                 │"
  echo "  │  tmux send-keys -t ixv-po:0.0 '$CLI_CMD' Enter               │"
  echo "  │  for i in {0..3}; do                                        │"
  echo "  │    tmux send-keys -t ixv-agents:0.\$i '$CLI_CMD' Enter       │"
  echo "  │  done                                                       │"
  echo "  └──────────────────────────────────────────────────────────────┘"
  echo ""
fi

echo "  次のステップ:"
echo "  ┌──────────────────────────────────────────────────────────────┐"
echo "  │  POにアタッチして開発を開始:                                  │"
echo "  │    tmux attach-session -t ixv-po                             │"
echo "  │                                                              │"
echo "  │  エージェントチームを確認する:                                │"
echo "  │    tmux attach-session -t ixv-agents                         │"
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
