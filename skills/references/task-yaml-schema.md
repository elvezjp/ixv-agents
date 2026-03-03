# SM -> Dev Task YAML Schema Reference

## Overview

このドキュメントは `queue/tasks/dev{N}.yaml` のスキーマ定義を記載する。
Spec.md 2.3.3 に準拠。SM（作成側）と Dev（読み取り側）の双方が参照する。

## Field Definitions

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| schema_version | optional | string | スキーマバージョン。現在は `"1.0"` |
| created_at | optional | string | 作成日時 (ISO-8601) |
| updated_at | optional | string | 更新日時 (ISO-8601) |
| task_id | **required** | string | タスクID |
| spec_ref | **required** | string | 仕様書への参照 |
| request_id | optional | string | 元リクエストID |
| assignee | **required** | string | 担当Dev |
| type | **required** | string | タスク種別 |
| summary | **required** | string | タスク概要 |
| definition_of_done | **required** | string[] | 完了条件（1件以上） |
| inputs | optional | string[] | 参照ファイルや前提 |
| outputs | optional | string[] | 期待成果物 |
| dependencies | optional | string[] | 依存タスク |

## Field Details

### task_id

`TASK-YYYYMMDD-###` 形式のユニークID。

- `YYYYMMDD`: 作成日（例: 20260201）
- `###`: 3桁の連番（例: 001, 002, ...）

```yaml
task_id: "TASK-20260201-001"
```

### spec_ref

仕様書への参照パス。セクション指定も可能。

```yaml
# ファイル全体を参照
spec_ref: README.md

# 特定セクションを参照
spec_ref: README.md#requirements
```

### request_id

元のPOリクエストとの紐付け。`REQ-YYYYMMDD-###` 形式。

```yaml
request_id: "REQ-20260201-001"
```

### assignee

担当Devの識別子。

| Value | 対応ペイン |
|-------|----------|
| dev1 | ixv-agents:0.2 |
| dev2 | ixv-agents:0.3 |
| dev3 | ixv-agents:0.4 |

**Dev側の確認**: 自分の番号と一致することを確認する。

### type

タスクの種別。Dev はこの値を基にペルソナを選択する。

| Value | Description |
|-------|-------------|
| dev | 実装タスク（コーディング、テスト、調査等） |
| doc | ドキュメント更新タスク |

### summary

タスクの簡潔な概要。**140文字以内推奨**。

- 何を実行するかを一文で表現
- 技術的な具体性を持たせる

Good:
```yaml
summary: "認証APIエンドポイント（/auth/login, /auth/logout）の実装"
```

Bad:
```yaml
summary: "認証を作る"  # 曖昧すぎる
```

### definition_of_done

完了条件のリスト。**最低1件必須**。テスト可能な条件を記載する。
Dev はこれを合格基準として使用し、全条件を満たした時点で `status: done` とする。

Good:
```yaml
definition_of_done:
  - "/auth/login エンドポイントが POST リクエストを受け付ける"
  - "正しい認証情報でトークンが返却される"
  - "ユニットテストがすべてパスする"
```

Bad:
```yaml
definition_of_done:
  - "動くこと"  # 曖昧すぎる
```

### inputs

タスク実行に必要な参照ファイルや前提条件。Dev は作業開始前に全て確認する。

```yaml
inputs:
  - "docs/auth-plan.md"
  - "README.md#requirements"
  - "既存の src/middleware/ ディレクトリ構成"
```

### outputs

タスク完了時に生成される成果物。Dev の報告書 `artifacts` に対応する。

```yaml
outputs:
  - "src/auth/api.ts"
  - "tests/auth/api.test.ts"
  - "queue/reports/TASK-20260201-001.yaml"
```

### dependencies

このタスクが依存する他のタスクID。依存タスクが完了してから開始する。
Dev は依存タスクが未完了の場合、`status: blocked` で報告する。

```yaml
dependencies:
  - "TASK-20260201-001"
  - "TASK-20260201-002"
```

## Complete Template

```yaml
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
updated_at: "YYYY-MM-DDTHH:MM:SSZ"
task_id: "TASK-YYYYMMDD-###"
spec_ref: README.md
request_id: "REQ-YYYYMMDD-###"
assignee: "dev1"
type: "dev"
summary: ""
definition_of_done:
  - ""
inputs:
  - ""
outputs:
  - ""
dependencies:
  - ""
```

## Validation Checklist

### SM（作成時）

- [ ] `task_id` が `TASK-YYYYMMDD-###` 形式である
- [ ] `spec_ref` が存在するファイルを指している
- [ ] `assignee` が `dev1` 〜 `dev3` のいずれかである
- [ ] `type` が `dev` または `doc` である
- [ ] `summary` が140文字以内である
- [ ] `definition_of_done` が1件以上ある
- [ ] 各 `definition_of_done` がテスト可能な条件である
- [ ] 日時が `date` コマンドで取得されている
- [ ] **RACE-001**: 同一ファイルを複数Devに書かせていない
- [ ] 依存タスクが存在する場合、`dependencies` に記載されている

### Dev（受領時）

- [ ] `task_id` が `TASK-YYYYMMDD-###` 形式である
- [ ] `spec_ref` が存在するファイルを指している
- [ ] `assignee` が自分のDev番号と一致している
- [ ] `type` が `dev` または `doc` である
- [ ] `summary` が存在する
- [ ] `definition_of_done` が1件以上ある
- [ ] `dependencies` がある場合、依存タスクが完了済みである
