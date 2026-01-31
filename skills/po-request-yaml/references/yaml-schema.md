# PO -> SM YAML Schema Reference

## Overview

このドキュメントは `queue/po_to_sm.yaml` のスキーマ定義を記載する。

## Field Definitions

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| schema_version | optional | string | スキーマバージョン。現在は `"1.0"` |
| created_at | optional | string | 作成日時 (ISO-8601 UTC) |
| updated_at | optional | string | 更新日時 (ISO-8601 UTC) |
| spec_ref | **required** | string | 仕様書への参照 |
| request_id | **required** | string | リクエストID |
| priority | **required** | string | 優先度 |
| summary | **required** | string | 要件サマリ |
| acceptance_criteria | **required** | string[] | 受入条件（1件以上） |
| constraints | optional | string[] | 制約条件 |
| notes | optional | string | 補足事項 |

## Field Details

### spec_ref

仕様書への参照パス。セクション指定も可能。

```yaml
# ファイル全体を参照
spec_ref: specs/current_spec.md

# 特定セクションを参照
spec_ref: specs/current_spec.md#section-2.2.3
```

### request_id

`REQ-YYYYMMDD-###` 形式のユニークID。

- `YYYYMMDD`: 作成日（例: 20260131）
- `###`: 3桁の連番（例: 001, 002, ...）

```yaml
request_id: "REQ-20260131-001"
```

### priority

| Value | Description |
|-------|-------------|
| P0 | 最優先。即時対応が必要 |
| P1 | 通常優先度。次スプリントで対応 |
| P2 | 低優先度。余裕があれば対応 |

### summary

要件の簡潔なサマリ。**120文字以内推奨**。

- 何を実現するかを一文で表現
- 技術的な詳細よりもビジネス価値を重視

### acceptance_criteria

受入条件のリスト。**最低1件必須**。

Good:
```yaml
acceptance_criteria:
  - "ユーザーがログインボタンをクリックすると認証画面が表示される"
  - "正しい認証情報でログインするとダッシュボードに遷移する"
```

Bad:
```yaml
acceptance_criteria:
  - "動くこと"  # 曖昧すぎる
```

### constraints

技術的・運用的な制約条件。任意。

```yaml
constraints:
  - "既存のAPIを変更しないこと"
  - "レスポンス時間は500ms以内"
  - "IE11はサポート対象外"
```

### notes

補足情報。背景、参考リンク、注意事項など。

## Complete Template

```yaml
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
updated_at: "YYYY-MM-DDTHH:MM:SSZ"
spec_ref: specs/current_spec.md
request_id: "REQ-YYYYMMDD-###"
priority: "P0"
summary: ""
acceptance_criteria:
  - ""
constraints:
  - ""
notes: ""
```

## Validation Checklist

- [ ] `request_id` が `REQ-YYYYMMDD-###` 形式である
- [ ] `priority` が P0, P1, P2 のいずれかである
- [ ] `summary` が120文字以内である
- [ ] `acceptance_criteria` が1件以上ある
- [ ] 各 `acceptance_criteria` がテスト可能な条件である
- [ ] `spec_ref` が存在するファイルを指している
- [ ] 日時が ISO-8601 UTC形式である
