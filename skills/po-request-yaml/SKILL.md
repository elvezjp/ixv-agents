---
name: po-request-yaml
description: |
  ユーザーの要望やPOの指示をSMへ伝達するためのqueue/po_to_sm.yamlを作成する。
  task_typeに応じて適切なYAMLを生成する。
  Use when: 「要望」「リクエスト」「タスク発行」「SMに指示」「機能追加」「バグ修正」「仕様策定」「計画策定」「実行指示」「Backlog更新」「フィードバック反映」と言われた時。
metadata:
  author: IXV-Agents
  version: 2.0.0
---

# PO Request YAML Generator

ユーザーの要望やPOの指示を受け取り、`queue/po_to_sm.yaml` を作成してSMに伝達する。

## When to Use

ユーザーが以下のようなリクエストをした時、このスキルを実行する：

- 「〜機能を追加してほしい」
- 「〜を修正して」
- 「仕様を更新して」
- 「計画を立てて」
- 「実行して」
- 「Backlogを更新して」
- 「フィードバックを反映して」

## Task Types

| task_type | 用途 | 対応フェーズ |
|-----------|------|-------------|
| constitution_update | 憲章更新タスク | 1 |
| spec_update | 仕様策定・更新タスク | 2, 7 |
| plan | 計画策定依頼 | 3 |
| execute | 実行指示 | 4 |
| backlog_update | Backlog更新指示 | 6 |
| feature | 機能追加（デフォルト） | - |
| bugfix | バグ修正 | - |

## フェーズ順序の確認（重要）

**タスク発行前に、現在のフェーズ状態を確認してください。**

### 確認手順

1. `po-check-constitution` でフェーズ1の完了を確認
2. `po-check-spec` でフェーズ2の完了を確認
3. 前フェーズが未完了なら、そのフェーズのタスクのみを発行

### 発行制限

| 現在の状態 | 発行可能なtask_type | 発行禁止 |
|-----------|-------------------|---------|
| フェーズ1未完了（憲章未記入） | constitution_update のみ | feature, spec_update, plan, execute 等 |
| フェーズ2未完了（仕様未反映） | spec_update のみ | feature, plan, execute 等 |
| フェーズ2完了 | 全てのtask_type | - |

### 禁止パターン

```yaml
# ダメな例: 憲章更新と機能追加を同時に発行
# → constitution_update のみを発行し、完了後に feature を発行すること

# 1回の実行で発行するのは1タスクのみ
# 前のタスクが完了（dashboard.mdでdone確認）してから次を発行
```

## Instructions

### Step 1: task_typeの判定

ユーザー入力やコンテキストから適切なtask_typeを判定する。

**判定基準**:

| ユーザー入力 | task_type |
|------------|-----------|
| 「憲章更新」「目的を記入」「constitution」 | constitution_update |
| 「仕様策定」「仕様更新」「READMEに追加」 | spec_update |
| 「計画を立てて」「設計して」「plan」 | plan |
| 「実行して」「開始して」「execute」 | execute |
| 「Backlog更新」「完了にして」「ステータス変更」 | backlog_update |
| 「バグ」「不具合」「動かない」 | bugfix |
| 「機能追加」「〜したい」「〜してほしい」 | feature |

### Step 2: 必要情報のヒアリング

task_typeに応じて必要な情報をヒアリングする。

**共通項目**:
| 項目 | 質問例 |
|------|--------|
| **何を実現したいか** | 「具体的にどのような動作を期待しますか？」 |
| **完了の定義** | 「どうなったらOKですか？」 |
| **優先度** | 「急ぎですか？（P0:最優先 / P1:通常 / P2:低）」 |

**task_type別の追加項目**:

| task_type | 追加ヒアリング |
|-----------|---------------|
| constitution_update | プロジェクトの目的・存在意義 |
| spec_update | 追加/変更する仕様の詳細 |
| plan | 対象範囲、段階的実行の必要性 |
| execute | 実行対象の計画、優先順位 |
| backlog_update | 対象ID、新ステータス |

### Step 3: request_idの採番

1. 既存の `queue/po_to_sm.yaml` を確認
2. 今日の日付で `REQ-YYYYMMDD-###` 形式のIDを採番
3. 同日に複数リクエストがある場合は連番をインクリメント

### Step 4: YAML生成

task_typeに応じたYAMLを生成する。

**共通フォーマット**:
```yaml
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
updated_at: "YYYY-MM-DDTHH:MM:SSZ"
spec_ref: README.md
request_id: "REQ-YYYYMMDD-###"
task_type: "{task_type}"
priority: "P1"
summary: "120文字以内の要件サマリ"
acceptance_criteria:
  - "完了条件1"
  - "完了条件2"
constraints:
  - "制約条件（任意）"
notes: "補足事項（任意）"
```

### Step 5: ファイル書き込み

生成したYAMLを `queue/po_to_sm.yaml` に書き込む。

## Task Type別 Examples

### constitution_update

