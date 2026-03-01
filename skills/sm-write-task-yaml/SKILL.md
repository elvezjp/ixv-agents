---
name: sm-write-task-yaml
description: |
  Spec.md 2.3.3 スキーマに準拠した queue/tasks/dev{N}.yaml を生成する。
  タスク分解の結果をDev向けYAMLファイルとして書き出す。
  Use when: 「タスク分解」「タスク作成」「Devに割り当て」「YAML作成」「tasks書き出し」と言われた時。
metadata:
  author: IXV-Agents
  version: 1.0.0
---

# SM Write Task YAML

タスク分解の結果を Spec.md 2.3.3 スキーマに準拠した YAML ファイルとして `queue/tasks/dev{N}.yaml` に書き出す。

## When to Use

- Phase 3: 調査・検討タスクをDevに依頼する時
- Phase 4: 実装タスクを分解してDevに割り当てる時
- Phase 5: 追加タスクが発生した時

## Instructions

### Step 1: task_id を採番

1. 既存の `queue/tasks/` 配下のYAMLファイルを確認
2. 今日の日付で `TASK-YYYYMMDD-###` 形式のIDを採番
3. 同日に複数タスクがある場合は連番をインクリメント

```bash
# タイムスタンプ取得（必須: 推測しないこと）
date "+%Y-%m-%dT%H:%M:%S"
```

### Step 2: Dev の空き状況を確認

タスク割り当て前に、各Devの空き状況を確認する。

```bash
# Dev1の状態確認
tmux capture-pane -t ixv-agents:0.2 -p | tail -20

# Dev2の状態確認
tmux capture-pane -t ixv-agents:0.3 -p | tail -20

# Dev3の状態確認
tmux capture-pane -t ixv-agents:0.4 -p | tail -20
```

**状態判定**:
| 表示 | 状態 |
|------|------|
| `❯ ` / `bypass permissions on` | idle（割り当て可能） |
| `thinking` / `Esc to interrupt` / `Effecting…` | busy（割り当て不可） |

### Step 3: タスク分解（5つの問い）

タスクをDevに振る前に、必ず以下を自問する：

| # | 問い | 考えるべきこと |
|---|------|---------------|
| 1 | **目的分析** | ユーザーが本当に欲しいものは何か？成功基準は何か？ |
| 2 | **タスク分解** | どう分解すれば最も効率的か？並列可能か？依存関係は？ |
| 3 | **人数決定** | 分割可能なら複数Devに分散。無意味な分割はしない |
| 4 | **観点設計** | レビューならペルソナ・シナリオ。開発なら専門性 |
| 5 | **リスク分析** | RACE-001の恐れは？Devの空き状況は？依存関係の順序は？ |

### Step 4: RACE-001 チェック

**同一ファイル書き込み禁止**:
```
❌ 禁止: Dev1 → output.md / Dev2 → output.md（競合）
✅ 正しい: Dev1 → output_1.md / Dev2 → output_2.md
```

| 条件 | 判断 |
|------|------|
| 成果物が複数ファイルに分かれる | 分割して並列投入 |
| 作業内容が独立している | 分割して並列投入 |
| 前工程の結果が次工程に必要 | 順次投入 |
| 同一ファイルへの書き込みが必要 | 1名で実行 |

### Step 5: YAML を生成

Spec.md 2.3.3 スキーマに準拠したYAMLを生成する。

```yaml
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
updated_at: "YYYY-MM-DDTHH:MM:SSZ"
task_id: "TASK-YYYYMMDD-###"
spec_ref: README.md
request_id: "REQ-YYYYMMDD-###"
assignee: "dev1"
type: "dev"
summary: "140文字以内のタスク概要"
definition_of_done:
  - "完了条件1"
  - "完了条件2"
inputs:
  - "参照ファイルや前提"
outputs:
  - "期待成果物"
dependencies:
  - "TASK-..."
```

### Step 6: ファイルに書き込み

