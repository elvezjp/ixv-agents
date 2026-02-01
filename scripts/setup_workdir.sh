#!/bin/bash
# ============================================================
# setup_workdir.sh - IXV-Agents ワークスペース初期化スクリプト
# ============================================================
# 使用方法:
#   ./scripts/setup_workdir.sh           # バックアップ＆初期化
#   ./scripts/setup_workdir.sh --no-backup  # バックアップなしで初期化のみ
#   ./scripts/setup_workdir.sh -h        # ヘルプ表示
# ============================================================

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$ROOT_DIR"

# ディレクトリ定義
WORKSPACE_DIR="./workspace"
BACKUP_BASE_DIR="./backups"
TEMPLATES_DIR="./templates"

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "\n${CYAN}${BOLD}━━━ $1 ━━━${NC}\n"
}

# テンプレートをコピーしてプレースホルダーを置換する関数
apply_template() {
    local src="$1"
    local dst="$2"
    local timestamp="$3"
    local date="$4"
    local assignee="$5"

    sed -e "s|{{TIMESTAMP}}|${timestamp}|g" \
        -e "s|{{DATE}}|${date}|g" \
        -e "s|{{ASSIGNEE}}|${assignee}|g" \
        "$src" > "$dst"
}

# オプション解析
NO_BACKUP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-backup)
            NO_BACKUP=true
            shift
            ;;
        -h|--help)
            echo ""
            echo "IXV-Agents ワークスペース初期化スクリプト"
            echo ""
            echo "使用方法: ./scripts/setup_workdir.sh [オプション]"
            echo ""
            echo "オプション:"
            echo "  --no-backup    バックアップをスキップして初期化のみ実行"
            echo "  -h, --help     このヘルプを表示"
            echo ""
            echo "動作内容:"
            echo "  1. 前回記録をバックアップ（backups/backup_YYYYMMDD_HHMMSS/）"
            echo "  2. workspace/ ディレクトリを初期化"
            echo "  3. シンボリックリンクを作成（instructions, skills）"
            echo "  4. テンプレートからキューファイル・specs・ダッシュボードを初期化"
            echo ""
            exit 0
            ;;
        *)
            echo "不明なオプション: $1"
            echo "./scripts/setup_workdir.sh -h でヘルプを表示"
            exit 1
            ;;
    esac
done

# テンプレートディレクトリの存在確認
if [ ! -d "$TEMPLATES_DIR" ]; then
    log_error "テンプレートディレクトリが見つかりません: $TEMPLATES_DIR"
    exit 1
fi

echo ""
echo "  ╔══════════════════════════════════════════════════════════════╗"
echo "  ║  IXV-Agents Workspace Setup                                  ║"
echo "  ║  ワークスペース初期化                                          ║"
echo "  ╚══════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================
# STEP 1: 前回記録のバックアップ
# ============================================================
BACKUP_DIR=""
if [ "$NO_BACKUP" = false ]; then
    log_step "STEP 1: 前回記録のバックアップ"

    # workspaceディレクトリが存在する場合は全体をバックアップ
    if [ -d "${WORKSPACE_DIR}" ]; then
        mkdir -p "${BACKUP_BASE_DIR}"
        BACKUP_DIR="${BACKUP_BASE_DIR}/backup_$(date '+%Y%m%d_%H%M%S')"
        mv "${WORKSPACE_DIR}" "$BACKUP_DIR"
        log_success "バックアップ完了: $BACKUP_DIR"
    else
        log_info "workspaceが存在しません（スキップ）"
    fi
else
    log_step "STEP 1: バックアップをスキップ (--no-backup)"
    # --no-backup の場合は既存のworkspaceを削除
    if [ -d "${WORKSPACE_DIR}" ]; then
        rm -rf "${WORKSPACE_DIR}"
        log_info "既存のworkspaceを削除"
    fi
fi

# ============================================================
# STEP 2: ディレクトリ構造の確認・作成
# ============================================================
log_step "STEP 2: ディレクトリ構造の確認"

mkdir -p "${WORKSPACE_DIR}/queue/tasks"
mkdir -p "${WORKSPACE_DIR}/queue/reports"
mkdir -p "${WORKSPACE_DIR}/specs"
mkdir -p "${WORKSPACE_DIR}/.claude"
mkdir -p "${WORKSPACE_DIR}/.opencode"
mkdir -p "${BACKUP_BASE_DIR}"

log_success "ディレクトリ構造 OK"

# ============================================================
# STEP 3: シンボリックリンクの作成
# ============================================================
log_step "STEP 3: シンボリックリンクの作成"

# instructions へのシンボリックリンク
if [ ! -L "${WORKSPACE_DIR}/instructions" ]; then
    ln -sfn ../instructions "${WORKSPACE_DIR}/instructions"
    log_info "workspace/instructions -> ../instructions を作成"
else
    log_info "workspace/instructions は既に存在"
fi

# .claude/skills へのシンボリックリンク
if [ ! -L "${WORKSPACE_DIR}/.claude/skills" ]; then
    ln -sfn ../../skills "${WORKSPACE_DIR}/.claude/skills"
    log_info "workspace/.claude/skills -> ../../skills を作成"
