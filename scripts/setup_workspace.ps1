# ============================================================
# setup_workspace.ps1 - IXV-Agents ワークスペース初期化スクリプト (Windows)
# ============================================================
# 使用方法:
#   .\scripts\setup_workspace.ps1              # バックアップ＆初期化
#   .\scripts\setup_workspace.ps1 -NoBackup    # バックアップなしで初期化のみ
#   .\scripts\setup_workspace.ps1 -Help        # ヘルプ表示
# ============================================================

param(
    [switch]$NoBackup,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# スクリプトのディレクトリを取得
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
Set-Location $RootDir

# ディレクトリ定義
$WorkspaceDir = ".\workspace"
$BackupBaseDir = ".\backups"
$TemplatesDir = ".\templates"

# 色付きログ関数
function Log-Info($msg) {
    Write-Host "[INFO] " -ForegroundColor Blue -NoNewline
    Write-Host $msg
}

function Log-Success($msg) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host $msg
}

function Log-Warn($msg) {
    Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline
    Write-Host $msg
}

function Log-Error($msg) {
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host $msg
}

function Log-Step($msg) {
    $ESC = [char]27
    Write-Host ""
    Write-Host "${ESC}[36m${ESC}[1m--- $msg ---${ESC}[0m"
    Write-Host ""
}

# テンプレートをコピーしてプレースホルダーを置換する関数
function Apply-Template {
    param(
        [string]$Src,
        [string]$Dst,
        [string]$Timestamp,
        [string]$Date,
        [string]$Assignee
    )
    $content = Get-Content -Path $Src -Raw -Encoding UTF8
    $content = $content -replace '\{\{TIMESTAMP\}\}', $Timestamp
    $content = $content -replace '\{\{DATE\}\}', $Date
    $content = $content -replace '\{\{ASSIGNEE\}\}', $Assignee
    Set-Content -Path $Dst -Value $content -Encoding UTF8 -NoNewline
}

# ヘルプ表示
if ($Help) {
    Write-Host ""
    Write-Host "IXV-Agents ワークスペース初期化スクリプト (Windows)"
    Write-Host ""
    Write-Host "使用方法: .\scripts\setup_workspace.ps1 [オプション]"
    Write-Host ""
    Write-Host "オプション:"
    Write-Host "  -NoBackup      バックアップをスキップして初期化のみ実行"
    Write-Host "  -Help          このヘルプを表示"
    Write-Host ""
    Write-Host "動作内容:"
    Write-Host "  1. 前回記録をバックアップ（backups\backup_YYYYMMDD_HHMMSS\）"
    Write-Host "  2. workspace\ ディレクトリを初期化"
    Write-Host "  3. ジャンクション（シンボリックリンク相当）を作成（roles, skills）"
    Write-Host "  4. テンプレートからキューファイル・ダッシュボード・README.mdを初期化"
    Write-Host ""
    exit 0
}

# テンプレートディレクトリの存在確認
if (-not (Test-Path $TemplatesDir)) {
    Log-Error "テンプレートディレクトリが見つかりません: $TemplatesDir"
    exit 1
}

Write-Host ""
Write-Host "  +==============================================================+"
Write-Host "  |  IXV-Agents Workspace Setup                                  |"
Write-Host "  |  ワークスペース初期化                                          |"
Write-Host "  +==============================================================+"
Write-Host ""

