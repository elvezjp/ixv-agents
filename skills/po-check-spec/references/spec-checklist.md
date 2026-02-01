# 仕様確認チェックリスト

## README.md 確認セクション

### 1. Goal（目的）
- [ ] プロジェクトの目的が明確か
- [ ] 要望がGoalの範囲内か

### 2. Scope（範囲）
- [ ] 含める範囲に該当するか
- [ ] Non-Goals に該当しないか

### 3. Requirements（機能要件）
- [ ] 要望に対応する要件が記載されているか
- [ ] 要件の粒度は適切か

### 4. Acceptance Criteria（受入条件）
- [ ] 関連する受入条件があるか
- [ ] テスト観点が明確か

### 5. Constraints（制約）
- [ ] 要望が制約に抵触しないか
- [ ] 技術的制約を考慮しているか

### 6. Backlog
- [ ] 関連するバックログエントリがあるか
- [ ] ステータスは何か（ready/in_sprint/done）

## 反映状況の判定マトリクス

| Goalに含まれる | Requirementsにある | Backlogにある | 判定 |
|---------------|-------------------|--------------|------|
| Yes | Yes | Yes | 反映済み |
| Yes | Yes | No | 反映済み（Backlog登録推奨） |
| Yes | No | - | 未反映 |
| No | - | - | Non-Goals確認 |

## Non-Goals 該当時の対応

1. ユーザーにNon-Goalsの理由を説明
2. 以下のいずれかを選択：
   - 要望を取り下げる
   - Scopeの変更を検討する（PO判断）

## README.md テンプレート構造

```markdown
# Project Name

## Metadata
- Version: 0.1.0
- Last Updated: YYYY-MM-DD

## Goal
- 目的/達成したい価値

## Scope
- 含める範囲
- 含めない範囲（Non-Goals）

## Requirements
- 機能要件

## Acceptance Criteria
- 受入条件（テスト観点）

## Constraints
- 技術/運用/セキュリティ制約

## Backlog
| ID | Priority | Summary | Status |
|----|----------|---------|--------|
| REQ-... | P0 | ... | ready/in_sprint/done |

## Icebox
- {Future ideas not yet prioritized}
```
