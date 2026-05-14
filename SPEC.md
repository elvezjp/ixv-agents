# IXV-Agents Specification (SPEC.md)

**Version**: 0.2.0

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

## 1.3. バージョン管理

### 1.3.1. リリースバージョンの Single Source of Truth

リポジトリルートの `VERSION` ファイル（1 行のプレーンテキスト）が **リリースバージョンの唯一の正** である。リリース時は同名の Git タグ（`v{MAJOR}.{MINOR}.{PATCH}`）を打ち、`VERSION` ファイルとタグの値を一致させる。

本プロジェクトはランタイム配布物（npm パッケージ、PyPI 等）を持たないため、`package.json` や `pyproject.toml` のようなパッケージマニフェストは導入しない。

### 1.3.2. リリース時の更新フロー

1. `VERSION` を新バージョンに更新する
2. `CHANGELOG.md` / `CHANGELOG_ja.md` に新エントリを追加する（リリース日、カテゴリ別の変更点）
3. `SECURITY.md` / `SECURITY_ja.md` のサポート対象バージョンを必要に応じて更新する


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
│ (Dev 1-3)    │   ・実装
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
| assignee | required | string | `dev1`〜`dev3` |
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

## 2.4. タスク状態遷移と検証ルール

### 2.4.1. 状態遷移 (State)

```
queued -> in_progress -> done
                    -> blocked
                    -> needs_review
```

### 2.4.2. 必須配列の空配列禁止

§2.3 で定義された必須配列フィールドは、空配列のまま発行してはならない。スキーマ自体は変更せず、発行スキルが Step として強制する。

| ファイル | フィールド | 検証者 | 違反時アクション |
|---------|---------|-------|--------------|
| `queue/po_to_sm.yaml` | `acceptance_criteria` | PO（発行前） | 発行を中断し、Human にヒアリング |
| `queue/tasks/dev{N}.yaml` | `definition_of_done` | SM（発行前） | 発行を中断し、PO に確認（`po_to_sm.yaml` の `acceptance_criteria` を再読） |

各項目は **検証可能な形式**（「〜が実装されている」「〜テストが通る」等）で記述すること。

### 2.4.3. Definition of Done 突合

Dev は `status: done` を報告する際、対応するタスクの `definition_of_done` の各項目に対し、`changes` または `artifacts` のいずれかが対応していることをセルフチェックする。未カバー項目があれば、

1. 既存の `issues` フィールドに未対応理由を明記し、
2. `status` を `needs_review` に格下げする。

SM は `done` レポート受領時に同様の突合を行い、未カバー項目があれば既存の `dashboard.md` の `## Notes` に記載し、Dev に追加作業を指示する（dashboard 構成は変更しない）。

### 2.4.4. 必須フィールド欠落時の挙動

| 受領者 | 対象ファイル | 欠落検出時の挙動 |
|--------|----------|-----|
| SM | `po_to_sm.yaml` | PO に send-keys で確認、処理を保留 |
| Dev | `tasks/dev{N}.yaml` | `status: blocked` で SM に報告 |
| SM | `reports/{task_id}.yaml` | `dashboard.md` の `## Notes` に記録、Dev に再作成依頼 |

## 2.5. 排他/競合ルールと依存関係グラフ

### 2.5.1. 排他ルール

- 同一 `task_id` に対する同時編集は禁止。
- 進行中タスクの中断は `status: blocked` で報告し、SM の判断で再割当て。

### 2.5.2. 依存関係 DAG 必須

タスク間の `dependencies` は **有向非巡回グラフ（DAG）** でなければならない。SM はタスク発行前に循環依存の有無を検証する（`queue/tasks/*.yaml` の `dependencies` を BFS で辿り、自タスク ID が現れたら循環）。

### 2.5.3. 依存先の状態要件

