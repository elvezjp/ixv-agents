---
name: po-check-spec
description: |
  README.md（仕様書）を確認し、ユーザーの要望が反映済みか判定する。
  Use when: 「仕様確認」「要望の反映確認」「spec check」「仕様に入ってる？」と言われた時。
  フェーズ2（企画・要件定義）の分岐判定として使用する。
metadata:
  author: IXV-Agents
  version: 1.0.0
  phase: "2"
---

# PO Spec Check

README.md（仕様書）を確認し、ユーザーの要望が反映済みか判定する。

## When to Use

- ユーザーが新しい要望を伝えた時
- 「仕様確認」「要望の反映確認」と言われた時
- ワークフロー フェーズ2（企画・要件定義フェーズ）の分岐判定時

## Instructions

### Step 1: 要望内容を確認

ユーザーの要望内容を明確にする。
不明確な場合は以下を質問：

| 項目 | 質問例 |
|------|--------|
| **何を実現したいか** | 「具体的にどのような動作を期待しますか？」 |
| **完了の定義** | 「どうなったらOKですか？」 |

### Step 2: README.mdを読み取り

`README.md` を読み取り、以下のセクションを確認：

- **## Goal** - 目的
- **## Scope** - 範囲
- **## Requirements** - 機能要件
- **## Acceptance Criteria** - 受入条件
- **## Backlog** - バックログ

### Step 3: 反映状況を判定

要望が以下のいずれかに該当するか確認：

**反映済みの判定基準**:
1. Requirements に該当する要件が記載されている
2. Backlog に関連するエントリがある（Status: ready/in_sprint）
3. Goal/Scope に包含されている

**未反映の判定基準**:
1. Requirements に該当する要件がない
2. Backlog に関連エントリがない
3. Scope の Non-Goals に該当する

### Step 4: 結果を報告

**反映済みの場合**:
```
仕様確認完了: 要望は仕様に反映済みです。

該当箇所:
- Requirements: {該当する要件}
- Backlog: {関連エントリ}

→ 次のステップ: フェーズ3 設計計画へ進んでください。
```

**未反映の場合**:
```
仕様確認完了: 要望は仕様に未反映です。

要望内容: {要望の要約}

→ 次のステップ:
  1. po-request-yaml スキル（task_type: spec_update）で仕様策定タスクを発行してください
  2. SMが README.md を更新した後、Human承認を得てください
```

**Non-Goalsに該当する場合**:
```
仕様確認完了: 要望は Non-Goals に該当します。

Non-Goals:
- {該当するNon-Goals項目}

→ 次のステップ:
  1. ユーザーに Non-Goals の理由を説明してください
  2. 必要に応じて Scope の変更を検討してください
```

## Examples

### Example 1: 反映済みの場合

**要望**: 「ユーザー認証機能が欲しい」

**README.md の内容**:
```markdown
## Requirements
- ユーザー認証（ログイン/ログアウト）
- セッション管理
```

**報告**:
```
仕様確認完了: 要望は仕様に反映済みです。

該当箇所:
- Requirements: ユーザー認証（ログイン/ログアウト）

→ 次のステップ: フェーズ3 設計計画へ進んでください。
```

### Example 2: 未反映の場合

**要望**: 「ダークモード対応したい」

**README.md の内容**: ダークモードに関する記載なし

**報告**:
```
仕様確認完了: 要望は仕様に未反映です。

要望内容: ダークモード対応

→ 次のステップ:
  1. po-request-yaml スキル（task_type: spec_update）で仕様策定タスクを発行してください
  2. SMが README.md を更新した後、Human承認を得てください
```

## References

詳細なチェックリストは `references/spec-checklist.md` を参照。

## Notes

- このスキルはPOロールのみが使用する
- README.md は唯一の仕様書（Single Source of Truth）
- 仕様の変更はHumanの最終承認が必要