各Devの専用ファイルに書き込む：
```
queue/tasks/dev1.yaml  ← Dev1専用
queue/tasks/dev2.yaml  ← Dev2専用
queue/tasks/dev3.yaml  ← Dev3専用
```

### Step 7: Dev に send-keys で通知

**【1回目】** メッセージを送る：
```bash
tmux send-keys -t ixv-agents:0.{N+1} 'queue/tasks/dev{N}.yaml にタスクがあります。確認して実行してください。'
```
※ Dev1=0.2, Dev2=0.3, Dev3=0.4

**【2回目】** Enterを送る：
```bash
tmux send-keys -t ixv-agents:0.{N+1} Enter
```

## Validation Rules

| Field | Rule |
|-------|------|
| task_id | `TASK-YYYYMMDD-###` 形式（必須） |
| spec_ref | `README.md` または `README.md#section`（必須） |
| assignee | `dev1` 〜 `dev8`（必須） |
| type | `dev` または `doc`（必須） |
| summary | 140文字以内推奨（必須） |
| definition_of_done | 1件以上必須 |
| created_at, updated_at | `date` コマンドで取得（推測禁止） |

## Examples

### Example 1: Phase 3 調査タスク

```yaml
schema_version: "1.0"
created_at: "2026-02-01T10:30:00Z"
updated_at: "2026-02-01T10:30:00Z"
task_id: "TASK-20260201-001"
spec_ref: README.md
request_id: "REQ-20260201-003"
assignee: "dev1"
type: "dev"
summary: "OAuth2.0とJWT認証の技術比較調査"
definition_of_done:
  - "OAuth2.0とJWTの比較表が作成されている"
  - "推奨方式とその理由が明記されている"
inputs:
  - "README.md の Requirements セクション"
outputs:
  - "queue/reports/TASK-20260201-001.yaml に調査結果を報告"
dependencies: []
```

### Example 2: Phase 4 並列実装タスク

**Dev1用** (`queue/tasks/dev1.yaml`):
```yaml
schema_version: "1.0"
created_at: "2026-02-01T14:00:00Z"
updated_at: "2026-02-01T14:00:00Z"
task_id: "TASK-20260201-010"
spec_ref: README.md
request_id: "REQ-20260201-004"
assignee: "dev1"
type: "dev"
summary: "認証APIエンドポイントの実装（/auth/login, /auth/logout）"
definition_of_done:
  - "/auth/login エンドポイントが正しく動作する"
  - "/auth/logout エンドポイントが正しく動作する"
  - "ユニットテストが作成されている"
inputs:
  - "docs/auth-plan.md"
outputs:
  - "src/auth/api.ts"
  - "tests/auth/api.test.ts"
dependencies: []
```

**Dev2用** (`queue/tasks/dev2.yaml`):
```yaml
schema_version: "1.0"
created_at: "2026-02-01T14:00:00Z"
updated_at: "2026-02-01T14:00:00Z"
task_id: "TASK-20260201-011"
spec_ref: README.md
request_id: "REQ-20260201-004"
assignee: "dev2"
type: "dev"
summary: "認証ミドルウェアとセッション管理の実装"
definition_of_done:
  - "認証ミドルウェアが正しく動作する"
  - "セッション管理が仕様通りに機能する"
  - "ユニットテストが作成されている"
inputs:
  - "docs/auth-plan.md"
outputs:
  - "src/auth/middleware.ts"
  - "tests/auth/middleware.test.ts"
dependencies: []
```

## References

詳細なスキーマ定義は `references/task-yaml-schema.md` を参照。

## Notes

- このスキルはSMロールのみが使用する
- POの指示をそのまま横流しせず、SMが自ら実行計画を設計すること
- 分割可能な作業は可能な限り多くのDevに分散して並列実行させる
- 「1名で済む」と安易に判断しない。分割の余地があるか必ず検討する
- RACE-001（同一ファイル書き込み禁止）を厳守する
- 1 Dev = 1 タスク（完了まで次のタスクを割り当てない）