| 依存先 status | SM の対応（発行前） | Dev の対応（受領時） |
|---|---|---|
| `done` | 発行可 | 受領可 |
| `in_progress` | 発行可（順次実行） / 発行延期も可 | 依存先完了まで待機（または `blocked` 報告） |
| `blocked` | 発行不可（解決後に再評価） | `status: blocked` で再報告 |
| `needs_review` | 発行不可（PO 判断後に再評価） | `status: blocked` で再報告 |
| 不在（task_id が存在しない） | 発行不可 | `status: blocked` で報告 |

### 2.5.4. 状態確認手段

依存先タスクの状態は **既存の `queue/reports/{dep_task_id}.yaml` の `status` フィールド** で確認する。report ファイルが存在しない場合は「未着手 or in_progress」と判定する。新たなフィールドやファイルは追加しない。

## 2.6. task_type → フェーズ判定規則

### 2.6.1. 直接マッピング

| task_type | Phase | 備考 |
|---|---|---|
| `constitution_update` | 1 | CONSTITUTION.md 更新 |
| `spec_update` | 2 | README.md 更新 |
| `plan` | 3 | 計画策定 |
| `execute` | 4 | タスク分割・実行指示 |
| `verify` | 6 | 検証 |
| `backlog_update` | 6 | Backlog ステータス更新 |

### 2.6.2. feature / bugfix の決定木

`feature` / `bugfix` は汎用的な task_type であり、コンテキストに応じてフェーズを判定する。SM は受領時に以下の決定木を **上から順に評価** し、最初にマッチした条件のフェーズを採用する。

1. 要件が `README.md` に未記載 → **Phase 2 (Specify)** = `spec_update` 相当
2. 要件は記載済みだが設計（`docs/`）未完了 → **Phase 3 (Plan)** = `plan` 相当
3. 設計済みだが実装未完了（成果物ファイル未作成） → **Phase 4 (Tasks)** = `execute` 相当
4. 実装済みだが検証未完了 → **Phase 6 (Verify)** = `verify` 相当

複数条件にマッチする場合は **より早いフェーズを優先** する（前段が未完了なら戻る）。判定後、SM は `dashboard.md` の `## Current Phase` を更新する（dashboard フォーマットは変更なし）。

## 2.7. ファイル所有権マトリクス (書き込み権限)

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
├── roles/              # 各ロールへの指示書 (PO, SM, Dev) [読み取り専用]
├── skills/             # AI CLIのスキル定義 [読み取り専用]
├── templates/          # ワークスペース初期化用テンプレート
│   ├── README.md       # 仕様書テンプレート
│   ├── CONSTITUTION.md # プロジェクト憲章
│   ├── PROCESS.md      # 工程と運用フロー
│   ├── AGENTS.md       # AI行動規範
│   ├── .gitignore
│   └── queue/
│       ├── dashboard.md
│       ├── po_to_sm.yaml
│       ├── tasks/dev.yaml
│       └── reports/TEMPLATE.yaml
├── scripts/            # 起動・管理スクリプト
│   ├── boot.sh         # エージェント起動
│   ├── stop.sh         # エージェント停止
│   ├── banner.sh       # ASCIIアート表示
│   └── setup_workspace.sh # ワークスペース初期化
├── backups/            # ワークスペースのバックアップ [.gitignore]
│   └── backup_YYYYMMDD_HHMMSS/
├── workspace/          # AIエディタの作業ディレクトリ [.gitignore]
│   └── (詳細は 4.1 参照)
├── docs/               # ドキュメント
├── SPEC.md             # 本仕様書
└── README.md
```

### 4.1. workspace/ ディレクトリ（AIエディタ作業領域）

`workspace/` はAIエディタ（Claude Code / OpenCode）が実際に作業を行うディレクトリである。
リポジトリルートとは分離されており、AIエディタがツールのREADME等にアクセスすることを防ぐ。

```
workspace/
├── README.md           # 仕様書 (Single Source of Truth)
├── CONSTITUTION.md     # プロジェクト憲章
├── PROCESS.md          # 工程と運用フロー
├── AGENTS.md           # AI行動規範
├── .gitignore          # Git除外設定（queue/等）
├── .claude/            # Claude Code設定
│   ├── settings.local.json
│   └── skills -> ../../skills    (symlink)
├── .opencode/          # OpenCode設定
│   └── skills -> ../../skills    (symlink)
├── roles -> ../roles  (symlink)
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
| `workspace/roles` | `../roles` | 役割定義の参照 |
| `workspace/.claude/skills` | `../../skills` | Claude Code用スキル |
| `workspace/.opencode/skills` | `../../skills` | OpenCode用スキル |

