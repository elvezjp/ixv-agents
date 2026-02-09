# SM -> Dev Task YAML Schema Reference（Dev読み取り用）

## Overview

このドキュメントは `queue/tasks/dev{N}.yaml` のスキーマ定義を記載する。
Spec.md 2.3.3 に準拠。Devがタスクを受領する際の検証に使用する。

## Field Definitions

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| schema_version | optional | string | スキーマバージョン。現在は `"1.0"` |
| created_at | optional | string | 作成日時 (ISO-8601) |
| updated_at | optional | string | 更新日時 (ISO-8601) |
| task_id | **required** | string | タスクID (`TASK-YYYYMMDD-###`) |
| spec_ref | **required** | string | 仕様書への参照 (`README.md`) |
| request_id | optional | string | 元リクエストID (`REQ-YYYYMMDD-###`) |
| assignee | **required** | string | 担当Dev (`dev1`〜`dev3`) |
| type | **required** | string | タスク種別 (`dev` / `doc`) |
| summary | **required** | string | タスク概要（140文字以内推奨） |
| definition_of_done | **required** | string[] | 完了条件（1件以上） |
| inputs | optional | string[] | 参照ファイルや前提 |
| outputs | optional | string[] | 期待成果物 |
| dependencies | optional | string[] | 依存タスク (`TASK-...`) |

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

### assignee

担当Devの識別子。自分の番号と一致することを確認する。

| Value | 対応ペイン |
|-------|----------|
| dev1 | ixv-agents:0.2 |
| dev2 | ixv-agents:0.3 |
| dev3 | ixv-agents:0.4 |

### type

タスクの種別。ペルソナ選択の判断材料となる。

| Value | Description |
|-------|-------------|
| dev | 実装タスク（コーディング、テスト、調査等） |
| doc | ドキュメント更新タスク |

### summary

タスクの簡潔な概要。**140文字以内推奨**。作業内容の全体像を把握する。

### definition_of_done

完了条件のリスト。**最低1件必須**。これが作業の合格基準となる。
各条件をすべて満たした時点でタスク完了（`status: done`）。

```yaml
definition_of_done:
  - "/auth/login エンドポイントが POST リクエストを受け付ける"
  - "正しい認証情報でトークンが返却される"
  - "ユニットテストがすべてパスする"
```

### inputs

タスク実行に必要な参照ファイルや前提条件。作業開始前に全て確認する。

```yaml
inputs:
  - "docs/auth-plan.md"
  - "README.md#requirements"
```

### outputs

タスク完了時に生成される成果物。これが報告書の `artifacts` に対応する。

```yaml
outputs:
  - "src/auth/api.ts"
  - "tests/auth/api.test.ts"
```

### dependencies

このタスクが依存する他のタスクID。依存タスクが未完了の場合は `status: blocked` で報告する。

```yaml
dependencies:
  - "TASK-20260201-001"
```

## Validation Checklist

- [ ] `task_id` が `TASK-YYYYMMDD-###` 形式である
- [ ] `spec_ref` が存在するファイルを指している
- [ ] `assignee` が自分のDev番号と一致している
- [ ] `type` が `dev` または `doc` である
- [ ] `summary` が存在する
- [ ] `definition_of_done` が1件以上ある
- [ ] `dependencies` がある場合、依存タスクが完了済みである
