# IXV-Agents Specification (Spec.md)

**Version**: 0.3.0 (Draft)
**Last Updated**: 2026-02-01
**Status**: Initial Design

---

## 1. 概要

IXV-Agentsは、**仕様主導（Specification-Driven）** のAI開発システムである。
`multi-agent-shogun` のアーキテクチャ（tmux + Claude Code CLI + イベント駆動通信）をベースに、アジャイル開発の役割（PO, SM, Dev）を実装する。

**基本理念**:

- **仕様（Specs）** が唯一の信頼できる情報源（Single Source of Truth）
- **役割（Roles）** による責任分担
- **イベント（Events）** によるリズム形成

## 1.1. 目的 / 非目的

### 目的 (Goals)

- 仕様主導での **ガバナンス / トレーサビリティ / 再現性** の確保
- 役割分担に基づく **責任の明確化**
- 仕様変更と実装変更の **同期と監査性**

### 非目的 (Non-Goals)

- 単一AIによる自律的な製品開発の実現
- 仕様無し・口頭のみでの開発フロー
- 実装詳細や最適化の自動化（本仕様は **運用モデル** を規定する）

## 1.2. 用語定義

- **Spec**: 仕様書（Single Source of Truth）。`README.md` を指す。
- **Task**: SMが作成する実装/検証単位。`queue/tasks/*.yaml` に記録。
- **Report**: Devの作業結果。`queue/reports/*.yaml` に記録。
- **Event**: スプリントイベントやDaily Loopの起点となる操作。

## 2. アーキテクチャ

### 2.1. 階層構造

```
User (Stakeholder)
  │
  ▼ 要望
┌──────────────┐
│  Product     │ ← PO (プロダクトオーナー)
│  Owner (PO)  │   ・仕様策定、バックログ管理
└──────┬───────┘
       │ YAML (queue/po_to_sm.yaml)
       ▼
┌──────────────┐
│    Scrum     │ ← SM (スクラムマスター)
│  Master (SM) │   ・タスク分解、割り当て、進捗管理
└──────┬───────┘
       │ YAML (queue/tasks/dev{N}.yaml)
       ▼
┌──────────────┐
│ Developers   │ ← Dev (3名)
│ (Dev 1-8)    │   ・実装
└──────────────┘
```

### 2.2. 通信プロトコル

- **イベント駆動**: ポーリング禁止。`tmux send-keys` でエージェントを起動（Wake up）。
- **データ永続化**: 通信内容はYAMLファイルに記録。
- **排他制御**: 各エージェントは専用の入力ファイルを持つ。

### 2.2.1. ファイル命名規則

- **PO → SM**: `queue/po_to_sm.yaml`
- **SM → Dev**: `queue/tasks/dev{N}.yaml`（Nは1開始）
- **Dev → SM**: `queue/reports/{task_id}.yaml`

## 2.3. データスキーマ (YAML)

### 2.3.0. 共通メタデータ（推奨）

```yaml
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
updated_at: "YYYY-MM-DDTHH:MM:SSZ"
```

### 2.3.1. ID / 参照ルール

- **request_id**: `REQ-YYYYMMDD-###`（例: `REQ-20260129-001`）
- **task_id**: `TASK-YYYYMMDD-###`（例: `TASK-20260129-004`）
- **spec_ref**: `README.md` もしくは `README.md#section`

### 2.3.2. PO -> SM フィールド定義

| Field | Required | Type | Allowed / Notes |
|------|----------|------|-----------------|
| schema_version | optional | string | `"1.0"` |
| created_at | optional | string | ISO-8601 UTC |
| updated_at | optional | string | ISO-8601 UTC |
| spec_ref | required | string | `README.md` |
| request_id | required | string | `REQ-YYYYMMDD-###` |
| priority | required | string | `P0` / `P1` / `P2` |
| summary | required | string | 120文字以内推奨 |
| acceptance_criteria | required | string[] | 1件以上 |
| constraints | optional | string[] | |
| notes | optional | string | |

**例: PO -> SM (queue/po_to_sm.yaml)**

```yaml
spec_ref: README.md
request_id: "REQ-YYYYMMDD-001"
priority: "P0"
summary: "短い要件サマリ"
acceptance_criteria:
  - "条件1"
  - "条件2"
constraints:
  - "制約1"
notes: "任意の補足"
```

### 2.3.3. SM -> Dev フィールド定義