#### 初期化

ワークスペースは `scripts/setup_workspace.sh` で初期化される。
初期化時に `templates/` 内のテンプレートがコピーされ、プレースホルダーが置換される。

```bash
# ワークスペースを初期化（既存データがあればバックアップ）
./scripts/setup_workspace.sh

# バックアップなしで初期化
./scripts/setup_workspace.sh --no-backup
```

## 4.2. dashboard.md フォーマット

```markdown
# IXV-Agents Dashboard

## Current Phase
> **工程1 Constitution** — 原則決定

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

## 4.4. tmuxセッション構成

エージェントは1つのtmuxセッション（`ixv-agents`）で動作する。

### セッション情報

| セッション名 | 役割 | ペイン構成 |
|-------------|------|-----------|
| `ixv-agents` | 全エージェント（PO, SM, Dev1-3） | 5ペイン |

- **変更時の注意**: セッション名・ペイン番号はrolesやskillsの指示書で引用されている。変更時は必ず確認・修正すること。

### ペイン配置

```
【ixv-agents】
┌───────────────┬───────┬───────┬───────┐
│               │       │       │       │
│      PO       │ Dev1  │ Dev2  │ Dev3  │
│     (0.0)     │ (0.2) │ (0.3) │ (0.4) │
├───────────────┤       │       │       │
│               │       │       │       │
│      SM       │       │       │       │
│     (0.1)     │       │       │       │
└───────────────┴───────┴───────┴───────┘
  (左50%)        (右50%を3等分)
