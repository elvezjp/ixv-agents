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

# ワークスペースとバックアップのディレクトリ
WORKSPACE_DIR="./workspace"
BACKUP_BASE_DIR="./backups"

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
            echo "  4. キューファイル・specs・ダッシュボードを初期化"
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

echo ""
echo "  ╔══════════════════════════════════════════════════════════════╗"
echo "  ║  IXV-Agents Workspace Setup                                  ║"
echo "  ║  ワークスペース初期化                                          ║"
echo "  ╚══════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================
# STEP 1: 前回記録のバックアップ（内容がある場合のみ）
# ============================================================
if [ "$NO_BACKUP" = false ]; then
    log_step "STEP 1: 前回記録のバックアップ"

    BACKUP_DIR="${BACKUP_BASE_DIR}/backup_$(date '+%Y%m%d_%H%M%S')"
    NEED_BACKUP=false

    # バックアップが必要かチェック（タスクファイルにデータがあるか）
    for f in "${WORKSPACE_DIR}"/queue/tasks/*.yaml; do
        if [ -f "$f" ]; then
            if grep -q "task_id:" "$f" 2>/dev/null && ! grep -q "task_id: null" "$f" 2>/dev/null; then
                NEED_BACKUP=true
                break
            fi
        fi
    done

    # レポートファイルをチェック（TEMPLATE以外）
    for f in "${WORKSPACE_DIR}"/queue/reports/*.yaml; do
        if [ -f "$f" ] && [[ "$f" != *"TEMPLATE"* ]]; then
            NEED_BACKUP=true
            break
        fi
    done

    # dashboard.mdにタスク記録があるかチェック
    if [ -f "${WORKSPACE_DIR}/dashboard.md" ]; then
        if grep -q "TASK-" "${WORKSPACE_DIR}/dashboard.md" 2>/dev/null || grep -q "REQ-" "${WORKSPACE_DIR}/dashboard.md" 2>/dev/null; then
            NEED_BACKUP=true
        fi
    fi

    # specs/current_spec.mdに内容があるかチェック
    if [ -f "${WORKSPACE_DIR}/specs/current_spec.md" ]; then
        if ! grep -q "^# TBD" "${WORKSPACE_DIR}/specs/current_spec.md" 2>/dev/null; then
            NEED_BACKUP=true
        fi
    fi

    if [ "$NEED_BACKUP" = true ]; then
        mkdir -p "$BACKUP_DIR"

        # dashboard.mdをバックアップ
        if [ -f "${WORKSPACE_DIR}/dashboard.md" ]; then
            cp "${WORKSPACE_DIR}/dashboard.md" "$BACKUP_DIR/"
            log_info "dashboard.md をバックアップ"
        fi

        # queue/po_to_sm.yamlをバックアップ
        if [ -f "${WORKSPACE_DIR}/queue/po_to_sm.yaml" ]; then
            cp "${WORKSPACE_DIR}/queue/po_to_sm.yaml" "$BACKUP_DIR/"
            log_info "queue/po_to_sm.yaml をバックアップ"
        fi

        # queue/tasksをバックアップ
        if [ -d "${WORKSPACE_DIR}/queue/tasks" ]; then
            cp -r "${WORKSPACE_DIR}/queue/tasks" "$BACKUP_DIR/"
            log_info "queue/tasks/ をバックアップ"
        fi

        # queue/reportsをバックアップ（TEMPLATE以外）
        if [ -d "${WORKSPACE_DIR}/queue/reports" ]; then
            mkdir -p "$BACKUP_DIR/reports"
            for f in "${WORKSPACE_DIR}"/queue/reports/*.yaml; do
                if [ -f "$f" ] && [[ "$f" != *"TEMPLATE"* ]]; then
                    cp "$f" "$BACKUP_DIR/reports/"
                fi
            done
            log_info "queue/reports/ をバックアップ"
        fi

        # specsをバックアップ
        if [ -d "${WORKSPACE_DIR}/specs" ]; then
            cp -r "${WORKSPACE_DIR}/specs" "$BACKUP_DIR/"
            log_info "specs/ をバックアップ"
        fi

        log_success "バックアップ完了: $BACKUP_DIR"
    else
        log_info "バックアップ対象のデータがありません（スキップ）"
    fi
else
    log_step "STEP 1: バックアップをスキップ (--no-backup)"
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
# STEP 4: キューファイルのリセット
# ============================================================
log_step "STEP 4: キューファイルの初期化"

TIMESTAMP=$(date -u "+%Y-%m-%dT%H:%M:%SZ")

# po_to_sm.yaml を初期化
cat > "${WORKSPACE_DIR}/queue/po_to_sm.yaml" << EOF
schema_version: "1.0"
created_at: "${TIMESTAMP}"
updated_at: "${TIMESTAMP}"
spec_ref: null
request_id: null
priority: null
summary: null
acceptance_criteria: []
constraints: []
notes: null
EOF
log_info "queue/po_to_sm.yaml を初期化"

# Dev用タスクファイルを初期化 (dev1-dev8)
for i in {1..8}; do
    cat > "${WORKSPACE_DIR}/queue/tasks/dev${i}.yaml" << EOF
schema_version: "1.0"
created_at: "${TIMESTAMP}"
updated_at: "${TIMESTAMP}"
task_id: null
spec_ref: null
request_id: null
assignee: "dev${i}"
type: "dev"
summary: null
definition_of_done: []
inputs: []
outputs: []
dependencies: []
EOF
done
log_info "queue/tasks/dev1-dev8.yaml を初期化"

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

# TEMPLATEファイルが存在しない場合は作成
if [ ! -f "${WORKSPACE_DIR}/queue/reports/TEMPLATE.yaml" ]; then
    cat > "${WORKSPACE_DIR}/queue/reports/TEMPLATE.yaml" << 'EOF'
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
updated_at: "YYYY-MM-DDTHH:MM:SSZ"
task_id: "TASK-YYYYMMDD-001"
status: "done"
summary: ""
changes: []
artifacts: []
issues: []
EOF
    log_info "queue/reports/TEMPLATE.yaml を作成"
fi

log_success "キューファイル初期化完了"

# ============================================================
# STEP 5: specsの初期化
# ============================================================
log_step "STEP 5: specsの初期化"

# specs/current_spec.md を初期化
cat > "${WORKSPACE_DIR}/specs/current_spec.md" << 'EOF'
# TBD

## Metadata
- Version: 0.0.0
- Last Updated: TBD

## Goal
- TBD

## Scope
- 含める範囲
  - TBD
- 含めない範囲（Non-Goals）
  - TBD

## Requirements
- TBD

## Acceptance Criteria
- TBD

## Constraints
- TBD

## Dependencies
- TBD
EOF
log_info "specs/current_spec.md を初期化"

# specs/backlog.md を初期化
cat > "${WORKSPACE_DIR}/specs/backlog.md" << 'EOF'
# Product Backlog

## Active Items
| ID | Priority | Summary | Status | Spec Ref |
|----|----------|---------|--------|----------|
| - | - | - | - | - |

## Icebox
- TBD
EOF
log_info "specs/backlog.md を初期化"

log_success "specs初期化完了"

# ============================================================
# STEP 6: ダッシュボードの初期化
# ============================================================
log_step "STEP 6: ダッシュボードの初期化"

DASHBOARD_DATE=$(date "+%Y-%m-%d")

cat > "${WORKSPACE_DIR}/dashboard.md" << EOF
# IXV-Agents Dashboard

## Sprint Info
- Sprint: 0
- Period: ${DASHBOARD_DATE} ~ TBD
- Goal: TBD

## Backlog Status
| Priority | ID | Summary | Status | Assignee |
|----------|-----|---------|--------|----------|
| - | - | - | - | - |

## Agent Status
| Agent | Current Task | Status | Last Update |
|-------|--------------|--------|-------------|
| PO | - | idle | - |
| SM | - | idle | - |
| Dev1 | - | idle | - |
| Dev2 | - | idle | - |
| Dev3 | - | idle | - |
| Dev4 | - | idle | - |
| Dev5 | - | idle | - |
| Dev6 | - | idle | - |
| Dev7 | - | idle | - |
| Dev8 | - | idle | - |

## Blockers
- [ ] None

## Notes
- TBD
EOF

log_success "dashboard.md を初期化"

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
echo "    - workspace/dashboard.md"
echo "    - workspace/queue/po_to_sm.yaml"
echo "    - workspace/queue/tasks/dev1-dev8.yaml"
echo "    - workspace/queue/reports/ (TEMPLATEを除き削除)"
echo "    - workspace/specs/current_spec.md"
echo "    - workspace/specs/backlog.md"
echo ""
echo "  シンボリックリンク:"
echo "    - workspace/instructions -> ../instructions"
echo "    - workspace/.claude/skills -> ../../skills"
echo "    - workspace/.opencode/skills -> ../../skills"
echo ""
if [ "$NO_BACKUP" = false ] && [ "$NEED_BACKUP" = true ]; then
    echo "  バックアップ先: $BACKUP_DIR"
    echo ""
fi
echo "  次のステップ:"
echo "    ./scripts/boot.sh    # エージェントを起動"
echo ""
