---
name: dev-receive-task
description: |
  queue/tasks/dev{N}.yaml を読み取り、Spec.md 2.3.3 スキーマに基づきタスクを確認する。
  Devが起こされた際の最初のステップとして使用する。
  Use when: 「SMから起こされた」「タスク確認」「tasks/dev確認」「タスク受領」と言われた時。
metadata:
  author: IXV-Agents
  version: 1.0.0
  phase: "3, 5"
---

# Dev Receive Task

`queue/tasks/dev{N}.yaml` を読み取り、Spec.md 2.3.3 スキーマに基づいてタスク内容を確認し、作業に最適なペルソナを設定する。

## When to Use

- SMから send-keys で起こされた時（**最初に実行するスキル**）
- コンパクション復帰後にタスクを再確認する時

## Instructions

### Step 1: 自分の番号を確認

```bash
tmux display-message -p '#W'
```

| 出力 | Dev番号 | ペイン |
|------|--------|--------|
| dev1 | Dev1 | ixv-agents:0.2 |
| dev2 | Dev2 | ixv-agents:0.3 |
| dev3 | Dev3 | ixv-agents:0.4 |

### Step 2: タスクYAML を読み取り

自分専用の `queue/tasks/dev{N}.yaml` を読み取る。

```
queue/tasks/dev1.yaml  ← Dev1はこれだけ
queue/tasks/dev2.yaml  ← Dev2はこれだけ
queue/tasks/dev3.yaml  ← Dev3はこれだけ
```

**他のDevのファイルは読まないこと。**

### Step 3: フィールドを検証

以下の必須フィールドが全て存在するか確認する：

| Field | Required | 検証ルール |
|-------|----------|-----------|
| task_id | **required** | `TASK-YYYYMMDD-###` 形式 |
| spec_ref | **required** | `README.md` または `README.md#section` |
| assignee | **required** | 自分のDev番号（`dev1`〜`dev3`） |
| type | **required** | `dev` または `doc` |
| summary | **required** | 140文字以内推奨 |
| definition_of_done | **required** | 1件以上 |

**必須フィールドが欠けている場合**: SMに `status: blocked` で報告する。

### Step 4: タスク内容を解析

1. **summary** から作業の全体像を把握
2. **definition_of_done** を完了条件として明確に理解（これが合格基準）
3. **inputs** を参照して関連ファイルや前提を確認
4. **outputs** で期待される成果物を確認
5. **dependencies** があれば、依存タスクが完了済みか確認

### Step 5: ペルソナを設定

タスクの `type` と内容に基づき、最適なペルソナを選択する：

| type / 内容 | 推奨ペルソナ |
|-------------|------------|
| dev（コーディング） | シニアソフトウェアエンジニア |
| dev（テスト） | QAエンジニア |
| dev（インフラ・CI/CD） | SRE / DevOpsエンジニア |
| dev（UI/UX） | シニアUIデザイナー |
| dev（DB設計） | データベースエンジニア |
| dev（調査・分析） | データアナリスト |
| doc（技術文書） | テクニカルライター |
| doc（ビジネス文書） | ビジネスライター |

### Step 6: タスク受領を確認

以下の形式でタスク受領を確認する：

```
タスク受領完了:
- task_id: TASK-YYYYMMDD-###
- type: dev
- summary: {タスク概要}
- definition_of_done: {件数}件
- ペルソナ: {選択したペルソナ}

作業を開始します。
```

## Examples

### Example 1: Phase 5 実装タスク

**queue/tasks/dev1.yaml**:
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

**受領確認出力**:
```
タスク受領完了:
- task_id: TASK-20260201-010
- type: dev
- summary: 認証APIエンドポイントの実装（/auth/login, /auth/logout）
- definition_of_done: 3件
- ペルソナ: シニアソフトウェアエンジニア

作業を開始します。
```

### Example 2: Phase 3 調査タスク

**queue/tasks/dev2.yaml**:
```yaml
schema_version: "1.0"
created_at: "2026-02-01T10:30:00Z"
updated_at: "2026-02-01T10:30:00Z"
task_id: "TASK-20260201-001"
spec_ref: README.md
request_id: "REQ-20260201-003"
assignee: "dev2"
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

**受領確認出力**:
```
タスク受領完了:
- task_id: TASK-20260201-001
- type: dev
- summary: OAuth2.0とJWT認証の技術比較調査
- definition_of_done: 2件
- ペルソナ: データアナリスト

作業を開始します。
```

## Validation Rules

| Check | Rule |
|-------|------|
| task_id 形式 | `TASK-YYYYMMDD-###` |
| assignee 一致 | 自分のDev番号と一致 |
| definition_of_done | 1件以上存在 |
| 必須フィールド | task_id, spec_ref, assignee, type, summary, definition_of_done が全て存在 |
| type 値 | `dev` または `doc` |

## References

詳細なスキーマ定義は `../references/task-yaml-schema.md`（共有リファレンス）を参照。

## Notes

- このスキルは **Devロールのみ** が使用する
- 他のDevのファイル（`queue/tasks/dev{他のN}.yaml`）は絶対に読まない
- 必須フィールドが欠けている場合は、作業を開始せず `dev-write-report` で `status: blocked` として報告する
- ペルソナは作業品質に直結するため、タスク内容に最も適したものを選択する
