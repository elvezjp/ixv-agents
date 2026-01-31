#!/bin/bash
# IXV-Agents bootstrap script
# Usage:
#   ./scripts/ixv_boot.sh                        # start tmux + agents (opencode)
#   ./scripts/ixv_boot.sh --claude-code          # use Claude Code instead
#   ./scripts/ixv_boot.sh --model <model_name>   # specify model
#   ./scripts/ixv_boot.sh -s                     # setup only (no CLI)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
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
      echo "Usage: ./scripts/ixv_boot.sh [--setup-only] [--claude-code] [--model <model_name>]"
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

  # PO/SM
  tmux send-keys -t "ixv-management:0.0" "$CLI_CMD"
  tmux send-keys -t "ixv-management:0.0" Enter
  tmux send-keys -t "ixv-management:0.1" "$CLI_CMD"
  tmux send-keys -t "ixv-management:0.1" Enter

  # Dev1-Dev8
  for i in {0..7}; do
    tmux send-keys -t "ixv-dev:0.$i" "$CLI_CMD"
    tmux send-keys -t "ixv-dev:0.$i" Enter
  done

  # QA1-QA2
  tmux send-keys -t "ixv-qa:0.0" "$CLI_CMD"
  tmux send-keys -t "ixv-qa:0.0" Enter
  tmux send-keys -t "ixv-qa:0.1" "$CLI_CMD"
  tmux send-keys -t "ixv-qa:0.1" Enter

  log "Waiting for $CLI_NAME to start..."
  sleep 8

  log "Sending role instructions..."

  # PO/SM
  tmux send-keys -t "ixv-management:0.0" "instructions/po.md を読んで役割を理解してください。"
  tmux send-keys -t "ixv-management:0.0" Enter
  tmux send-keys -t "ixv-management:0.1" "instructions/sm.md を読んで役割を理解してください。"
  tmux send-keys -t "ixv-management:0.1" Enter

  # Dev1-Dev8
  for i in {0..7}; do
    tmux send-keys -t "ixv-dev:0.$i" "instructions/dev.md を読んで役割を理解してください。あなたは Dev$((i+1)) です。"
    tmux send-keys -t "ixv-dev:0.$i" Enter
  done

  # QA1-QA2
  tmux send-keys -t "ixv-qa:0.0" "instructions/qa.md を読んで役割を理解してください。あなたは QA1 です。"
  tmux send-keys -t "ixv-qa:0.0" Enter
  tmux send-keys -t "ixv-qa:0.1" "instructions/qa.md を読んで役割を理解してください。あなたは QA2 です。"
  tmux send-keys -t "ixv-qa:0.1" Enter
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
echo "    【ixv-management】PO/SM"
echo "    ┌─────────────────┐"
echo "    │  Pane 0: PO     │  ← Product Owner"
echo "    ├─────────────────┤"
echo "    │  Pane 1: SM     │  ← Scrum Master"
echo "    └─────────────────┘"
echo ""
echo "    【ixv-dev】Dev1-Dev8 (4x2)"
echo "    ┌──────┬──────┬──────┬──────┐"
echo "    │ Dev1 │ Dev3 │ Dev5 │ Dev7 │"
echo "    ├──────┼──────┼──────┼──────┤"
echo "    │ Dev2 │ Dev4 │ Dev6 │ Dev8 │"
echo "    └──────┴──────┴──────┴──────┘"
echo ""
echo "    【ixv-qa】QA1-QA2"
echo "    ┌─────────────────┐"
echo "    │  Pane 0: QA1    │"
echo "    ├─────────────────┤"
echo "    │  Pane 1: QA2    │"
echo "    └─────────────────┘"
echo ""

if [ "$SETUP_ONLY" = true ]; then
  echo "  ⚠️  セットアップのみモード: CLIは未起動です"
  echo ""
  echo "  手動でCLIを起動するには:"
  echo "  ┌──────────────────────────────────────────────────────────────┐"
  echo "  │  # 全ペインに一括でCLIを起動                                 │"
  echo "  │  tmux send-keys -t ixv-management:0.0 '$CLI_CMD' Enter       │"
  echo "  │  tmux send-keys -t ixv-management:0.1 '$CLI_CMD' Enter       │"
  echo "  │  for i in {0..7}; do                                        │"
  echo "  │    tmux send-keys -t ixv-dev:0.\$i '$CLI_CMD' Enter          │"
  echo "  │  done                                                       │"
  echo "  │  tmux send-keys -t ixv-qa:0.0 '$CLI_CMD' Enter              │"
  echo "  │  tmux send-keys -t ixv-qa:0.1 '$CLI_CMD' Enter              │"
  echo "  └──────────────────────────────────────────────────────────────┘"
  echo ""
fi

echo "  次のステップ:"
echo "  ┌──────────────────────────────────────────────────────────────┐"
echo "  │  POにアタッチして開発を開始:                                  │"
echo "  │    tmux attach-session -t ixv-management                     │"
echo "  │                                                              │"
echo "  │  Devチームを確認する:                                        │"
echo "  │    tmux attach-session -t ixv-dev                            │"
echo "  │                                                              │"
echo "  │  QAチームを確認する:                                         │"
echo "  │    tmux attach-session -t ixv-qa                             │"
echo "  │                                                              │"
echo "  │  セッション一覧を確認:                                        │"
echo "  │    tmux ls                                                   │"
echo "  │                                                              │"
echo "  │  セッションをデタッチ:                                        │"
echo "  │    Ctrl+b d                                                  │"
echo "  │                                                              │"
echo "  │  全セッションを停止:                                          │"
echo "  │    tmux kill-session -t ixv-management                       │"
echo "  │    tmux kill-session -t ixv-dev                              │"
echo "  │    tmux kill-session -t ixv-qa                               │"
echo "  │                                                              │"
echo "  │  tmuxサーバーごと停止（全セッション終了）:                      │"
echo "  │    tmux kill-server                                          │"
echo "  └──────────────────────────────────────────────────────────────┘"
echo ""