```

### ペイン番号対応表

| セッション | ペイン | 役割 |
|-----------|--------|------|
| ixv-agents | 0.0 | PO |
| ixv-agents | 0.1 | SM |
| ixv-agents | 0.2 | Dev1 |
| ixv-agents | 0.3 | Dev2 |
| ixv-agents | 0.4 | Dev3 |

## 4.5. スクリプト

### 4.5.1. boot.sh（エージェント起動）

エージェントを起動するスクリプト。

**機能**:
- 起動時に `banner.sh` を呼び出してASCIIアートを表示する
- tmuxセッション（`ixv-agents`）を作成し、5ペインを構成する
- 各ペインにヘルプメッセージ（セッション構成、起動後の流れ、操作方法）を表示する
- 各エージェント（PO, SM, Dev1-3）のペインでAI CLIを起動する
- セッション作成後、自動でアタッチする

### 4.5.2. banner.sh（ASCIIアート表示）

「IXV-agents」のASCIIアートを標準出力に表示するスクリプト。

### 4.5.3. setup_workspace.sh（ワークスペース初期化）

ワークスペースを初期化するスクリプト。

**機能**:
- `templates/` からファイルをコピー
- プレースホルダーの置換
- シンボリックリンクの作成
- 既存データのバックアップ（`--no-backup` オプションで無効化可能）

### 4.5.4. stop.sh（エージェント停止）

エージェントを停止するスクリプト。

**機能**:
- 各ペインに Ctrl+C を送信して CLI をグレースフル終了
- tmuxセッション（`ixv-agents`）を終了
- プロセスが残った場合に備え、`--force`オプションでAIエディタとtmuxのプロセスを強制終了できるようにする

## 5. エージェントワークフロー

本セクションは PROCESS.md の7つの工程に対応する。

### 5.0. 参照順序（全エージェント共通）

エージェントは以下の順序でドキュメントを参照する：

1. `CONSTITUTION.md` - プロジェクト憲章
2. `README.md` - 仕様書（Single Source of Truth）
3. `PROCESS.md` - 工程と運用フロー
4. `roles/*` - 各ロールの詳細指示

### 5.1. 原則決定フェーズ（Constitution）

プロジェクト開始時に CONSTITUTION.md の「存在意義（Purpose）」が未記入の場合に実行する。

```
[Human] プロジェクトの目的を伝える
    ↓
[PO] CONSTITUTION.md を確認
    ↓
    ├─ 目的が記載済み → スキップ（5.2へ）
    │
    └─ 目的が未記入（初期状態）
           ↓
       [PO] 目的をヒアリングし、po_to_sm.yaml に憲章更新タスクを記録
           ↓
       [SM] queue/dashboard.md の Current Phase を更新（工程1 Constitution）
           ↓
       [SM] CONSTITUTION.md を更新
           ↓
       [SM] POに更新完了を通知（send-keys）
           ↓
       [PO] Human に承認を依頼
           ↓
       [Human] ★ 憲章承認
```

| 担当 | 作成/更新ファイル | 承認 |
|------|------------------|------|
| PO | `queue/po_to_sm.yaml` | - |
| SM | `queue/dashboard.md`（Current Phase） | - |
| SM | `CONSTITUTION.md` | Human |

### 5.2. 企画・要件定義フェーズ（Specify）

Human の要望を仕様（README.md）に反映し、承認を得るフェーズ。

```
[Human] 要望を伝える
    ↓
[PO] README.md を確認
    ↓
    ├─ 要望が仕様に反映済み → スキップ（5.3へ）
    │
    └─ 要望が未反映
           ↓
       [PO] 要望をヒアリングし、po_to_sm.yaml に仕様策定タスクを記録
           ↓
       [SM] queue/dashboard.md の Current Phase を更新（工程2 Specify）
           ↓
       [SM] 仕様（README.md）更新
           ↓
       [SM] POに更新完了を通知（send-keys）
           ↓
       [PO] Human に承認を依頼
           ↓
       [Human] ★ 仕様承認
```

| 担当 | 作成/更新ファイル | 承認 |
|------|------------------|------|
| PO | `queue/po_to_sm.yaml` | - |
| SM | `queue/dashboard.md`（Current Phase） | - |
| SM | `README.md` | Human |

### 5.3. 設計計画フェーズ（Plan）

SMが実行計画を立てるフェーズ。要件の複雑さに応じて、SMが直接計画を策定するか、Devに調査・検討を依頼する。

```
[PO] po_to_sm.yaml に計画策定を依頼
    ↓
[SM] queue/dashboard.md の Current Phase を更新（工程3 Plan）
    ↓
[SM] 要件の複雑さを判断
    ↓
    ├─ 単純な要件
    │      ↓
    │  [SM] 計画を策定
    │
    └─ 複雑な要件
           ↓
       [SM] 調査・検討タスクを tasks/dev{N}.yaml に記録
           ↓
       [Dev] 調査・検討を実施し、結果を reports/{task_id}.yaml に報告
           ↓
       [SM] 調査結果を踏まえて計画を策定
    ↓
[SM] 実行計画を docs/ に作成（計画書・設計メモ）
    ↓
[SM] 仕様（README.md）を詳細化、更新
    ↓
[SM] POに計画完了と関連する仕様を通知（send-keys）
    ↓
[PO] Human に承認を依頼
    ↓
[Human] ★ 計画承認
```

*注: 計画書・設計メモは一時的な補助資料であり、**仕様（SSoT）は README.md のみ**。*

| 担当 | 作成/更新ファイル | 承認 |
|------|------------------|------|
| PO | `queue/po_to_sm.yaml` | - |
| SM | `queue/dashboard.md`（Current Phase） | - |
| SM | `queue/tasks/dev{N}.yaml`（調査用） | - |
| Dev | `queue/reports/{task_id}.yaml`（調査結果） | - |
| SM | `docs/*`（計画書・設計メモ） | Human |

### 5.4. タスク分割フェーズ（Tasks）

POが計画に応じて実行を指示し、SMがタスクに分割するフェーズ。

```
[PO] 計画に応じて、実行する旨を po_to_sm.yaml に記録
    ↓
[SM] po_to_sm.yaml を読み取り
    ↓
[SM] queue/dashboard.md の Current Phase を更新（工程4 Tasks）
    ↓
[SM] docs/ の計画書を読み取り
    ↓
[SM] 今回のタスクで実施する範囲を判断（計画にフェーズ分けがある場合は該当フェーズのみ）
    ↓
[SM] タスクを分解し queue/tasks/dev{N}.yaml を作成
```

| 担当 | 作成/更新ファイル | 承認 |
|------|------------------|------|
| PO | `queue/po_to_sm.yaml` | - |
| SM | `queue/tasks/dev{N}.yaml` | - |
| SM | `queue/dashboard.md`（Current Phase） | - |

### 5.5. 実装フェーズ（Implement）

```
[SM] queue/dashboard.md の Current Phase を更新（工程5 Implement）
    ↓
[SM] queue/dashboard.md を更新（Backlog Status）
    ↓
[SM] Devにタスクを通知（send-keys）
    ↓
[Dev] queue/tasks/dev{N}.yaml を読み取り
    ↓
[Dev] 実装作業（コード、テスト等）
    ↓
[Dev] queue/reports/{task_id}.yaml に結果を報告（問題や仕様との乖離があれば含める）
    ↓
[Dev] SMに完了を通知（send-keys）
    ↓
[SM] queue/reports/*.yaml を確認
    ↓
[SM] queue/dashboard.md を更新（Agent Status, 計画の進捗状況）
    ↓
[SM] POに完了内容を報告（問題があれば含める）（send-keys）
    ↓
[PO] queue/dashboard.md を確認し、Human に報告
    ↓
    ├─ 問題なし、計画完了 → 実装完了を通知し、検証に進むか確認
    │
    ├─ 問題なし、計画未完了 → 現フェーズの完了を通知し、次フェーズへ進むか確認
    │
    └─ 問題あり → 修正するかの判断を依頼
    ↓
[Human] 成果物を確認
    ↓
    ├─ 完了を確認 → 5.6 検証・受入フェーズへ
    │
    ├─ 次フェーズへ → 5.4 タスク分割フェーズへ
    │
    └─ 修正を指示 → 5.4 タスク分割フェーズへ
```

| 担当 | 作成/更新ファイル | 承認 |
|------|------------------|------|
| SM | `queue/dashboard.md`（Current Phase, Backlog Status, Agent Status） | - |
| Dev | 実装コード、テスト等 | - |
| Dev | `queue/reports/{task_id}.yaml` | - |

**ブロッカー発生時：**

```
[Dev] 実装中にブロッカー発生
    ↓
[Dev] queue/reports/{task_id}.yaml に status: blocked で報告
    ↓
[SM] ブロッカー内容を確認
    ↓
[SM] queue/dashboard.md の Blockers セクションに記録
    ↓
[SM] 解決策を検討（タスク再割当て / PO相談）
    ↓
（解決後）[SM] 新タスク発行 or 既存タスク更新
```

### 5.6. 検証・受入フェーズ（Verify/Accept）

PO 判断は **ACCEPT / REJECT / REVIEW_NEEDED** の 3 分岐の状態機械として扱う。Dev / SM が §2.4.3 のセルフチェックで `status: needs_review` に格下げした報告がある場合、SM は dashboard.md `## Notes` に記載した上で PO に send-keys で報告し、PO は REVIEW_NEEDED 分岐として判断する。

```
[PO] 検証開始を po_to_sm.yaml に記録（task_type: verify）
    ↓
[SM] queue/dashboard.md の Current Phase を更新（工程6 Verify/Accept）
    ↓
[SM] 計画（docs/）と仕様（README.md）に基づき成果物を検証
     ※ §2.4.3 の needs_review 報告があれば dashboard.md ## Notes に転記
    ↓
[SM] POに検証結果を報告（send-keys）→ 停止（PO 判断待ち）
    ↓
[PO] SMの報告と仕様（README.md）に基づき検証・判断
    ↓
    ├─ ACCEPT（問題なし）
    │      ↓
    │  [PO] Human に受入の承認を依頼
    │      ↓
    │  [Human] ★ 最終承認
    │      ↓
    │  [PO] Backlog更新を指示（po_to_sm.yaml: task_type: backlog_update）
    │      ↓
    │  [SM] README.md の Backlog を更新（Status: done）
    │      ↓
    │  [SM] POに完了を通知（send-keys）→ 停止（idle / 次 po_to_sm.yaml 待ち）
    │
    ├─ REJECT（問題あり）
    │      ↓
    │  [PO] Human に問題を報告
    │      ↓
    │  [Human] ★ 5.3 設計計画フェーズへ差し戻し
    │      ↓
    │  [PO] 再計画を指示（po_to_sm.yaml: task_type: plan）
    │      ↓
    │  [SM] Phase 3（5.3）へ遷移
    │
    └─ REVIEW_NEEDED（追加確認が必要 / needs_review 起因）
           ↓
       [PO] 追加確認内容を判断
           ↓
           ├─ 再検証で解消可能 → [PO] task_type: verify を再発行 → SM 再検証
           └─ 部分差し戻しが必要 → [PO] task_type: plan を発行 → Phase 3 へ
```

#### 5.6.1. PO 判断 → SM アクション対応表

| PO 判断 | 発行 task_type | SM の処理 | 完了後の SM 状態 |
|---------|---------------|----------|-----------------|
| ACCEPT | `backlog_update` | README.md の Backlog を `done` に更新し、PO に完了通知 | **idle**（次 `po_to_sm.yaml` を send-keys で待機） |
| REJECT | `plan`（Phase 3 差し戻し）| 計画再策定フロー（5.3）へ遷移 | Phase 3 進行中 |
| REVIEW_NEEDED | `verify`（再検証）または `plan`（部分差し戻し）| PO 指示に従い再検証または計画修正 | 発行された task_type に応じる |

`needs_review` のハンドリング詳細は §2.4.3 を参照。Dev / SM 双方が突合に失敗した場合は `needs_review` に格下げされ、本フェーズで PO の REVIEW_NEEDED 判断に接続される。

| 担当 | 作成/更新ファイル | 承認 |
|------|------------------|------|
| SM | `queue/dashboard.md`（Current Phase, Notes） | - |
| PO | `queue/po_to_sm.yaml` | - |
| SM | `README.md`（Backlog更新） | - |

### 5.7. 移行・運用フェーズ（Migration/Operation）

運用からのフィードバックを分析し、適切なフェーズへ振り分ける。

```
[Human] 運用からのフィードバックを伝える
    ↓
[PO] SMにフィードバックを伝達（po_to_sm.yaml）
    ↓
[SM] queue/dashboard.md の Current Phase を更新（工程7 Migration/Op）
    ↓
[SM] フィードバックを分析
    ↓
    ├─ 仕様更新が必要 → 5.2 企画・要件定義フェーズへ
    │
    └─ 仕様変更不要（バグ修正、調査等） → 5.4 タスク分割フェーズへ
```

| 担当 | 作成/更新ファイル | 承認 |
|------|------------------|------|
| PO | `queue/po_to_sm.yaml` | - |
| SM | `queue/dashboard.md`（Current Phase） | - |

### 5.8. 承認が必要なタイミング（まとめ）

| フェーズ | 承認対象 | 承認者 |
|---------|---------|--------|
| 5.1 原則決定 | `CONSTITUTION.md` | Human |
| 5.2 企画・要件定義 | `README.md` | Human |
| 5.3 設計計画 | 計画内容 | Human |
| 5.5 実装 | 成果物 | Human |
| 5.6 検証・受入 | 実装結果 | Human |

*注: 5.7 移行・運用フェーズは振り分けのみ。承認は振り分け先のフェーズで行う。*