```yaml
schema_version: "1.0"
created_at: "2026-02-01T10:00:00Z"
updated_at: "2026-02-01T10:00:00Z"
spec_ref: README.md
request_id: "REQ-20260201-001"
task_type: "constitution_update"
priority: "P0"
summary: "CONSTITUTION.mdの存在意義セクションを記入"
acceptance_criteria:
  - "## 1. 存在意義（Purpose）に具体的な目的が記載されている"
  - "テンプレート文言が置き換えられている"
constraints: []
notes: "目的: AIエージェントによる効率的なソフトウェア開発プロセスの実現"
```

### spec_update

```yaml
schema_version: "1.0"
created_at: "2026-02-01T11:00:00Z"
updated_at: "2026-02-01T11:00:00Z"
spec_ref: README.md
request_id: "REQ-20260201-002"
task_type: "spec_update"
priority: "P1"
summary: "README.mdにダークモード対応の要件を追加"
acceptance_criteria:
  - "Requirements セクションにダークモード対応が記載されている"
  - "Acceptance Criteria にテスト観点が追加されている"
  - "Backlog に REQ-20260201-002 がエントリされている"
constraints: []
notes: "ユーザー要望: ダークモードに切り替えられるようにしたい"
```

### plan

```yaml
schema_version: "1.0"
created_at: "2026-02-01T12:00:00Z"
updated_at: "2026-02-01T12:00:00Z"
spec_ref: README.md
request_id: "REQ-20260201-003"
task_type: "plan"
priority: "P1"
summary: "認証機能の実装計画を策定"
acceptance_criteria:
  - "段階的な実行計画が docs/ に作成されている"
  - "各段階の成果物と完了条件が明確である"
  - "依存関係が整理されている"
constraints:
  - "既存のセッション管理と互換性を保つこと"
notes: "OAuth2.0とJWT認証の両方を検討すること"
```

### execute

```yaml
schema_version: "1.0"
created_at: "2026-02-01T13:00:00Z"
updated_at: "2026-02-01T13:00:00Z"
spec_ref: README.md
request_id: "REQ-20260201-004"
task_type: "execute"
priority: "P0"
summary: "認証機能フェーズ1の実行を開始"
acceptance_criteria:
  - "タスクが tasks/dev{N}.yaml に分解されている"
  - "Devへの割り当てが完了している"
  - "dashboard.md が更新されている"
constraints: []
notes: "計画: docs/auth-plan.md を参照"
```

### backlog_update

```yaml
schema_version: "1.0"
created_at: "2026-02-01T14:00:00Z"
updated_at: "2026-02-01T14:00:00Z"
spec_ref: README.md
request_id: "REQ-20260201-005"
task_type: "backlog_update"
priority: "P1"
summary: "REQ-20260131-001 のステータスを done に更新"
acceptance_criteria:
  - "README.md の Backlog テーブルで REQ-20260131-001 が done になっている"
constraints: []
notes: "Human承認済み"
```

### feature

```yaml
schema_version: "1.0"
created_at: "2026-02-01T15:00:00Z"
updated_at: "2026-02-01T15:00:00Z"
spec_ref: README.md
request_id: "REQ-20260201-006"
task_type: "feature"
priority: "P1"
summary: "ダッシュボードにリアルタイム更新機能を追加"
acceptance_criteria:
  - "ファイル変更が5秒以内にUIに反映される"
  - "手動リロードが不要"
constraints: []
notes: ""
```

### bugfix

```yaml
schema_version: "1.0"
created_at: "2026-02-01T16:00:00Z"
updated_at: "2026-02-01T16:00:00Z"
spec_ref: README.md
request_id: "REQ-20260201-007"
task_type: "bugfix"
priority: "P0"
summary: "タスク一覧が表示されないバグの修正"
acceptance_criteria:
  - "queue/tasks/*.yaml の内容がUI上に表示される"
constraints: []
notes: "再現手順: localhost:3000 → Tasksタブ"
```

## Validation Rules

| Field | Rule |
|-------|------|
| request_id | `REQ-YYYYMMDD-###` 形式 |
| task_type | 定義されたタイプのいずれか |
| priority | P0 / P1 / P2 のいずれか |
| summary | 120文字以内推奨 |
| acceptance_criteria | 最低1件必須 |
| created_at, updated_at | ISO-8601 UTC形式 |

## Error Handling

| Issue | Action |
|-------|--------|
| task_typeが不明確 | ユーザーに確認、デフォルトは feature |
| 完了条件が不明確 | 「どうなったらOKですか？」と質問 |
| 優先度が不明 | P1をデフォルトとして提案 |
| summaryが長すぎる | 120文字以内に要約を提案 |

## References

詳細なスキーマ定義は `references/yaml-schema.md` を参照。

## Notes

- このスキルはPOロールのみが使用する
- YAMLの詳細なスキーマは `references/yaml-schema.md` を参照
- SMへの通知は roles/po.md のワークフローに従う
- **フェーズ順序厳守**: 前フェーズが未完了なら、そのフェーズのタスクのみを発行する
- **1回1タスク**: 複数のtask_typeを同時に発行しない