# ============================================================
# STEP 1: 前回記録のバックアップ
# ============================================================
$BackupDir = ""
if (-not $NoBackup) {
    Log-Step "STEP 1: 前回記録のバックアップ"

    if (Test-Path $WorkspaceDir) {
        if (-not (Test-Path $BackupBaseDir)) {
            New-Item -ItemType Directory -Path $BackupBaseDir -Force | Out-Null
        }
        $BackupDir = Join-Path $BackupBaseDir ("backup_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
        Move-Item $WorkspaceDir $BackupDir
        Log-Success "バックアップ完了: $BackupDir"
    } else {
        Log-Info "workspaceが存在しません（スキップ）"
    }
} else {
    Log-Step "STEP 1: バックアップをスキップ (-NoBackup)"
    if (Test-Path $WorkspaceDir) {
        Remove-Item -Recurse -Force $WorkspaceDir
        Log-Info "既存のworkspaceを削除"
    }
}

# ============================================================
# STEP 2: ディレクトリ構造の確認・作成
# ============================================================
Log-Step "STEP 2: ディレクトリ構造の確認"

New-Item -ItemType Directory -Path (Join-Path $WorkspaceDir "queue\tasks") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $WorkspaceDir "queue\reports") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $WorkspaceDir ".claude") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $WorkspaceDir ".opencode") -Force | Out-Null
New-Item -ItemType Directory -Path $BackupBaseDir -Force | Out-Null

Log-Success "ディレクトリ構造 OK"

# ============================================================
# STEP 3: ジャンクション（シンボリックリンク相当）の作成
# ============================================================
Log-Step "STEP 3: ジャンクション（シンボリックリンク相当）の作成"

# NOTE: Windows ではシンボリックリンクに管理者権限が必要なため、
#       ジャンクション (directory junction) を使用します。
#       ジャンクションは絶対パスが必要です。

$AbsRootDir = (Resolve-Path $RootDir).Path
$AbsWorkspaceDir = Join-Path $AbsRootDir "workspace"

# roles へのジャンクション
$RolesLink = Join-Path $AbsWorkspaceDir "roles"
if (-not (Test-Path $RolesLink)) {
    $RolesTarget = Join-Path $AbsRootDir "roles"
    cmd /c mklink /J "$RolesLink" "$RolesTarget" | Out-Null
    Log-Info "workspace\roles -> roles を作成"
} else {
    Log-Info "workspace\roles は既に存在"
}

# .claude\skills へのジャンクション
$ClaudeSkillsLink = Join-Path $AbsWorkspaceDir ".claude\skills"
if (-not (Test-Path $ClaudeSkillsLink)) {
    $SkillsTarget = Join-Path $AbsRootDir "skills"
    cmd /c mklink /J "$ClaudeSkillsLink" "$SkillsTarget" | Out-Null
    Log-Info "workspace\.claude\skills -> skills を作成"
} else {
    Log-Info "workspace\.claude\skills は既に存在"
}

# .opencode\skills へのジャンクション
$OpencodeSkillsLink = Join-Path $AbsWorkspaceDir ".opencode\skills"
if (-not (Test-Path $OpencodeSkillsLink)) {
    $SkillsTarget = Join-Path $AbsRootDir "skills"
    cmd /c mklink /J "$OpencodeSkillsLink" "$SkillsTarget" | Out-Null
    Log-Info "workspace\.opencode\skills -> skills を作成"
} else {
    Log-Info "workspace\.opencode\skills は既に存在"
}

Log-Success "ジャンクション OK"

# ============================================================
# STEP 4: キューファイルの初期化（テンプレートから）
# ============================================================
Log-Step "STEP 4: キューファイルの初期化"

$Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$CurrentDate = (Get-Date).ToString("yyyy-MM-dd")

# po_to_sm.yaml を初期化
Apply-Template -Src (Join-Path $TemplatesDir "queue\po_to_sm.yaml") `
               -Dst (Join-Path $WorkspaceDir "queue\po_to_sm.yaml") `
               -Timestamp $Timestamp -Date $CurrentDate -Assignee ""
Log-Info "queue\po_to_sm.yaml を初期化"

# Dev用タスクファイルを初期化 (dev1-dev3)
for ($i = 1; $i -le 3; $i++) {
    Apply-Template -Src (Join-Path $TemplatesDir "queue\tasks\dev.yaml") `
                   -Dst (Join-Path $WorkspaceDir "queue\tasks\dev${i}.yaml") `
                   -Timestamp $Timestamp -Date $CurrentDate -Assignee "dev${i}"
}
Log-Info "queue\tasks\dev1-dev3.yaml を初期化"

