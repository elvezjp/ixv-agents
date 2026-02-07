#!/bin/bash
# IXV-Agents bootstrap script
# Usage:
#   ./scripts/boot.sh                        # start tmux + agents (opencode)
#   ./scripts/boot.sh --claude-code          # use Claude Code instead
#   ./scripts/boot.sh --model <model_name>   # specify model

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# バナーを表示
"${SCRIPT_DIR}/banner.sh"
# バナーがすぐ見えなくならないように待機
sleep 5
echo ""

ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_DIR="${ROOT_DIR}/workspace"
cd "$ROOT_DIR"

CLI_NAME="opencode"
CLI_CMD="OPENCODE_PERMISSION='{\"permission\":{\"*\":\"allow\"}}' opencode"
MODEL=""

while [[ $# -gt 0 ]]; do
  case $1 in
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
      echo "Usage: ./scripts/boot.sh [--claude-code] [--model <model_name>]"
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

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
  echo ""
  echo "  ERROR: tmux not found."
  echo ""
  echo "  コマンドでインストール: brew install tmux"
  echo "  その他のインストール方法は https://github.com/tmux/tmux/wiki/Installing を参照"
  echo ""
  echo "  詳細は README_ja.md の「セットアップ」を参照してください。"
  echo ""
  exit 1
fi

# Check if workspace exists
if [ ! -d "$WORKSPACE_DIR" ]; then
  log "Workspace not found. Running setup_workspace.sh first..."
  "${SCRIPT_DIR}/setup_workspace.sh" --no-backup
fi

log "Stopping existing session if present..."
tmux kill-session -t ixv-agents 2>/dev/null || true

# ═══════════════════════════════════════════════════════════════════════════════
# ixv-agents: 全エージェント（PO, SM, Dev1-3）を1セッション5ペインで構成
# ═══════════════════════════════════════════════════════════════════════════════
# レイアウト:
# ┌─────────┬───────┬───────┬───────┐
# │   PO    │ Dev1  │ Dev2  │ Dev3  │
# │  (0.0)  │ (0.2) │ (0.3) │ (0.4) │
# ├─────────┤       │       │       │
# │   SM    │       │       │       │
# │  (0.1)  │       │       │       │
# └─────────┴───────┴───────┴───────┘
# ═══════════════════════════════════════════════════════════════════════════════

log "Creating ixv-agents session (5 panes)..."
tmux new-session -d -s ixv-agents -n "agents" -x 200 -y 50

# Step 1: 左右に分割（左50%, 右50%）
tmux split-window -h -t "ixv-agents:0" -p 50

# Step 2: 左側を上下に分割（PO / SM）
tmux split-window -v -t "ixv-agents:0.0" -p 50

# Step 3: 右側を横に3等分（Dev1 / Dev2 / Dev3）
# ペイン2を分割 → 2(33%), 3(67%)
tmux split-window -h -t "ixv-agents:0.2" -p 67
# ペイン3を分割 → 3(50%), 4(50%)
tmux split-window -h -t "ixv-agents:0.3" -p 50

# Set titles and prompts
# ペイン番号: 0=PO(左上), 1=SM(左下), 2=Dev1, 3=Dev2, 4=Dev3
tmux select-pane -t "ixv-agents:0.0" -T "PO"
tmux send-keys -t "ixv-agents:0.0" "cd $WORKSPACE_DIR && export PS1='(PO) \\w\\$ ' && clear" Enter

tmux select-pane -t "ixv-agents:0.1" -T "SM"
tmux send-keys -t "ixv-agents:0.1" "cd $WORKSPACE_DIR && export PS1='(SM) \\w\\$ ' && clear" Enter

DEV_PANES=(2 3 4)
for i in {0..2}; do
  DEV_NUM=$((i + 1))
  PANE_NUM=${DEV_PANES[$i]}
  tmux select-pane -t "ixv-agents:0.$PANE_NUM" -T "Dev$DEV_NUM"
  tmux send-keys -t "ixv-agents:0.$PANE_NUM" "cd $WORKSPACE_DIR && export PS1='(Dev$DEV_NUM) \\w\\$ ' && clear" Enter
done

# 各ペインにヘルプテキストを表示
cp "${SCRIPT_DIR}/tmux-help.txt" "$WORKSPACE_DIR/.tmux-help.txt"
for PANE_NUM in 0 1 2 3 4; do
  tmux send-keys -t "ixv-agents:0.$PANE_NUM" "cat .tmux-help.txt"
  tmux send-keys -t "ixv-agents:0.$PANE_NUM" Enter
done

# ═══════════════════════════════════════════════════════════════════════════
# バックグラウンドで CLI 起動と役割指示送信を実行
# 注意: send-keys はテキスト送信と Enter 送信を分けて実行すること
#       1行にまとめると Enter が正しく送信されない場合がある
# ═══════════════════════════════════════════════════════════════════════════
(
  sleep 5  # attach が安定するまで待つ

  # PO + SM
  tmux send-keys -t "ixv-agents:0.0" "$CLI_CMD"
  tmux send-keys -t "ixv-agents:0.0" Enter
  tmux send-keys -t "ixv-agents:0.1" "$CLI_CMD"
  tmux send-keys -t "ixv-agents:0.1" Enter

  # Dev1-3
  for PANE_NUM in 2 3 4; do
    tmux send-keys -t "ixv-agents:0.$PANE_NUM" "$CLI_CMD"
    tmux send-keys -t "ixv-agents:0.$PANE_NUM" Enter
  done

  sleep 5  # CLI 起動待ち

  # PO
  tmux send-keys -t "ixv-agents:0.0" "roles/po.md を読んで役割を理解してください。"
  tmux send-keys -t "ixv-agents:0.0" Enter

  # SM
  tmux send-keys -t "ixv-agents:0.1" "roles/sm.md を読んで役割を理解してください。"
  tmux send-keys -t "ixv-agents:0.1" Enter

  # Dev1-Dev3
  for i in 0 1 2; do
    DEV_NUM=$((i + 1))
    PANE_NUM=$((i + 2))
    tmux send-keys -t "ixv-agents:0.$PANE_NUM" "roles/dev.md を読んで役割を理解してください。あなたは Dev$DEV_NUM です。"
    tmux send-keys -t "ixv-agents:0.$PANE_NUM" Enter
  done
) &

# ═══════════════════════════════════════════════════════════════════════════════
# 完了メッセージ（スクリプトを実行したターミナルに表示）
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
log "Session ready:"
tmux list-sessions
echo ""

echo "  ┌──────────────────────────────────────────────────────────────┐"
echo "  │  IXV-Agents セッション構成                                    │"
echo "  └──────────────────────────────────────────────────────────────┘"
echo ""
echo "    作業ディレクトリ: $WORKSPACE_DIR"
echo ""
echo "    【ixv-agents】全エージェント（5ペイン）"
echo "    ┌─────────┬───────┬───────┬───────┐"
echo "    │   PO    │ Dev1  │ Dev2  │ Dev3  │"
echo "    │  (0.0)  │ (0.2) │ (0.3) │ (0.4) │"
echo "    ├─────────┤       │       │       │"
echo "    │   SM    │       │       │       │"
echo "    │  (0.1)  │       │       │       │"
echo "    └─────────┴───────┴───────┴───────┘"
echo ""

echo "  操作方法:"
echo "  ┌──────────────────────────────────────────────────────────────┐"
echo "  │  ペイン間移動:                                                │"
echo "  │    Ctrl+b 矢印キー                                           │"
echo "  │                                                              │"
echo "  │  セッションをデタッチ:                                        │"
echo "  │    Ctrl+b d                                                  │"
echo "  │                                                              │"
echo "  │  セッションに再アタッチ:                                      │"
echo "  │    tmux attach-session -t ixv-agents                         │"
echo "  │                                                              │"
echo "  │  IXVセッションを停止:                                          │"
echo "  │    ./scripts/stop.sh                                         │"
echo "  │                                                              │"
echo "  │  プロセスが残った場合の強制停止:                              │"
echo "  │    ./scripts/stop.sh --force                                 │"
echo "  └──────────────────────────────────────────────────────────────┘"
echo ""

log "Attaching to ixv-agents session..."
exec tmux attach-session -t ixv-agents
