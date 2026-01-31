---
name: po-request-yaml
description: |
  ユーザーからの要望・リクエストを受け取り、SMへ伝達するためのYAMLファイルを作成する。
  Use when user describes any feature request, bug fix, improvement, or task.
  Triggers on: "〜してほしい", "〜を追加", "〜を修正", "〜が欲しい", "〜を実装",
  "バグ", "機能追加", "改善", or any development request from user.
metadata:
  author: IXV-Agents
  version: 1.1.0
---

# PO Request YAML Generator

ユーザーの要望を受け取り、`queue/po_to_sm.yaml` を作成してSMに伝達する。

## When to Use

ユーザーが以下のようなリクエストをした時、このスキルを実行する：

- 「〜機能を追加してほしい」
- 「〜を修正して」
- 「〜が動かない」
- 「〜を改善したい」
- 「〜を実装して」
- その他、開発に関するあらゆる要望

## Instructions

### Step 1: 要望のヒアリング

ユーザーから以下の情報を収集する：

| 項目 | 質問例 |
|------|--------|
| **何を実現したいか** | 「具体的にどのような動作を期待しますか？」 |
| **完了の定義** | 「どうなったらOKですか？」 |
| **優先度** | 「急ぎですか？（P0:最優先 / P1:通常 / P2:低）」 |
| **制約条件**（任意） | 「何か制約はありますか？」 |

不足している情報があれば、ユーザーに質問して明確化する。

### Step 2: request_id の採番

1. 既存の `queue/po_to_sm.yaml` を確認
2. 今日の日付で `REQ-YYYYMMDD-###` 形式のIDを採番
3. 同日に複数リクエストがある場合は連番をインクリメント

### Step 3: YAML生成

以下のスキーマに従ってYAMLを生成：

```yaml
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
updated_at: "YYYY-MM-DDTHH:MM:SSZ"
spec_ref: specs/current_spec.md
request_id: "REQ-YYYYMMDD-###"
priority: "P1"
summary: "120文字以内の要件サマリ"
acceptance_criteria:
  - "完了条件1"
  - "完了条件2"
constraints:
  - "制約条件（任意）"
notes: "補足事項（任意）"
```

詳細なスキーマ定義は `references/yaml-schema.md` を参照。

### Step 4: ファイル書き込み

生成したYAMLを `queue/po_to_sm.yaml` に書き込む。

## Validation Rules

| Field | Rule |
|-------|------|
| request_id | `REQ-YYYYMMDD-###` 形式 |
| priority | P0 / P1 / P2 のいずれか |
| summary | 120文字以内推奨 |
| acceptance_criteria | 最低1件必須 |
| created_at, updated_at | ISO-8601 UTC形式 |

## Examples

### Example 1: 機能追加

**User**: 「ダッシュボードにリアルタイム更新機能を追加したい」

**PO**: 「どのくらいの頻度で更新されればOKですか？」

**User**: 「5秒以内に反映されればいい」

**Generated YAML**:
```yaml
schema_version: "1.0"
created_at: "2026-01-31T10:00:00Z"
updated_at: "2026-01-31T10:00:00Z"
spec_ref: specs/current_spec.md
request_id: "REQ-20260131-001"
priority: "P1"
summary: "ダッシュボードにリアルタイム更新機能を追加"
acceptance_criteria:
  - "ファイル変更が5秒以内にUIに反映される"
  - "手動リロードが不要"
constraints: []
notes: ""
```

### Example 2: バグ修正

**User**: 「タスク一覧が表示されない」

**Generated YAML**:
```yaml
schema_version: "1.0"
created_at: "2026-01-31T14:30:00Z"
updated_at: "2026-01-31T14:30:00Z"
spec_ref: specs/current_spec.md
request_id: "REQ-20260131-002"
priority: "P0"
summary: "タスク一覧が表示されないバグの修正"
acceptance_criteria:
  - "queue/tasks/*.yaml の内容がUI上に表示される"
constraints: []
notes: "再現手順: localhost:3000 → Tasksタブ"
```

## Error Handling

| Issue | Action |
|-------|--------|
| 完了条件が不明確 | 「どうなったらOKですか？」と質問 |
| 優先度が不明 | P1をデフォルトとして提案 |
| summaryが長すぎる | 120文字以内に要約を提案 |

## Notes

- このスキルはPOロールのみが使用する
- YAMLの詳細なスキーマは `references/yaml-schema.md` を参照
- SMへの通知は po.md のワークフローに従う