# レポートファイルを削除（TEMPLATE以外）
$DeletedCount = 0
$ReportsDir = Join-Path $WorkspaceDir "queue\reports"
Get-ChildItem -Path $ReportsDir -Filter "*.yaml" -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -notlike "*TEMPLATE*"
} | ForEach-Object {
    Remove-Item $_.FullName
    $DeletedCount++
}
if ($DeletedCount -gt 0) {
    Log-Info "${DeletedCount} 件のレポートファイルを削除"
} else {
    Log-Info "削除対象のレポートファイルなし"
}

# TEMPLATEファイルをコピー
Copy-Item (Join-Path $TemplatesDir "queue\reports\TEMPLATE.yaml") `
          (Join-Path $WorkspaceDir "queue\reports\TEMPLATE.yaml")
Log-Info "queue\reports\TEMPLATE.yaml を初期化"

Log-Success "キューファイル初期化完了"

# ============================================================
# STEP 5: ダッシュボードの初期化（テンプレートから）
# ============================================================
Log-Step "STEP 5: ダッシュボードの初期化"

Apply-Template -Src (Join-Path $TemplatesDir "queue\dashboard.md") `
               -Dst (Join-Path $WorkspaceDir "queue\dashboard.md") `
               -Timestamp $Timestamp -Date $CurrentDate -Assignee ""

Log-Success "queue\dashboard.md を初期化"

# ============================================================
# STEP 6: ワークスペースルートファイルの初期化
# ============================================================
Log-Step "STEP 6: ワークスペースルートファイルの初期化"

Apply-Template -Src (Join-Path $TemplatesDir "README.md") `
               -Dst (Join-Path $WorkspaceDir "README.md") `
               -Timestamp $Timestamp -Date $CurrentDate -Assignee ""
Log-Info "README.md（仕様書）を初期化"

Copy-Item (Join-Path $TemplatesDir "CONSTITUTION.md") (Join-Path $WorkspaceDir "CONSTITUTION.md")
Log-Info "CONSTITUTION.md を初期化"

Copy-Item (Join-Path $TemplatesDir "PROCESS.md") (Join-Path $WorkspaceDir "PROCESS.md")
Log-Info "PROCESS.md を初期化"

Copy-Item (Join-Path $TemplatesDir "AGENTS.md") (Join-Path $WorkspaceDir "AGENTS.md")
Log-Info "AGENTS.md を初期化"

Copy-Item (Join-Path $TemplatesDir ".gitignore") (Join-Path $WorkspaceDir ".gitignore")
Log-Info ".gitignore を初期化"

Log-Success "ルートファイル初期化完了"

# ============================================================
# 完了メッセージ
# ============================================================
Write-Host ""
Write-Host "  +==============================================================+"
Write-Host "  |  ワークスペース初期化完了                                      |"
Write-Host "  +==============================================================+"
Write-Host ""
Write-Host "  ワークスペース: ${WorkspaceDir}\"
Write-Host ""
Write-Host "  初期化されたファイル:"
Write-Host "    - workspace\README.md（仕様書）"
Write-Host "    - workspace\CONSTITUTION.md"
Write-Host "    - workspace\PROCESS.md"
Write-Host "    - workspace\AGENTS.md"
Write-Host "    - workspace\.gitignore"
Write-Host "    - workspace\queue\dashboard.md"
Write-Host "    - workspace\queue\po_to_sm.yaml"
Write-Host "    - workspace\queue\tasks\dev1-dev3.yaml"
Write-Host "    - workspace\queue\reports\TEMPLATE.yaml"
Write-Host ""
Write-Host "  ジャンクション（シンボリックリンク相当）:"
Write-Host "    - workspace\roles -> roles"
Write-Host "    - workspace\.claude\skills -> skills"
Write-Host "    - workspace\.opencode\skills -> skills"
Write-Host ""
if ((-not $NoBackup) -and $BackupDir -and (Test-Path $BackupDir)) {
    Write-Host "  バックアップ先: $BackupDir"
    Write-Host ""
}
Write-Host "  次のステップ:"
Write-Host "    .\scripts\boot.ps1    # エージェントを起動"
Write-Host ""
