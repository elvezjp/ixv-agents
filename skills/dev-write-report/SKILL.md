---
name: dev-write-report
description: |
  Spec.md 2.3.4 スキーマに準拠した queue/reports/{task_id}.yaml を生成する。
  タスク完了後の報告書作成に使用する。
  Use when: 「報告書作成」「レポート作成」「報告ファイル書き出し」「タスク完了報告」と言われた時。
metadata:
  author: IXV-Agents
  version: 1.0.0
  phase: "3, 5"
---

# Dev Write Report

タスク完了後の結果を Spec.md 2.3.4 スキーマに準拠した YAML ファイルとして `queue/reports/{task_id}.yaml` に書き出す。

## When to Use

- タスクが完了した時（`status: done`）
- タスクがブロックされた時（`status: blocked`）
- レビューが必要な時（`status: needs_review`）

## Instructions

### Step 1: タイムスタンプを取得

```bash
date "+%Y-%m-%dT%H:%M:%S"
```

**必須**: タイムスタンプは必ず `date` コマンドで取得する。推測しないこと。

### Step 2: status を決定

| status | 条件 |
|--------|------|
| `done` | definition_of_done の全項目を満たした |
| `blocked` | ブロッカーにより作業を継続できない |
| `needs_review` | 作業は完了したがレビューが必要 |

**注意**: `failed` は有効な status ではない（Spec.md 2.3.4 準拠）。

### Step 3: 報告 YAML を生成

Spec.md 2.3.4 スキーマに準拠した YAML を生成する：

```yaml
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SS"
updated_at: "YYYY-MM-DDTHH:MM:SS"
task_id: "TASK-YYYYMMDD-###"
status: "done"
summary: "200文字以内の結果概要"
changes:
  - "変更点1"
  - "変更点2"
artifacts:
  - "ファイルパス1"
  - "ファイルパス2"
issues:
  - "課題や不具合（あれば）"
```

**各フィールドの記載方針**:

| Field | 記載内容 |
|-------|---------|
| summary | 何をしたか、結果はどうだったかを簡潔に |
| changes | 具体的な変更点を箇条書き |
| artifacts | 作成・変更したファイルパスを列挙 |
| issues | 問題点、仕様との乖離、注意事項など |

### Step 4: ファイルに書き込み

ファイルパス: `queue/reports/{task_id}.yaml`

```
例: queue/reports/TASK-20260201-010.yaml
```

**注意**: ファイル名は `task_id` を使用する。`dev{N}_report.yaml` ではない。

### Step 5: 書き込み後の検証

ファイルを読み返し、以下を確認する：

- [ ] `task_id` が正しい形式（`TASK-YYYYMMDD-###`）
- [ ] `status` が `done` / `blocked` / `needs_review` のいずれか
- [ ] `summary` が存在する
- [ ] `created_at`, `updated_at` が `date` コマンドで取得した値

## Examples

### Example 1: 完了報告（status: done）

```yaml
schema_version: "1.0"
created_at: "2026-02-01T15:30:00"
updated_at: "2026-02-01T15:30:00"
task_id: "TASK-20260201-010"
status: "done"
summary: "認証APIエンドポイント（/auth/login, /auth/logout）の実装完了。全テストパス。"
changes:
  - "/auth/login エンドポイントを実装（POST、JWT返却）"
  - "/auth/logout エンドポイントを実装（トークン無効化）"
  - "ユニットテスト8件を作成"
artifacts:
  - "src/auth/api.ts"
  - "tests/auth/api.test.ts"
issues: []
```

### Example 2: ブロック報告（status: blocked）

```yaml
schema_version: "1.0"
created_at: "2026-02-01T14:45:00"
updated_at: "2026-02-01T14:45:00"
task_id: "TASK-20260201-011"
status: "blocked"
summary: "セッション管理の実装中にRedis接続エラーが発生。環境変数の設定が不足。"
changes:
  - "セッション管理の基本構造を実装"
artifacts:
  - "src/auth/session.ts（未完成）"
issues:
  - "Redis接続情報（REDIS_URL）が環境変数に設定されていない"
  - "接続設定の仕様がREADME.mdに記載されていない"
```

## Validation Rules

| Field | Rule |
|-------|------|
| task_id | `TASK-YYYYMMDD-###` 形式（必須） |
| status | `done` / `blocked` / `needs_review`（必須） |
| summary | 200文字以内推奨（必須） |
| created_at, updated_at | `date` コマンドで取得（必須） |
| ファイル名 | `queue/reports/{task_id}.yaml` |

## References

詳細なスキーマ定義は `references/report-yaml-schema.md` を参照。

## Notes

- このスキルは **Devロールのみ** が使用する
- ファイル名には必ず `task_id` を使用する（`dev{N}_report.yaml` は旧形式）
- タイムスタンプは必ず `date` コマンドで取得する（推測禁止）
- 報告書作成後は必ず `dev-notify-sm` スキルでSMに通知する
