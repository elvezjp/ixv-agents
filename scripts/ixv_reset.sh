#!/bin/bash
# ============================================================
# ixv_reset.sh - IXV-Agents 前回記録バックアップ＆初期化スクリプト
# ============================================================
# 使用方法:
#   ./scripts/ixv_reset.sh           # バックアップ＆初期化
#   ./scripts/ixv_reset.sh --no-backup  # バックアップなしで初期化のみ
#   ./scripts/ixv_reset.sh -h        # ヘルプ表示
# ============================================================

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$ROOT_DIR"

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
            echo "IXV-Agents 前回記録バックアップ＆初期化スクリプト"
            echo ""
            echo "使用方法: ./scripts/ixv_reset.sh [オプション]"
            echo ""
            echo "オプション:"
            echo "  --no-backup    バックアップをスキップして初期化のみ実行"
            echo "  -h, --help     このヘルプを表示"
            echo ""
            echo "動作内容:"
            echo "  1. 前回記録をバックアップ（logs/backup_YYYYMMDD_HHMMSS/）"
            echo "  2. キューファイルを初期化（queue/tasks/, queue/reports/, queue/po_to_sm.yaml）"
            echo "  3. specsを初期化（specs/current_spec.md, specs/backlog.md）"
            echo "  4. ダッシュボードを初期化（dashboard.md）"
            echo ""
            exit 0
            ;;
        *)
            echo "不明なオプション: $1"
            echo "./scripts/ixv_reset.sh -h でヘルプを表示"
            exit 1
            ;;
    esac
done

echo ""
echo "  ╔══════════════════════════════════════════════════════════════╗"
echo "  ║  IXV-Agents Reset Script                                     ║"
echo "  ║  前回記録バックアップ＆初期化                                   ║"
echo "  ╚══════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================
# STEP 1: 前回記録のバックアップ（内容がある場合のみ）
# ============================================================
if [ "$NO_BACKUP" = false ]; then
    log_step "STEP 1: 前回記録のバックアップ"

    BACKUP_DIR="./logs/backup_$(date '+%Y%m%d_%H%M%S')"
    NEED_BACKUP=false

    # バックアップが必要かチェック（タスクファイルにデータがあるか）
    for f in ./queue/tasks/*.yaml; do
        if [ -f "$f" ]; then
            if grep -q "task_id:" "$f" 2>/dev/null && ! grep -q "task_id: null" "$f" 2>/dev/null; then
                NEED_BACKUP=true
                break
            fi
        fi
    done

    # レポートファイルをチェック（TEMPLATE以外）
    for f in ./queue/reports/*.yaml; do
        if [ -f "$f" ] && [[ "$f" != *"TEMPLATE"* ]]; then
            NEED_BACKUP=true
            break
        fi
    done

    # dashboard.mdにタスク記録があるかチェック
    if [ -f "./dashboard.md" ]; then
        if grep -q "TASK-" "./dashboard.md" 2>/dev/null || grep -q "REQ-" "./dashboard.md" 2>/dev/null; then
            NEED_BACKUP=true
        fi
    fi

    # specs/current_spec.mdに内容があるかチェック
    if [ -f "./specs/current_spec.md" ]; then
        if ! grep -q "^# TBD" "./specs/current_spec.md" 2>/dev/null; then
            NEED_BACKUP=true
        fi
    fi

    if [ "$NEED_BACKUP" = true ]; then
        mkdir -p "$BACKUP_DIR"

        # dashboard.mdをバックアップ
        if [ -f "./dashboard.md" ]; then
            cp "./dashboard.md" "$BACKUP_DIR/"
            log_info "dashboard.md をバックアップ"
        fi

        # queue/po_to_sm.yamlをバックアップ
        if [ -f "./queue/po_to_sm.yaml" ]; then
            cp "./queue/po_to_sm.yaml" "$BACKUP_DIR/"
            log_info "queue/po_to_sm.yaml をバックアップ"
        fi

        # queue/tasksをバックアップ
        if [ -d "./queue/tasks" ]; then
            cp -r "./queue/tasks" "$BACKUP_DIR/"
            log_info "queue/tasks/ をバックアップ"
        fi

        # queue/reportsをバックアップ（TEMPLATE以外）
        if [ -d "./queue/reports" ]; then
            mkdir -p "$BACKUP_DIR/reports"
            for f in ./queue/reports/*.yaml; do
                if [ -f "$f" ] && [[ "$f" != *"TEMPLATE"* ]]; then
                    cp "$f" "$BACKUP_DIR/reports/"
                fi
            done
            log_info "queue/reports/ をバックアップ"
        fi

        # specsをバックアップ
        if [ -d "./specs" ]; then
            cp -r "./specs" "$BACKUP_DIR/"
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

[ -d ./queue/tasks ] || mkdir -p ./queue/tasks
[ -d ./queue/reports ] || mkdir -p ./queue/reports
[ -d ./specs ] || mkdir -p ./specs
[ -d ./logs ] || mkdir -p ./logs

log_success "ディレクトリ構造 OK"

# ============================================================
# STEP 3: キューファイルのリセット
# ============================================================
log_step "STEP 3: キューファイルの初期化"

TIMESTAMP=$(date -u "+%Y-%m-%dT%H:%M:%SZ")

# po_to_sm.yaml を初期化
cat > ./queue/po_to_sm.yaml << EOF
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
    cat > ./queue/tasks/dev${i}.yaml << EOF
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
for f in ./queue/reports/*.yaml; do
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
if [ ! -f "./queue/reports/TEMPLATE.yaml" ]; then
    cat > ./queue/reports/TEMPLATE.yaml << 'EOF'
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
# STEP 4: specsの初期化
# ============================================================
log_step "STEP 4: specsの初期化"

# specs/current_spec.md を初期化
cat > ./specs/current_spec.md << 'EOF'
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
cat > ./specs/backlog.md << 'EOF'
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
# STEP 5: ダッシュボードの初期化
# ============================================================
log_step "STEP 5: ダッシュボードの初期化"

DASHBOARD_DATE=$(date "+%Y-%m-%d")

cat > ./dashboard.md << EOF
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
echo "  ║  ✅ 初期化完了                                                ║"
echo "  ╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  初期化されたファイル:"
echo "    - dashboard.md"
echo "    - queue/po_to_sm.yaml"
echo "    - queue/tasks/dev1-dev8.yaml"
echo "    - queue/reports/ (TEMPLATEを除き削除)"
echo "    - specs/current_spec.md"
echo "    - specs/backlog.md"
echo ""
if [ "$NO_BACKUP" = false ] && [ "$NEED_BACKUP" = true ]; then
    echo "  バックアップ先: $BACKUP_DIR"
    echo ""
fi
echo "  次のステップ:"
echo "    ./scripts/ixv_boot.sh    # エージェントを起動"
echo ""
