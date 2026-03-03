# IXV-Agents bootstrap script for Windows (psmux)
# Usage:
#   .\scripts\boot.ps1                        # start psmux + agents (opencode)
#   .\scripts\boot.ps1 -ClaudeCode            # use Claude Code instead
#   .\scripts\boot.ps1 -Model <model_name>    # specify model

param(
    [switch]$ClaudeCode,
    [string]$Model,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# バナーを表示
$BannerScript = Join-Path $ScriptDir "banner.ps1"
if (Test-Path $BannerScript) {
    & $BannerScript
}
# バナーがすぐ見えなくならないように待機
Start-Sleep -Seconds 5
Write-Host ""

$RootDir = Split-Path -Parent $ScriptDir
$WorkspaceDir = Join-Path $RootDir "workspace"
Set-Location $RootDir

$CliName = "opencode"
$CliCmd = "opencode"

if ($Help) {
    Write-Host "Usage: .\scripts\boot.ps1 [-ClaudeCode] [-Model <model_name>]"
    Write-Host "  -ClaudeCode   Use Claude Code instead of OpenCode (default)"
    Write-Host "  -Model <name> Specify model (e.g., sonnet, opus, anthropic/claude-sonnet-4-5)"
    exit 0
}

if ($ClaudeCode) {
    $CliName = "claude"
    $CliCmd = "claude --dangerously-skip-permissions"
}

# Validate and append model option if specified
if ($Model) {
    if ($Model -notmatch '^[a-zA-Z0-9/_.:@-]+$') {
        Write-Host "ERROR: Invalid model name: $Model" -ForegroundColor Red
        Write-Host "Model name must contain only alphanumeric characters, '/', '_', '.', ':', '@', '-'"
        exit 1
    }
    $CliCmd = "$CliCmd --model $Model"
}

function Log($msg) {
    Write-Host "[ixv] $msg"
}

# Check if tmux (psmux) is installed
if (-not (Get-Command "tmux" -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "  ERROR: tmux (psmux) not found." -ForegroundColor Red
    Write-Host ""
    Write-Host "  コマンドでインストール: irm https://raw.githubusercontent.com/marlocarlo/psmux/master/scripts/install.ps1 | iex"
    Write-Host "  その他のインストール方法は https://github.com/marlocarlo/psmux を参照"
    Write-Host "  PowerShell 7+ が必要です"
    Write-Host ""
    Write-Host "  詳細は README_ja.md の「セットアップ」を参照してください。"
    Write-Host ""
    exit 1
}

# Check if workspace exists
if (-not (Test-Path $WorkspaceDir)) {
    Log "Workspace not found. Running setup_workspace.ps1 first..."
    $SetupScript = Join-Path $ScriptDir "setup_workspace.ps1"
    & $SetupScript -NoBackup
}

Log "Stopping existing session if present..."
$StopScript = Join-Path $ScriptDir "stop.ps1"
& $StopScript *>&1 | Out-Null

# ===============================================================================
# ixv-agents: 全エージェント（PO, SM, Dev1-3）を1セッション5ペインで構成
# ===============================================================================
# レイアウト:
# +---------+-------+-------+-------+
# |   PO    | Dev1  | Dev2  | Dev3  |
# |  (0.0)  | (0.2) | (0.3) | (0.4) |
# +---------+       |       |       |
# |   SM    |       |       |       |
# |  (0.1)  |       |       |       |
# +---------+-------+-------+-------+
# ===============================================================================

Log "Creating ixv-agents session (5 panes)..."
tmux new-session -d -s ixv-agents -n "agents"

# Step 1: 左右に分割（左50%, 右50%）
# Note: -p is not supported in psmux, so we split sequentially for roughly equal panes
tmux split-window -h -t "ixv-agents:0"

# Step 2: 左側を上下に分割（PO / SM）
tmux split-window -v -t "ixv-agents:0.0"

# Step 3: 右側を横に3等分（Dev1 / Dev2 / Dev3）
tmux split-window -h -t "ixv-agents:0.2"
tmux split-window -h -t "ixv-agents:0.3"

# Set titles, prompts, and working directory
# ペイン番号: 0=PO(左上), 1=SM(左下), 2=Dev1, 3=Dev2, 4=Dev3

# PO
tmux select-pane -t "ixv-agents:0.0" -T "PO"
tmux send-keys -t "ixv-agents:0.0" "chcp 65001 > `$null"
tmux send-keys -t "ixv-agents:0.0" Enter
tmux send-keys -t "ixv-agents:0.0" "cd `"$WorkspaceDir`""
tmux send-keys -t "ixv-agents:0.0" Enter
tmux send-keys -t "ixv-agents:0.0" "function prompt { '(PO) ' + (Get-Location) + '> ' }"
tmux send-keys -t "ixv-agents:0.0" Enter
tmux send-keys -t "ixv-agents:0.0" "cls"
tmux send-keys -t "ixv-agents:0.0" Enter

# SM
tmux select-pane -t "ixv-agents:0.1" -T "SM"
tmux send-keys -t "ixv-agents:0.1" "chcp 65001 > `$null"
tmux send-keys -t "ixv-agents:0.1" Enter
tmux send-keys -t "ixv-agents:0.1" "cd `"$WorkspaceDir`""
tmux send-keys -t "ixv-agents:0.1" Enter
tmux send-keys -t "ixv-agents:0.1" "function prompt { '(SM) ' + (Get-Location) + '> ' }"
tmux send-keys -t "ixv-agents:0.1" Enter
tmux send-keys -t "ixv-agents:0.1" "cls"
tmux send-keys -t "ixv-agents:0.1" Enter

# Dev1-Dev3
$DevPanes = @(2, 3, 4)
for ($i = 0; $i -le 2; $i++) {
    $DevNum = $i + 1
    $PaneNum = $DevPanes[$i]
    tmux select-pane -t "ixv-agents:0.$PaneNum" -T "Dev$DevNum"
    tmux send-keys -t "ixv-agents:0.$PaneNum" "chcp 65001 > `$null"
    tmux send-keys -t "ixv-agents:0.$PaneNum" Enter
    tmux send-keys -t "ixv-agents:0.$PaneNum" "cd `"$WorkspaceDir`""
    tmux send-keys -t "ixv-agents:0.$PaneNum" Enter
    tmux send-keys -t "ixv-agents:0.$PaneNum" "function prompt { '(Dev$DevNum) ' + (Get-Location) + '> ' }"
    tmux send-keys -t "ixv-agents:0.$PaneNum" Enter
    tmux send-keys -t "ixv-agents:0.$PaneNum" "cls"
    tmux send-keys -t "ixv-agents:0.$PaneNum" Enter
}

# 各ペインにヘルプテキストを表示
$HelpFile = Join-Path $ScriptDir "tmux-help.txt"
if (Test-Path $HelpFile) {
    Copy-Item $HelpFile (Join-Path $WorkspaceDir ".tmux-help.txt")
    for ($PaneNum = 0; $PaneNum -le 4; $PaneNum++) {
        tmux send-keys -t "ixv-agents:0.$PaneNum" "type .tmux-help.txt"
        tmux send-keys -t "ixv-agents:0.$PaneNum" Enter
    }
}

# ===============================================================================
# バックグラウンドで CLI 起動と役割指示送信を実行
# 注意: send-keys はテキスト送信と Enter 送信を分けて実行すること
#       1行にまとめると Enter が正しく送信されない場合がある
#
# トークンリフレッシュの競合を防ぐため、最初の1エージェントを先に起動し
# トークン更新を完了させてから残りを起動する（Issue #20 対策）
# ===============================================================================
Start-Job -ScriptBlock {
    param($CliCmd, $WorkspaceDir)

    Start-Sleep -Seconds 5  # attach が安定するまで待つ

    # Step 1: 最初に PO を起動してトークンリフレッシュを完了させる
    tmux send-keys -t "ixv-agents:0.0" "$CliCmd"
    tmux send-keys -t "ixv-agents:0.0" Enter

    Start-Sleep -Seconds 5  # トークンリフレッシュ完了を待つ

    # Step 2: 残りのエージェントを起動（トークンはリフレッシュ済み）
    tmux send-keys -t "ixv-agents:0.1" "$CliCmd"
    tmux send-keys -t "ixv-agents:0.1" Enter

    for ($PaneNum = 2; $PaneNum -le 4; $PaneNum++) {
        tmux send-keys -t "ixv-agents:0.$PaneNum" "$CliCmd"
        tmux send-keys -t "ixv-agents:0.$PaneNum" Enter
    }

    Start-Sleep -Seconds 5  # CLI 起動待ち

    # PO
    tmux send-keys -t "ixv-agents:0.0" "roles/po.md を読んで役割を理解してください。"
    tmux send-keys -t "ixv-agents:0.0" Enter

    # SM
    tmux send-keys -t "ixv-agents:0.1" "roles/sm.md を読んで役割を理解してください。"
    tmux send-keys -t "ixv-agents:0.1" Enter

    # Dev1-Dev3
    for ($i = 0; $i -le 2; $i++) {
        $DevNum = $i + 1
        $PaneNum = $i + 2
        tmux send-keys -t "ixv-agents:0.$PaneNum" "roles/dev.md を読んで役割を理解してください。あなたは Dev$DevNum です。"
        tmux send-keys -t "ixv-agents:0.$PaneNum" Enter
    }
} -ArgumentList $CliCmd, $WorkspaceDir | Out-Null

# ===============================================================================
# 完了メッセージ（スクリプトを実行したターミナルに表示）
# ===============================================================================
Write-Host ""
Log "Session ready:"
tmux list-sessions
Write-Host ""

Write-Host "  +--------------------------------------------------------------+"
Write-Host "  |  IXV-Agents セッション構成                                    |"
Write-Host "  +--------------------------------------------------------------+"
Write-Host ""
Write-Host "    作業ディレクトリ: $WorkspaceDir"
Write-Host ""
Write-Host "    【ixv-agents】全エージェント（5ペイン）"
Write-Host "    +---------+-------+-------+-------+"
Write-Host "    |   PO    | Dev1  | Dev2  | Dev3  |"
Write-Host "    |  (0.0)  | (0.2) | (0.3) | (0.4) |"
Write-Host "    +---------+       |       |       |"
Write-Host "    |   SM    |       |       |       |"
Write-Host "    |  (0.1)  |       |       |       |"
Write-Host "    +---------+-------+-------+-------+"
Write-Host ""

Write-Host "  操作方法:"
Write-Host "  +--------------------------------------------------------------+"
Write-Host "  |  ペイン間移動:                                                |"
Write-Host "  |    Ctrl+b 矢印キー                                           |"
Write-Host "  |                                                              |"
Write-Host "  |  セッションをデタッチ:                                        |"
Write-Host "  |    Ctrl+b d                                                  |"
Write-Host "  |                                                              |"
Write-Host "  |  セッションに再アタッチ:                                      |"
Write-Host "  |    tmux attach-session -t ixv-agents                         |"
Write-Host "  |                                                              |"
Write-Host "  |  IXVセッションを停止:                                          |"
Write-Host "  |    .\scripts\stop.ps1                                        |"
Write-Host "  |                                                              |"
Write-Host "  |  プロセスが残った場合の強制停止:                              |"
Write-Host "  |    .\scripts\stop.ps1 -Force                                 |"
Write-Host "  +--------------------------------------------------------------+"
Write-Host ""

Log "Attaching to ixv-agents session..."
tmux attach-session -t ixv-agents
