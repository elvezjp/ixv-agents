---
name: po-verify-acceptance
description: |
  README.mdの受入基準（Acceptance Criteria）とqueue/reports/*.yamlを比較し、
  実装結果が基準を満たしているか検証する。
  Use when: 「受入確認」「検証」「acceptance」「完了確認」「受入テスト」と言われた時。
  フェーズ5.6（検証・受入フェーズ）で使用する。
metadata:
  author: IXV-Agents
  version: 1.0.0
  phase: "5.6"
---

# PO Verify Acceptance

README.mdの受入基準（Acceptance Criteria）とqueue/reports/*.yamlを比較し、実装結果が基準を満たしているか検証する。

## When to Use

- 実装完了後の検証時
- 「受入確認」「検証」「acceptance」と言われた時
- ワークフロー5.6（検証・受入フェーズ）時

## Instructions

### Step 1: 対象リクエストの特定

検証対象のリクエストIDを特定する。

1. `queue/dashboard.md` を確認し、status: in_sprint のエントリを取得
2. または、ユーザーから対象リクエストIDを確認

### Step 2: 受入基準の取得

`README.md` から対象リクエストに関連する受入基準を取得：

1. **Acceptance Criteria** セクションを確認
2. 対象リクエストに関連する項目を抽出

### Step 3: 実装レポートの取得

`queue/reports/` ディレクトリから対象リクエストのレポートを取得：

```
queue/reports/
└── {request_id}.yaml
```

**レポートYAMLの構造**:
```yaml
request_id: "REQ-YYYYMMDD-###"
status: "completed" | "partial" | "failed"
completed_at: "YYYY-MM-DDTHH:MM:SSZ"
results:
  - criteria: "受入基準1"
    status: "pass" | "fail"
    evidence: "確認方法・証跡"
  - criteria: "受入基準2"
    status: "pass" | "fail"
    evidence: "確認方法・証跡"
notes: "補足事項"
```

### Step 4: 基準との照合

各受入基準に対して、レポートの結果を照合：

| 受入基準 | レポート結果 | 判定 |
|---------|-------------|------|
| 基準A | pass | OK |
| 基準B | fail | NG |
| 基準C | (未記載) | 未確認 |

### Step 5: 検証結果の報告

**全基準を満たしている場合**:
```
検証完了: 全ての受入基準を満たしています。

リクエストID: {request_id}
検証結果: OK (N/N 基準達成)

| 受入基準 | 結果 | 証跡 |
|---------|------|------|
| 基準A | OK | {evidence} |
| 基準B | OK | {evidence} |

→ 次のステップ:
  1. Human承認を得てください
  2. 承認後、po-request-yaml（task_type: backlog_update）でBacklog更新を指示
```

**基準を満たさない場合**:
```
検証完了: 一部の受入基準を満たしていません。

リクエストID: {request_id}
検証結果: NG (M/N 基準達成)

| 受入基準 | 結果 | 備考 |
|---------|------|------|
| 基準A | OK | {evidence} |
| 基準B | NG | {reason} |

→ 次のステップ:
  1. 未達成項目について修正タスクを発行してください
  2. po-request-yaml（task_type: bugfix）を使用
```

**レポートが存在しない場合**:
```
検証不可: 実装レポートが見つかりません。

リクエストID: {request_id}

→ 次のステップ:
  1. SMに実装完了報告を確認してください
  2. queue/reports/{request_id}.yaml の作成を依頼
```

## Examples

### Example 1: 全基準達成

**README.md の Acceptance Criteria**:
```markdown
## Acceptance Criteria
- ログインボタンをクリックすると認証画面が表示される
- 正しい認証情報でログインするとダッシュボードに遷移する
```

**queue/reports/REQ-20260201-001.yaml**:
```yaml
request_id: "REQ-20260201-001"
status: "completed"
completed_at: "2026-02-01T15:00:00Z"
results:
  - criteria: "ログインボタンをクリックすると認証画面が表示される"
    status: "pass"
    evidence: "E2Eテスト auth.spec.ts 通過"
  - criteria: "正しい認証情報でログインするとダッシュボードに遷移する"
    status: "pass"
    evidence: "E2Eテスト auth.spec.ts 通過"
notes: ""
```

**報告**:
```
検証完了: 全ての受入基準を満たしています。

リクエストID: REQ-20260201-001
検証結果: OK (2/2 基準達成)

| 受入基準 | 結果 | 証跡 |
|---------|------|------|
| ログインボタンをクリックすると認証画面が表示される | OK | E2Eテスト auth.spec.ts 通過 |
| 正しい認証情報でログインするとダッシュボードに遷移する | OK | E2Eテスト auth.spec.ts 通過 |

→ 次のステップ:
  1. Human承認を得てください
  2. 承認後、po-request-yaml（task_type: backlog_update）でBacklog更新を指示
```

### Example 2: 一部基準未達成

**報告**:
```
検証完了: 一部の受入基準を満たしていません。

リクエストID: REQ-20260201-002
検証結果: NG (1/2 基準達成)

| 受入基準 | 結果 | 備考 |
|---------|------|------|
| ダークモード切替ボタンが表示される | OK | UIテスト通過 |
| 設定がlocalStorageに保存される | NG | テスト失敗 |

→ 次のステップ:
  1. 未達成項目について修正タスクを発行してください
  2. po-request-yaml（task_type: bugfix）を使用
```

## Validation Checklist

検証時の確認項目：

- [ ] 対象リクエストIDが特定されている
- [ ] README.mdのAcceptance Criteriaが取得できている
- [ ] queue/reports/{request_id}.yamlが存在する
- [ ] 全ての受入基準に対してresultsがある
- [ ] 各resultsにevidenceが記載されている

## References

詳細なチェックリストは `references/acceptance-checklist.md` を参照。

## Notes

- このスキルはPOロールのみが使用する
- 検証結果の最終判断はHumanが行う
- 受入基準を満たさない場合は修正タスクを発行する
