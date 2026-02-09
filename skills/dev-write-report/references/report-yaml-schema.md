# Dev -> SM Report YAML Schema Reference

## Overview

このドキュメントは `queue/reports/{task_id}.yaml` のスキーマ定義を記載する。
Spec.md 2.3.4 に準拠。Devが報告書を生成する際に使用する。

## Field Definitions

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| schema_version | optional | string | スキーマバージョン。現在は `"1.0"` |
| created_at | optional | string | 作成日時 (ISO-8601) |
| updated_at | optional | string | 更新日時 (ISO-8601) |
| task_id | **required** | string | タスクID (`TASK-YYYYMMDD-###`) |
| status | **required** | string | `done` / `blocked` / `needs_review` |
| summary | **required** | string | 結果概要（200文字以内推奨） |
| changes | optional | string[] | 変更点 |
| artifacts | optional | string[] | 変更ファイル/成果物 |
| issues | optional | string[] | ブロッカーや不具合 |

## 拡張フィールド: skill_candidate

Spec.md 2.3.4 の基本スキーマに加え、以下の拡張フィールドを **毎回必ず** 記入する。

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| skill_candidate.found | **required** | boolean | スキル化候補の有無 (`true` / `false`) |
| skill_candidate.name | conditional | string | スキル名（`found: true` の場合） |
| skill_candidate.description | conditional | string | スキルの説明（`found: true` の場合） |
| skill_candidate.reason | conditional | string | スキル化の理由（`found: true` の場合） |

## Field Details

### task_id

対応するタスクの `TASK-YYYYMMDD-###` 形式のID。タスクYAMLの `task_id` と一致すること。

```yaml
task_id: "TASK-20260201-010"
```

### status

タスクの完了状態。

| Value | Description | 次のアクション |
|-------|-------------|--------------|
| `done` | 全 definition_of_done を満たした | dev-notify-sm でSMに通知 |
| `blocked` | ブロッカーにより続行不能 | issues にブロッカー詳細を記載 → dev-notify-sm |
| `needs_review` | 作業完了、レビュー必要 | dev-notify-sm でSMに通知 |

**注意**: `failed` は有効な値ではない。

### summary

結果の概要。**200文字以内推奨**。

- 何をしたか
- 結果はどうだったか
- 特記事項があるか

Good:
```yaml
summary: "認証APIエンドポイント（/auth/login, /auth/logout）の実装完了。テスト8件全パス。"
```

Bad:
```yaml
summary: "完了しました"  # 具体性がない
```

### changes

実施した変更の詳細。箇条書きで記載。

```yaml
changes:
  - "/auth/login エンドポイントを実装（POST、JWT返却）"
  - "/auth/logout エンドポイントを実装（トークン無効化）"
  - "ユニットテスト8件を作成"
```

### artifacts

作成・変更したファイルのパス。SMが成果物を確認する際に使用する。

```yaml
artifacts:
  - "src/auth/api.ts"
  - "tests/auth/api.test.ts"
```

### issues

問題点、ブロッカー、仕様との乖離など。`status: blocked` の場合は必ず記載する。

```yaml
issues:
  - "Redis接続情報（REDIS_URL）が環境変数に設定されていない"
  - "接続設定の仕様がREADME.mdに記載されていない"
```

### skill_candidate

スキル化候補の検討結果。**全報告で必須**。

```yaml
# 候補なしの場合
skill_candidate:
  found: false

# 候補ありの場合
skill_candidate:
  found: true
  name: "wiki-page-generator"
  description: "仕様書からWikiページのひな型を自動生成"
  reason: "同じ構成パターンを3回繰り返した"
```

## Complete Template

```yaml
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SS"
updated_at: "YYYY-MM-DDTHH:MM:SS"
task_id: "TASK-YYYYMMDD-###"
status: "done"
summary: ""
changes:
  - ""
artifacts:
  - ""
issues: []
skill_candidate:
  found: false
  name: null
  description: null
  reason: null
```

## Validation Checklist

- [ ] `task_id` が `TASK-YYYYMMDD-###` 形式である
- [ ] `task_id` がタスクYAMLの `task_id` と一致している
- [ ] `status` が `done` / `blocked` / `needs_review` のいずれかである
- [ ] `summary` が存在し、200文字以内である
- [ ] `status: blocked` の場合、`issues` にブロッカー詳細がある
- [ ] `created_at`, `updated_at` が `date` コマンドで取得した値である
- [ ] `skill_candidate.found` が `true` または `false` である
- [ ] `skill_candidate.found: true` の場合、`name`, `description`, `reason` が記入されている
- [ ] ファイル名が `queue/reports/{task_id}.yaml` である
