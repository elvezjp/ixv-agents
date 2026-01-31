---
name: po-request-yaml
description: |
  ユーザーの要望をPO -> SM用のYAMLファイル(queue/po_to_sm.yaml)に変換する。
  Use when user says "要望をYAMLに", "SMへリクエスト", "タスクを依頼",
  "po_to_sm.yamlを作成", "この機能を実装したい", or describes a feature request.
metadata:
  author: IXV-Agents
  version: 1.0.0
---

# PO Request YAML Generator

ユーザーの要望を `queue/po_to_sm.yaml` 形式に変換するスキル。

## Instructions

### Step 1: 要望のヒアリング

ユーザーから以下の情報を収集する：

1. **何を実現したいか** (summary)
2. **完了の定義** (acceptance_criteria)
3. **制約条件** (constraints) - 任意
4. **優先度** (priority: P0/P1/P2) - 不明なら確認

不足している情報があれば、ユーザーに質問して明確化する。

### Step 2: 仕様書の確認

1. `specs/current_spec.md` を読み、要望に関連するセクションを特定
2. `spec_ref` に適切な参照を設定（セクション指定可: `specs/current_spec.md#section-name`）
3. 仕様と矛盾する要望の場合は警告を出す

### Step 3: request_id の採番

1. 既存の `queue/po_to_sm.yaml` を確認
2. 今日の日付で `REQ-YYYYMMDD-###` 形式のIDを採番
3. 同日に複数リクエストがある場合は連番をインクリメント

### Step 4: YAML生成

以下のスキーマに従ってYAMLを生成：

```yaml
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
updated_at: "YYYY-MM-DDTHH:MM:SSZ"
spec_ref: specs/current_spec.md
request_id: "REQ-YYYYMMDD-###"
priority: "P0"
summary: "120文字以内の要件サマリ"
acceptance_criteria:
  - "条件1"
  - "条件2"
constraints:
  - "制約1"
notes: "補足事項"
```

詳細なスキーマ定義は `references/yaml-schema.md` を参照。

### Step 5: ファイル書き込み

生成したYAMLを `queue/po_to_sm.yaml` に書き込む。

**CRITICAL**: 書き込み前にユーザーに内容を確認させる。

## Validation Rules

| Field | Rule |
|-------|------|
| request_id | `REQ-YYYYMMDD-###` 形式 (例: REQ-20260131-001) |
| priority | P0, P1, P2 のいずれか |
| summary | 120文字以内推奨 |
| acceptance_criteria | 最低1件必須、具体的かつテスト可能な条件 |
| created_at, updated_at | ISO-8601 UTC形式 |

## Examples

### Example 1: 機能追加リクエスト

**User**: "ダッシュボードにリアルタイム更新機能を追加したい"

**Actions**:
1. 要望を確認 → リアルタイム更新機能
2. 受入条件を質問 → "どのタイミングで更新されればOK？"
3. 優先度を確認 → P1
4. YAMLを生成

**Generated YAML**:
```yaml
schema_version: "1.0"
created_at: "2026-01-31T10:00:00Z"
updated_at: "2026-01-31T10:00:00Z"
spec_ref: specs/current_spec.md#section-2.2.3
request_id: "REQ-20260131-001"
priority: "P1"
summary: "ダッシュボードにリアルタイム更新機能を追加"
acceptance_criteria:
  - "ファイル変更を検知して自動的にUIが更新される"
  - "手動リロードなしで最新状態が反映される"
constraints:
  - "ポーリング間隔は5秒以内"
notes: "WebSocket または SSE の利用を検討"
```

### Example 2: バグ修正リクエスト

**User**: "タスク一覧が表示されないバグを直して"

**Generated YAML**:
```yaml
schema_version: "1.0"
created_at: "2026-01-31T14:30:00Z"
updated_at: "2026-01-31T14:30:00Z"
spec_ref: specs/current_spec.md#section-2.2.4
request_id: "REQ-20260131-002"
priority: "P0"
summary: "タスク一覧が表示されないバグの修正"
acceptance_criteria:
  - "queue/tasks/*.yaml の内容がUI上に一覧表示される"
  - "タスクのstatus, assignee, summaryが正しく表示される"
constraints: []
notes: "再現手順: ブラウザでlocalhost:3000を開き、Tasksタブをクリック"
```

## Error Handling

| Issue | Action |
|-------|--------|
| 受入条件が不明確 | ユーザーに具体的な完了条件を質問 |
| 優先度が不明 | P1をデフォルトとして提案し確認 |
| 仕様との整合性問題 | 警告を出し、仕様更新が必要か確認 |
| summaryが長すぎる | 120文字以内に要約を提案 |

## Notes

- このスキルはPOロールのみが使用する
- 生成後、SMエージェントに通知するのはPOの責任
- 仕様変更が必要な場合は、先に `specs/current_spec.md` を更新すること
