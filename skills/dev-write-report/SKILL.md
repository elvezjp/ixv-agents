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

### Step 4: skill_candidate を検討（毎回必須）

**全ての報告で必ず記入すること。**

```yaml
skill_candidate:
  found: false  # true/false 必須
  # found: true の場合、以下も記入
  name: null        # 例: "readme-improver"
  description: null  # 例: "README.mdを初心者向けに改善"
  reason: null       # 例: "同じパターンを3回実行した"
```

| 判断基準 | 該当したら `found: true` |
|---------|------------------------|
| 他プロジェクトでも使えそう | yes |
| 同じパターンを2回以上実行 | yes |
| 他のDevにも有用 | yes |
| 手順や知識が必要な作業 | yes |

**`skill_candidate` の記入を忘れた報告は不完全とみなされる。**

### Step 5: ファイルに書き込み

ファイルパス: `queue/reports/{task_id}.yaml`

```
例: queue/reports/TASK-20260201-010.yaml
```

**注意**: ファイル名は `task_id` を使用する。`dev{N}_report.yaml` ではない。

### Step 6: 書き込み後の検証

ファイルを読み返し、以下を確認する：

- [ ] `task_id` が正しい形式（`TASK-YYYYMMDD-###`）
- [ ] `status` が `done` / `blocked` / `needs_review` のいずれか
- [ ] `summary` が存在する
- [ ] `created_at`, `updated_at` が `date` コマンドで取得した値
- [ ] `skill_candidate.found` が `true` または `false`

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
skill_candidate:
  found: false
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
skill_candidate:
  found: false
```

### Example 3: 完了報告 + スキル化候補あり

```yaml
schema_version: "1.0"
created_at: "2026-02-01T16:00:00"
updated_at: "2026-02-01T16:00:00"
task_id: "TASK-20260201-012"
status: "done"
summary: "Wikiページ3枚（Home, Getting Started, Configuration）を作成完了。"
changes:
  - "Home.md: プロジェクト概要と目次を作成"
  - "getting-started.md: インストール手順と初期設定を作成"
  - "configuration.md: 設定項目の一覧と説明を作成"
artifacts:
  - "docs/wiki/Home.md"
  - "docs/wiki/getting-started.md"
  - "docs/wiki/configuration.md"
issues: []
skill_candidate:
  found: true
  name: "wiki-page-generator"
  description: "仕様書からWikiページのひな型を自動生成"
  reason: "同じ構成パターン（概要→手順→注意事項）を3回繰り返した"
```

## Validation Rules

| Field | Rule |
|-------|------|
| task_id | `TASK-YYYYMMDD-###` 形式（必須） |
| status | `done` / `blocked` / `needs_review`（必須） |
| summary | 200文字以内推奨（必須） |
| created_at, updated_at | `date` コマンドで取得（必須） |
| skill_candidate.found | `true` / `false`（必須） |
| ファイル名 | `queue/reports/{task_id}.yaml` |

## References

詳細なスキーマ定義は `references/report-yaml-schema.md` を参照。

## Notes

- このスキルは **Devロールのみ** が使用する
- `skill_candidate` は Spec.md 2.3.4 の拡張フィールドであり、全報告で必須
- ファイル名には必ず `task_id` を使用する（`dev{N}_report.yaml` は旧形式）
- タイムスタンプは必ず `date` コマンドで取得する（推測禁止）
- 報告書作成後は必ず `dev-notify-sm` スキルでSMに通知する