else
    log_info "workspace/.claude/skills は既に存在"
fi

# .opencode/skills へのシンボリックリンク
if [ ! -L "${WORKSPACE_DIR}/.opencode/skills" ]; then
    ln -sfn ../../skills "${WORKSPACE_DIR}/.opencode/skills"
    log_info "workspace/.opencode/skills -> ../../skills を作成"
else
    log_info "workspace/.opencode/skills は既に存在"
fi

log_success "シンボリックリンク OK"

# ============================================================
# STEP 4: キューファイルの初期化（テンプレートから）
# ============================================================
log_step "STEP 4: キューファイルの初期化"

TIMESTAMP=$(date -u "+%Y-%m-%dT%H:%M:%SZ")
CURRENT_DATE=$(date "+%Y-%m-%d")

# po_to_sm.yaml を初期化
apply_template "${TEMPLATES_DIR}/queue/po_to_sm.yaml" \
               "${WORKSPACE_DIR}/queue/po_to_sm.yaml" \
               "$TIMESTAMP" "$CURRENT_DATE" ""
log_info "queue/po_to_sm.yaml を初期化"

# Dev用タスクファイルを初期化 (dev1-dev3)
for i in {1..3}; do
    apply_template "${TEMPLATES_DIR}/queue/tasks/dev.yaml" \
                   "${WORKSPACE_DIR}/queue/tasks/dev${i}.yaml" \
                   "$TIMESTAMP" "$CURRENT_DATE" "dev${i}"
done
log_info "queue/tasks/dev1-dev3.yaml を初期化"

# レポートファイルを削除（TEMPLATE以外）
DELETED_COUNT=0
for f in "${WORKSPACE_DIR}"/queue/reports/*.yaml; do
    if [ -f "$f" ] && [[ "$f" != *"TEMPLATE"* ]]; then
        rm "$f"
        DELETED_COUNT=$((DELETED_COUNT + 1))
    fi
done
if [ $DELETED_COUNT -gt 0 ]; then
    log_info "${DELETED_COUNT} 件のレポートファイルを削除"
else
    log_info "削除対象のレポートファイルなし"
fi

# TEMPLATEファイルをコピー
cp "${TEMPLATES_DIR}/queue/reports/TEMPLATE.yaml" "${WORKSPACE_DIR}/queue/reports/TEMPLATE.yaml"
log_info "queue/reports/TEMPLATE.yaml を初期化"

log_success "キューファイル初期化完了"

# ============================================================
# STEP 5: specsの初期化（テンプレートから）
# ============================================================
log_step "STEP 5: specsの初期化"

cp "${TEMPLATES_DIR}/specs/current_spec.md" "${WORKSPACE_DIR}/specs/current_spec.md"
log_info "specs/current_spec.md を初期化"

cp "${TEMPLATES_DIR}/specs/backlog.md" "${WORKSPACE_DIR}/specs/backlog.md"
log_info "specs/backlog.md を初期化"

log_success "specs初期化完了"

# ============================================================
# STEP 6: ダッシュボードの初期化（テンプレートから）
# ============================================================
log_step "STEP 6: ダッシュボードの初期化"

apply_template "${TEMPLATES_DIR}/queue/dashboard.md" \
               "${WORKSPACE_DIR}/queue/dashboard.md" \
               "$TIMESTAMP" "$CURRENT_DATE" ""

log_success "queue/dashboard.md を初期化"

# ============================================================
# STEP 7: ワークスペースルートファイルの初期化
# ============================================================
log_step "STEP 7: ワークスペースルートファイルの初期化"

cp "${TEMPLATES_DIR}/README.md" "${WORKSPACE_DIR}/README.md"
log_info "README.md を初期化"

cp "${TEMPLATES_DIR}/.gitignore" "${WORKSPACE_DIR}/.gitignore"
log_info ".gitignore を初期化"

log_success "ルートファイル初期化完了"

# ============================================================
# 完了メッセージ
# ============================================================
echo ""
echo "  ╔══════════════════════════════════════════════════════════════╗"
echo "  ║  ✅ ワークスペース初期化完了                                    ║"
echo "  ╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  ワークスペース: ${WORKSPACE_DIR}/"
echo ""
echo "  初期化されたファイル:"
echo "    - workspace/README.md"
echo "    - workspace/.gitignore"
echo "    - workspace/queue/dashboard.md"
echo "    - workspace/queue/po_to_sm.yaml"
echo "    - workspace/queue/tasks/dev1-dev3.yaml"
echo "    - workspace/queue/reports/TEMPLATE.yaml"
echo "    - workspace/specs/current_spec.md"
echo "    - workspace/specs/backlog.md"
echo ""
echo "  シンボリックリンク:"
echo "    - workspace/instructions -> ../instructions"
echo "    - workspace/.claude/skills -> ../../skills"
echo "    - workspace/.opencode/skills -> ../../skills"
echo ""
if [ "$NO_BACKUP" = false ] && [ -d "$BACKUP_DIR" ]; then
    echo "  バックアップ先: $BACKUP_DIR"
    echo ""
fi
echo "  次のステップ:"
echo "    ./scripts/boot.sh    # エージェントを起動"
echo ""
