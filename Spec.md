# IXV-Agents Specification (Spec.md)

**Version**: 0.1.0 (Draft)
**Last Updated**: 2026-01-29
**Status**: Initial Design

---

## 1. 概要

IXV-Agentsは、**仕様主導（Specification-Driven）** のAI開発システムである。
`multi-agent-shogun` のアーキテクチャ（tmux + Claude Code CLI + イベント駆動通信）をベースに、アジャイル開発の役割（PO, SM, Dev, QA）を実装する。

**基本理念**:

- **仕様（Specs）** が唯一の信頼できる情報源（Single Source of Truth）
- **役割（Roles）** による責任分担
- **イベント（Events）** によるリズム形成

## 1.1. 目的 / 非目的

### 目的 (Goals)

- 仕様主導での **ガバナンス / トレーサビリティ / 再現性** の確保
- 役割分担に基づく **責任の明確化**
- 仕様変更と実装変更の **同期と監査性**
- ダッシュボード/キュー状況を確認できる **ローカルWeb UI** の提供

### 非目的 (Non-Goals)

- 単一AIによる自律的な製品開発の実現
- 仕様無し・口頭のみでの開発フロー
- 実装詳細や最適化の自動化（本仕様は **運用モデル** を規定する）

## 1.2. 用語定義

- **Spec**: 仕様書（Single Source of Truth）。`specs/current_spec.md` を指す。
- **Task**: SMが作成する実装/検証単位。`queue/tasks/*.yaml` に記録。
- **Report**: Dev/QAの作業結果。`queue/reports/*.yaml` に記録。
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
       │ YAML (queue/tasks/dev{N}.yaml / qa{N}.yaml)
       ▼
