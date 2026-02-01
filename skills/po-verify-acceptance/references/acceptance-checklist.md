# 受入基準検証チェックリスト

## 検証前の準備

### 1. 対象の特定
- [ ] 検証対象のリクエストIDを確認
- [ ] dashboard.mdでステータスがin_sprintであることを確認

### 2. 必要ファイルの確認
- [ ] README.md が存在する
- [ ] queue/reports/{request_id}.yaml が存在する

## 検証プロセス

### Step 1: 受入基準の抽出

README.mdから受入基準を抽出：

```markdown
## Acceptance Criteria
- 基準1
- 基準2
- 基準3
```

**確認ポイント**:
- [ ] 全ての受入基準が具体的かつテスト可能である
- [ ] 曖昧な表現（「正しく動作する」など）がない

### Step 2: レポートの確認

queue/reports/{request_id}.yaml の構造：

```yaml
request_id: "REQ-YYYYMMDD-###"
status: "completed" | "partial" | "failed"
completed_at: "YYYY-MM-DDTHH:MM:SSZ"
results:
  - criteria: "受入基準の文言"
    status: "pass" | "fail"
    evidence: "確認方法・証跡"
notes: "補足事項"
```

**確認ポイント**:
- [ ] request_idが一致している
- [ ] statusが設定されている
- [ ] 全ての受入基準に対応するresultsがある
- [ ] 各resultにevidenceが記載されている

### Step 3: 基準照合

| チェック項目 | 確認内容 |
|------------|---------|
| 基準カバレッジ | 全ての受入基準がresultsに含まれているか |
| ステータス確認 | 各基準のpass/failが明確か |
| 証跡の妥当性 | evidenceが基準達成を証明しているか |

## 判定基準

### OK判定（受入可能）

以下の全てを満たす場合：

1. 全ての受入基準に対応するresultsがある
2. 全てのresultsがstatus: "pass"
3. 全てのresultsに有効なevidenceがある

### NG判定（要修正）

以下のいずれかに該当する場合：

1. 受入基準に対応するresultsがない
2. いずれかのresultsがstatus: "fail"
3. evidenceが不十分

### 検証不可

以下の場合：

1. queue/reports/{request_id}.yamlが存在しない
2. レポートのフォーマットが不正

## 証跡（Evidence）の種類

| 種類 | 例 |
|-----|---|
| 自動テスト | 「E2Eテスト auth.spec.ts 通過」 |
| 手動テスト | 「手動確認: ログイン→ダッシュボード遷移OK」 |
| コードレビュー | 「PR #123 でレビュー済み」 |
| ログ確認 | 「アクセスログで確認」 |
| スクリーンショット | 「screenshots/login-flow.png」 |

## 検証結果の記録

### OK時のアクション
1. Human承認を依頼
2. 承認後、Backlog更新（status: done）

### NG時のアクション
1. 未達成項目を特定
2. 修正タスクを発行（po-request-yaml task_type: bugfix）
3. 再実装後、再検証

## レポートYAMLテンプレート

Devが作成するレポートのテンプレート：

```yaml
request_id: "REQ-YYYYMMDD-###"
status: "completed"
completed_at: "YYYY-MM-DDTHH:MM:SSZ"
results:
  - criteria: "受入基準1"
    status: "pass"
    evidence: "確認方法"
  - criteria: "受入基準2"
    status: "pass"
    evidence: "確認方法"
notes: ""
```

## よくある問題と対処

| 問題 | 対処 |
|-----|------|
| レポートがない | SMに実装完了報告を確認 |
| 基準とresultsが対応しない | Devに再レポートを依頼 |
| evidenceが不明確 | 具体的な証跡を追記依頼 |
| 部分的に完了 | 完了分を受入、残りを新タスク化 |
