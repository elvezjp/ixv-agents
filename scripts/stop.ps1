# IXV-Agents stop script for Windows (psmux)
# Usage:
#   .\scripts\stop.ps1           # stop all ixv sessions (graceful)
#   .\scripts\stop.ps1 --force   # force kill opencode/claude processes + sessions

param(
    [Alias("f")]
    [switch]$Force,
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\scripts\stop.ps1 [-Force]"
    Write-Host "  -Force  Force kill opencode/claude processes and sessions"
    Write-Host ""
    Write-Host "By default, sends Ctrl+C to gracefully stop CLI, then kills sessions."
    Write-Host "Use -Force if processes remain after normal stop."
    exit 0
}

function Log($msg) {
    Write-Host "[ixv] $msg"
}

function Log-Success($msg) {
    Write-Host "[OK] $msg" -ForegroundColor Green
}

function Log-Warn($msg) {
    Write-Host "[WARN] $msg" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  +--------------------------------------------------------------+"
Write-Host "  |  IXV-Agents Stop                                             |"
Write-Host "  +--------------------------------------------------------------+"
Write-Host ""

function Send-CtrlC {
    Log "Sending Ctrl+C to all panes..."

    $hasSession = $false
    try {
        tmux has-session -t ixv-agents 2>$null
        $hasSession = ($LASTEXITCODE -eq 0)
    } catch {
        $hasSession = $false
    }

    if ($hasSession) {
        for ($i = 0; $i -le 4; $i++) {
            tmux send-keys -t "ixv-agents:0.$i" C-c 2>$null
        }
    }

    Log "Waiting for CLI to exit..."
    Start-Sleep -Seconds 3
}

function Kill-Sessions {
    $hasSession = $false
    try {
        tmux has-session -t ixv-agents 2>$null
        $hasSession = ($LASTEXITCODE -eq 0)
    } catch {
        $hasSession = $false
    }

    if ($hasSession) {
        tmux kill-session -t ixv-agents
        Log-Success "ixv-agents session stopped"
    } else {
        Log-Warn "ixv-agents session not found"
    }
}

if ($Force) {
    Log "Force killing opencode/claude processes..."

    # Kill opencode processes
    $opencodeProcs = Get-Process -Name "opencode" -ErrorAction SilentlyContinue
    if ($opencodeProcs) {
        $opencodeProcs | Stop-Process -Force
        Log-Success "opencode processes killed"
    } else {
        Log-Warn "No opencode processes found"
    }

    # Kill claude processes
    $claudeProcs = Get-Process -Name "claude" -ErrorAction SilentlyContinue
    if ($claudeProcs) {
        $claudeProcs | Stop-Process -Force
        Log-Success "claude processes killed"
    } else {
        Log-Warn "No claude processes found"
    }

    Kill-Sessions
} else {
    Send-CtrlC
    Kill-Sessions
}

Write-Host ""
Log "Remaining sessions:"
tmux list-sessions 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  (no sessions)"
}
Write-Host ""