| Field | Required | Type | Allowed / Notes |
|------|----------|------|-----------------|
| schema_version | optional | string | `"1.0"` |
| created_at | optional | string | ISO-8601 UTC |
| updated_at | optional | string | ISO-8601 UTC |
| task_id | required | string | `TASK-YYYYMMDD-###` |
| spec_ref | required | string | `README.md` |
| request_id | optional | string | `REQ-YYYYMMDD-###` |
| assignee | required | string | `dev1`〜`dev8` |
| type | required | string | `dev` / `doc`（docはドキュメント更新） |
| summary | required | string | 140文字以内推奨 |
| definition_of_done | required | string[] | 1件以上 |
| inputs | optional | string[] | |
| outputs | optional | string[] | |
| dependencies | optional | string[] | `TASK-...` |

**例: SM -> Dev (queue/tasks/*.yaml)**

```yaml
task_id: "TASK-YYYYMMDD-001"
spec_ref: README.md
request_id: "REQ-YYYYMMDD-001"
assignee: "dev1"
type: "dev"
summary: "タスク概要"
definition_of_done:
  - "完了条件"
inputs:
  - "参照ファイルや前提"
outputs:
  - "期待成果物"
dependencies:
  - "TASK-..."
```

### 2.3.4. Dev -> SM フィールド定義

| Field | Required | Type | Allowed / Notes |
|------|----------|------|-----------------|
| schema_version | optional | string | `"1.0"` |
| created_at | optional | string | ISO-8601 UTC |
| updated_at | optional | string | ISO-8601 UTC |
| task_id | required | string | `TASK-YYYYMMDD-###` |
| status | required | string | `done` / `blocked` / `needs_review` |
| summary | required | string | 200文字以内推奨 |
| changes | optional | string[] | |
| artifacts | optional | string[] | 変更ファイル/成果物 |
| issues | optional | string[] | ブロッカーや不具合 |

**例: Dev -> SM (queue/reports/*.yaml)**

```yaml
task_id: "TASK-YYYYMMDD-001"
status: "done"
summary: "結果概要"
changes:
  - "変更点の箇条書き"
artifacts:
  - "ファイルパス"
issues:
  - "課題や不具合"
```

### 2.3.5. YAMLテンプレート（最小）

**PO -> SM**
```yaml
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
updated_at: "YYYY-MM-DDTHH:MM:SSZ"
spec_ref: README.md
request_id: "REQ-YYYYMMDD-001"
priority: "P0"
summary: ""
acceptance_criteria: []
constraints: []
notes: ""
```

**SM -> Dev**
```yaml
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
updated_at: "YYYY-MM-DDTHH:MM:SSZ"
task_id: "TASK-YYYYMMDD-001"
spec_ref: README.md
request_id: "REQ-YYYYMMDD-001"
assignee: "dev1"
type: "dev"
summary: ""
definition_of_done: []
inputs: []
outputs: []
dependencies: []
```

**Dev -> SM**
```yaml
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
updated_at: "YYYY-MM-DDTHH:MM:SSZ"
task_id: "TASK-YYYYMMDD-001"
status: "done"
summary: ""
changes: []
artifacts: []
issues: []
```

*注: 必須配列（`acceptance_criteria`, `definition_of_done`）は送信前に1件以上で埋める。*

## 2.4. タスク状態遷移 (State)

```
queued -> in_progress -> done
                    -> blocked
                    -> needs_review
```

## 2.5. 排他/競合ルール

- 同一 `task_id` に対する同時編集は禁止。
- 進行中タスクの中断は `status: blocked` で報告し、SMの判断で再割当て。

## 2.6. ファイル所有権マトリクス (書き込み権限)

| Role | Write | Read |
|------|-------|------|
| PO | `workspace/README.md`, `workspace/queue/po_to_sm.yaml` | 全体 |
| SM | `workspace/queue/tasks/*.yaml`, `workspace/queue/dashboard.md` | 全体 |
| Dev | `workspace/queue/reports/*.yaml`, 実装関連ファイル | 仕様/タスク/ダッシュボード |

*注: すべてのパスは `workspace/` 配下を指す。実装関連ファイルも `workspace/` 内に作成される。*

## 3. 役割定義 (Roles)

### 3.1. Product Owner (PO) - 1名

- **責任**: プロダクトの価値最大化。
- **主なタスク**:
  - ユーザー要望のヒアリング
  - **仕様書（README.md）の作成・更新**
  - プロダクトバックログの優先順位付け
  - 完成品の受入（Acceptance）
- **禁止事項**: コードの実装、タスクの直接割り当て。

### 3.2. Scrum Master (SM) - 1名

- **責任**: チームのプロセス管理と障害除去。
- **主なタスク**:
  - スプリント計画の進行
  - **仕様から実装タスク（WBS）への分解**
  - Devへのタスク割り当て
  - **ダッシュボード（queue/dashboard.md）の更新**
  - チーム間のブロッカー解決
- **禁止事項**: 実装作業、POへの越権行為。

### 3.3. Development Team (Dev) - 3名

- **責任**: 動作するソフトウェアの作成。
- **主なタスク**:
  - 設計・コーディング
  - ユニットテスト作成
  - 詳細設計書（Implementation Plan）の更新
- **構成**: Dev1〜Dev3
- **禁止事項**: 仕様の勝手な変更、他エージェントの担当ファイルへの書き込み。

## 3.4. 共通ガードレール

- 仕様/タスク/レポートは **必ずファイルに記録** する。
- 役割外のファイル更新は禁止（権限境界の維持）。
- 仕様の変更は PO のみが行う。

## 4. ディレクトリ構成

```
ixv-agents/
├── config/             # プロジェクト設定
├── instructions/       # 各ロールへの指示書 (PO, SM, Dev) [読み取り専用]
├── skills/             # AI CLIのスキル定義 [読み取り専用]
├── templates/          # ワークスペース初期化用テンプレート
│   ├── README.md       # 仕様書テンプレート
│   ├── .gitignore
│   └── queue/
│       ├── dashboard.md
│       ├── po_to_sm.yaml
│       ├── tasks/dev.yaml
│       └── reports/TEMPLATE.yaml
├── scripts/            # 起動・管理スクリプト
│   ├── boot.sh         # エージェント起動
│   └── setup_workdir.sh # ワークスペース初期化
├── backups/            # ワークスペースのバックアップ [.gitignore]
│   └── backup_YYYYMMDD_HHMMSS/
├── workspace/          # AIエディタの作業ディレクトリ [.gitignore]
│   └── (詳細は 4.1 参照)
├── docs/               # ドキュメント
├── Spec.md             # 本仕様書
└── README.md
```

### 4.1. workspace/ ディレクトリ（AIエディタ作業領域）

`workspace/` はAIエディタ（Claude Code / OpenCode）が実際に作業を行うディレクトリである。
リポジトリルートとは分離されており、AIエディタがツールのREADME等にアクセスすることを防ぐ。

```
workspace/
├── README.md           # 仕様書 (Single Source of Truth)
├── .gitignore          # Git除外設定（queue/等）
├── .claude/            # Claude Code設定
│   ├── settings.local.json
│   └── skills -> ../../skills    (symlink)
├── .opencode/          # OpenCode設定
│   └── skills -> ../../skills    (symlink)
├── instructions -> ../instructions  (symlink)
├── queue/              # 通信バッファ（.gitignoreで除外）
│   ├── dashboard.md    # プロジェクト全体状況ボード
│   ├── po_to_sm.yaml   # PO -> SM
│   ├── tasks/          # SM -> Dev
│   │   └── dev1-3.yaml
│   └── reports/        # Dev -> SM
│       └── TEMPLATE.yaml
└── (成果物)            # 実装コード、テスト等
```

#### シンボリックリンク

| リンクパス | リンク先 | 用途 |
|------------|----------|------|
| `workspace/instructions` | `../instructions` | 役割定義の参照 |
| `workspace/.claude/skills` | `../../skills` | Claude Code用スキル |
| `workspace/.opencode/skills` | `../../skills` | OpenCode用スキル |

#### 初期化

ワークスペースは `scripts/setup_workdir.sh` で初期化される。
初期化時に `templates/` 内のテンプレートがコピーされ、プレースホルダーが置換される。

```bash
# ワークスペースを初期化（既存データがあればバックアップ）
./scripts/setup_workdir.sh

# バックアップなしで初期化
./scripts/setup_workdir.sh --no-backup
```

## 4.2. dashboard.md フォーマット

```markdown
# IXV-Agents Dashboard

## Sprint Info
- Sprint: {N}
- Period: YYYY-MM-DD ~ YYYY-MM-DD
- Goal: {Sprint Goal}

## Backlog Status
| Priority | ID | Summary | Status | Assignee |
|----------|-----|---------|--------|----------|
| P0 | REQ-... | ... | queued/in_progress/done | - |

## Agent Status
| Agent | Current Task | Status | Last Update |
|-------|--------------|--------|-------------|
| Dev1 | TASK-... | working/idle/blocked | HH:MM |
| ... | | | |

## Blockers
- [ ] {Blocker description} (Owner: SM)

## Notes
- {Any relevant notes}
```

## 4.3. README.md テンプレート（仕様書）

`workspace/README.md` は唯一の仕様書（Single Source of Truth）として以下の構成を持つ。

```markdown
# Project Name

## Metadata
- Version: 0.1.0
- Last Updated: YYYY-MM-DD

## Goal
- 目的/達成したい価値

## Scope
- 含める範囲
- 含めない範囲（Non-Goals）

## Requirements
- 機能要件

## Acceptance Criteria
- 受入条件（テスト観点）

## Constraints
- 技術/運用/セキュリティ制約

## Backlog
| ID | Priority | Summary | Status |
|----|----------|---------|--------|
| REQ-... | P0 | ... | ready/in_sprint/done |

## Icebox
- {Future ideas not yet prioritized}
```

## 5. ワークフロー (Events)

### 5.1. Sprint Planning

1. **PO**: バックログから次スプリントの対象を選定し、仕様を明確化（`README.md`）。
2. **SM**: 仕様を読み込み、タスクに分解。Devに割り当て。

### 5.2. Implementation (Daily Loop)

1. **Dev**: 割り当てられたタスクを実行。完了後、SMに報告。
2. **SM**: 報告を確認し、結果を統合。次のタスクがあれば割り当て。

### 5.3. Sprint Review & Retrospective

- スプリント終了時に、成果物を確認し、プロセスを改善する（PO/SM主導）。

### 5.4. Event 実行トリガー（最小）

- **Planning**: POが `README.md` を更新した時点で開始
- **Daily**: SMが `queue/tasks/*.yaml` を更新した時点で開始
- **Review**: 全タスクの `status: done` レポートが揃った時点で開始

## 6. 技術スタック

- **Base System**: `multi-agent-shogun` (Bash, tmux)
- **Reference Implementation**: `multi-agent-shogun-main/`（本リポジトリ同梱）
- **AI Model**: Claude 3.7 Sonnet (Main), Opus (PO/Planning if needed)
- **CLI**: `claude-code`
- **MCP**: Memory, Filesystem, etc.

## 7. 運用・監査

- **ログ**: すべての決定はYAMLまたはMarkdownで記録。
- **監査**: `spec_ref` / `task_id` / `request_id` を追跡キーとして利用。
- **バージョン**: `README.md` の更新履歴を残す（Git履歴を前提）。

## 8. セキュリティ / 権限

- 役割境界により書き込み先を制限し、意図しない仕様変更を防止。
- 外部通信が必要な場合は明示的に許可（運用ポリシーで管理）。

## 9. エラーハンドリング / リカバリー

### 9.1. タスク失敗時

1. **Dev**: `status: blocked` でレポートを送信。`issues` に原因を記載。
2. **SM**: ブロッカーを確認し、以下のいずれかを実施：
   - タスクの再割り当て
   - タスクの分割・再定義
   - POへのエスカレーション（仕様の問題の場合）

### 9.2. エージェント無応答時

1. **SM**: 該当エージェントのタスクを `status: blocked` に変更。
2. **SM**: 別のエージェントにタスクを再割り当て。
3. **運用者**: tmuxセッションを確認し、必要に応じてエージェントを再起動。

### 9.3. 仕様の不整合検出時

1. **検出者**: SMに報告（`queue/reports/` 経由）。
2. **SM**: POにエスカレーション。
3. **PO**: 仕様を修正し、影響範囲を評価。必要に応じてタスクを再発行。

### 9.4. YAML破損・欠落時

1. **SM**: 直近のバックアップまたはGit履歴から復旧
2. **SM**: 復旧内容を `queue/reports/` に記録
3. **PO**: 仕様側に影響がある場合は修正し再通知

## 10. 変更履歴

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.3.0 | 2026-02-01 | - | specsディレクトリ廃止、README.mdを唯一の仕様書に統合 |
| 0.2.1 | 2026-02-01 | - | workspaceをリポジトリとして見立て: README.md/.gitignore追加、dashboard.mdをqueue/配下に移動 |
| 0.2.0 | 2026-02-01 | - | workspace/分離、templates/追加、ディレクトリ構成更新 |
| 0.1.0 | 2026-01-29 | - | Initial draft |