┌──────────────┬──────────────┐
│ Developers   │ QA Team      │ ← Dev (8名) / QA (2名)
│ (Dev 1-8)    │ (QA 1-2)     │   ・実装および品質保証
└──────────────┴──────────────┘
```

### 2.2. 通信プロトコル

- **イベント駆動**: ポーリング禁止。`tmux send-keys` でエージェントを起動（Wake up）。
- **データ永続化**: 通信内容はYAMLファイルに記録。
- **排他制御**: 各エージェントは専用の入力ファイルを持つ。

### 2.2.1. ファイル命名規則

- **PO → SM**: `queue/po_to_sm.yaml`
- **SM → Dev/QA**: `queue/tasks/dev{N}.yaml`, `queue/tasks/qa{N}.yaml`（Nは1開始）
- **Dev/QA → SM**: `queue/reports/{task_id}.yaml`

### 2.2.2. Web UI の位置づけ

- Web UI は **読み取り専用** とし、`dashboard.md` と `queue/` を表示する。
- Markdown/YAML が **Single Source of Truth** であり、UIはそれを反映する。
- UI実装は **frontend/**（React + Tailwind）と **backend/**（ローカル読取専用サービス）に分ける。

### 2.2.3. Web UI 要件（最小）

- **提供形態**: ローカルのみ（`localhost` で提供）、外部公開はしない
- **権限**: 読み取り専用（UIからの書き込みは不可）
- **更新方法**: ファイル更新を検知して反映（最低でも手動リロードで最新化可能）
- **対象ファイル**: `dashboard.md`, `queue/po_to_sm.yaml`, `queue/tasks/*.yaml`, `queue/reports/*.yaml`
- **目的**: 進捗確認とトレーサビリティの可視化（編集はMarkdown/YAML側で実施）

### 2.2.4. Web UI 表示項目（最小）

- **Dashboard**: `dashboard.md` の内容をそのまま表示
- **Queue Overview**: `po_to_sm`, `tasks`, `reports` の一覧と最終更新時刻
- **Task Detail**: `task_id` / `assignee` / `status` / `summary` / `artifacts` の表示

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
- **spec_ref**: `specs/current_spec.md` もしくは `specs/current_spec.md#section`

### 2.3.2. PO -> SM フィールド定義

| Field | Required | Type | Allowed / Notes |
|------|----------|------|-----------------|
| schema_version | optional | string | `"1.0"` |
| created_at | optional | string | ISO-8601 UTC |
| updated_at | optional | string | ISO-8601 UTC |
| spec_ref | required | string | `specs/current_spec.md` |
| request_id | required | string | `REQ-YYYYMMDD-###` |
| priority | required | string | `P0` / `P1` / `P2` |
| summary | required | string | 120文字以内推奨 |
| acceptance_criteria | required | string[] | 1件以上 |
| constraints | optional | string[] | |
| notes | optional | string | |

**例: PO -> SM (queue/po_to_sm.yaml)**

```yaml
spec_ref: specs/current_spec.md
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

### 2.3.3. SM -> Dev/QA フィールド定義

| Field | Required | Type | Allowed / Notes |
|------|----------|------|-----------------|
| schema_version | optional | string | `"1.0"` |
| created_at | optional | string | ISO-8601 UTC |
| updated_at | optional | string | ISO-8601 UTC |
| task_id | required | string | `TASK-YYYYMMDD-###` |
| spec_ref | required | string | `specs/current_spec.md` |
| request_id | optional | string | `REQ-YYYYMMDD-###` |
| assignee | required | string | `dev1`〜`dev8` / `qa1`〜`qa2` |
| type | required | string | `dev` / `qa` / `doc`（docはドキュメント更新） |
| summary | required | string | 140文字以内推奨 |
| definition_of_done | required | string[] | 1件以上 |
| inputs | optional | string[] | |
| outputs | optional | string[] | |
| dependencies | optional | string[] | `TASK-...` |

**例: SM -> Dev/QA (queue/tasks/*.yaml)**

```yaml
task_id: "TASK-YYYYMMDD-001"
spec_ref: specs/current_spec.md
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

### 2.3.4. Dev/QA -> SM フィールド定義

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

**例: Dev/QA -> SM (queue/reports/*.yaml)**

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
spec_ref: specs/current_spec.md
request_id: "REQ-YYYYMMDD-001"
priority: "P0"
summary: ""
acceptance_criteria: []
constraints: []
notes: ""
```

**SM -> Dev/QA**
```yaml
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
updated_at: "YYYY-MM-DDTHH:MM:SSZ"
task_id: "TASK-YYYYMMDD-001"
spec_ref: specs/current_spec.md
request_id: "REQ-YYYYMMDD-001"
assignee: "dev1"
type: "dev"
summary: ""
definition_of_done: []
inputs: []
outputs: []
dependencies: []
```

**Dev/QA -> SM**
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
| PO | `Spec.md`, `specs/*.md`, `queue/po_to_sm.yaml` | 全体 |
| SM | `queue/tasks/*.yaml`, `dashboard.md` | 全体 |
| Dev | `queue/reports/*.yaml`, 実装関連ファイル | 仕様/タスク/ダッシュボード |
| QA | `queue/reports/*.yaml`, テスト関連ファイル | 仕様/タスク/ダッシュボード |

*注: 実装関連ファイルは Phase 5 以降に作成予定。*

## 3. 役割定義 (Roles)

### 3.1. Product Owner (PO) - 1名

- **責任**: プロダクトの価値最大化。
- **主なタスク**:
  - ユーザー要望のヒアリング
  - **仕様書（Spec.md）の作成・更新**
  - プロダクトバックログの優先順位付け
  - 完成品の受入（Acceptance）
- **禁止事項**: コードの実装、タスクの直接割り当て。

### 3.2. Scrum Master (SM) - 1名

- **責任**: チームのプロセス管理と障害除去。
- **主なタスク**:
  - スプリント計画の進行
  - **仕様から実装タスク（WBS）への分解**
  - Dev/QAへのタスク割り当て
  - **ダッシュボード（dashboard.md）の更新**
  - チーム間のブロッカー解決
- **禁止事項**: 実装作業、POへの越権行為。

### 3.3. Development Team (Dev) - 8名

- **責任**: 動作するソフトウェアの作成。
- **主なタスク**:
  - 設計・コーディング
  - ユニットテスト作成
  - 詳細設計書（Implementation Plan）の更新
- **構成**: Dev1〜Dev8
- **禁止事項**: 仕様の勝手な変更、他エージェントの担当ファイルへの書き込み。

### 3.4. QA / Quality Team (QA) - 2名

- **責任**: 品質の保証と仕様適合性の確認。
- **主なタスク**:
  - テスト計画の作成
  - 統合テスト・E2Eテストの実行
  - コードレビュー（静的解析など）
  - バグ報告
- **構成**: QA1〜QA2

## 3.5. 共通ガードレール

- 仕様/タスク/レポートは **必ずファイルに記録** する。
- 役割外のファイル更新は禁止（権限境界の維持）。
- 仕様の変更は PO のみが行う。

## 4. ディレクトリ構成

```
ixv-agents/
├── config/             # プロジェクト設定
├── instructions/       # 各ロールへの指示書 (PO, SM, Dev, QA)
├── specs/              # 仕様書 (Single Source of Truth)
│   ├── current_spec.md
│   └── backlog.md
├── queue/              # 通信バッファ
│   ├── po_to_sm.yaml
│   ├── tasks/          # SM -> Dev/QA
│   └── reports/        # Dev/QA -> SM
├── dashboard.md        # プロジェクト全体状況ボード
├── frontend/           # ローカルWeb UI (React + Tailwind)
├── backend/            # ローカル読取専用サービス
├── memory/             # MCP Memory
└── scripts/            # 起動スクリプト等
```

## 4.1. dashboard.md フォーマット

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

## 4.2. backlog.md フォーマット

プロダクトバックログは `specs/backlog.md` で管理する。

```markdown
# Product Backlog

## Active Items
| ID | Priority | Summary | Status | Spec Ref |
|----|----------|---------|--------|----------|
| REQ-... | P0 | ... | ready/in_sprint/done | specs/current_spec.md#section |

## Icebox
- {Future ideas not yet prioritized}
```

## 4.3. current_spec.md テンプレート

`specs/current_spec.md` は以下の最小構成を満たす。

```markdown
# Spec Title

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
```

**追加推奨セクション（任意）**

```markdown
## Dependencies
- 依存関係（外部/内部）

## Risks
- 既知のリスク

## Open Questions
- 未解決事項
```

## 5. ワークフロー (Events)

### 5.1. Sprint Planning

1. **PO**: バックログから次スプリントの対象を選定し、仕様を明確化（`specs/current_spec.md`）。
2. **SM**: 仕様を読み込み、タスクに分解。Dev/QAに割り当て。

### 5.2. Implementation (Daily Loop)

1. **Dev**: 割り当てられたタスクを実行。完了後、SMに報告。
2. **SM**: 報告を確認し、結果を統合。次のタスクがあれば割り当て。
3. **QA**: 実装が完了した機能をテスト。

### 5.3. Sprint Review & Retrospective

- スプリント終了時に、成果物を確認し、プロセスを改善する（PO/SM主導）。

### 5.4. Event 実行トリガー（最小）

- **Planning**: POが `specs/current_spec.md` を更新した時点で開始
- **Daily**: SMが `queue/tasks/*.yaml` を更新した時点で開始
- **Review**: QAの `status: done` レポートが揃った時点で開始

## 6. 技術スタック

- **Base System**: `multi-agent-shogun` (Bash, tmux)
- **Reference Implementation**: `multi-agent-shogun-main/`（本リポジトリ同梱）
- **Frontend**: React, Tailwind CSS
- **Backend (UI)**: Local read-only service (TBD)
- **AI Model**: Claude 3.7 Sonnet (Main), Opus (PO/Planning if needed)
- **CLI**: `claude-code`
- **MCP**: Memory, Filesystem, etc.

## 7. 運用・監査

- **ログ**: すべての決定はYAMLまたはMarkdownで記録。
- **監査**: `spec_ref` / `task_id` / `request_id` を追跡キーとして利用。
- **バージョン**: `specs/current_spec.md` の更新履歴を残す（Git履歴を前提）。

## 8. セキュリティ / 権限

- 役割境界により書き込み先を制限し、意図しない仕様変更を防止。
- 外部通信が必要な場合は明示的に許可（運用ポリシーで管理）。

## 9. エラーハンドリング / リカバリー

### 9.1. タスク失敗時

1. **Dev/QA**: `status: blocked` でレポートを送信。`issues` に原因を記載。
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
| 0.1.0 | 2026-01-29 | - | Initial draft |
