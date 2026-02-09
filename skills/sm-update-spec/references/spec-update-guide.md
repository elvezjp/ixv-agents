# Spec Update Guide

## Overview

SMがフェーズに応じて CONSTITUTION.md / README.md を更新するための詳細ガイド。

## CONSTITUTION.md 構造

```markdown
# プロジェクト憲章（Constitution）

## 1. 存在意義（Purpose）        ← Phase 1 で更新
- [目的を記入]

## 2. 基本原則（4つの原則）
1. 仕様は「生きたドキュメント」である
2. 仕様は「信頼できる唯一の情報源」とする
3. 仕様は「変更と反復が前提」とする
4. AIでコストを抑えて実現する（人間が最終判断）

## 3. 変更禁止の範囲（非交渉事項）
- この憲章は例外的事情を除き変更しない
- 変更する場合はPOが指示し、SMが実行、人間（ユーザー）が最終承認

## 4. ガバナンスと責任
- 最終判断：プロダクトオーナー（PO）
- 運用監督：スクラムマスター（SM）
- 実行責任：デベロッパー（Dev）

## 5. 合意形成と承認
- 指示はPOがqueue/po_to_sm.yamlで発行
- 決定事項はqueue/dashboard.mdに記録
- 最終承認は人間（ユーザー）が行う

## 6. セキュリティと品質
- 仕様とコードの整合性を常に確認
- AI出力は必ず人間がレビュー
```

### Phase 1: 存在意義の更新手順

1. `## 1. 存在意義（Purpose）` セクションを特定
2. テンプレート文言/プレースホルダーを削除
3. po_to_sm.yaml の情報（notes, summary）に基づき具体的な目的を記入
4. **他のセクション（## 2〜6）は変更しない**

**未記入判定パターン**:
| パターン | 例 |
|---------|-----|
| テンプレート文言 | 「このプロジェクトが存在する理由を明記する」 |
| TODO系 | 「TODO」「TBD」「要記入」 |
| プレースホルダー | `{purpose}`, `[目的を記入]`, `___` |
| 空セクション | 見出しのみで内容なし |

## README.md 構造

```markdown
# Project Name

この`README.md`は、このプロジェクトにおける **唯一の仕様（Single Source of Truth）** です。

## 仕様の扱い
- **優先順位**: `CONSTITUTION.md` → `README.md` → `PROCESS.md` → `AGENTS.md` → `roles/*`

## Goal                          ← Phase 2 で追加・修正
- 目的/達成したい価値

## Scope                         ← Phase 2 で追加・修正
- 含める範囲
- 含めない範囲（Non-Goals）

## Requirements                  ← Phase 2, 3 で追加・詳細化
- 機能要件

## Acceptance Criteria            ← Phase 2, 3 で追加・詳細化
- 受入条件（テスト観点）

## Constraints                   ← Phase 2, 3 で追加
- 技術/運用/セキュリティ制約

## Backlog                       ← Phase 2 でエントリ追加, Phase 6 でステータス更新
| ID | Priority | Summary | Status |
|----|----------|---------|--------|
| REQ-... | P0 | ... | ready/in_sprint/done |

## Workspace Structure
(変更しない)

## References
(変更しない)
```

### Phase 2: 仕様策定の更新手順

1. po_to_sm.yaml の summary / acceptance_criteria / constraints / notes を確認
2. 以下のセクションを更新:

| セクション | 更新内容 | 注意点 |
|-----------|---------|--------|
| Goal | 新しい目的・価値の追加 | 既存の Goal を上書きしない |
| Scope | 範囲の追加、Non-Goals の明記 | 明示的に除外するものを記載 |
| Requirements | 機能要件の追加 | 箇条書きで具体的に |
| Acceptance Criteria | テスト可能な受入条件 | 曖昧な条件は避ける |
| Constraints | 技術/運用制約 | 必要な場合のみ |
| Backlog | 新規エントリ追加 | Status: `ready` |

3. Backlog テーブルに新規エントリを追加

### Phase 3: 仕様詳細化の更新手順

1. docs/ の計画書を読み取り
2. 計画内容に基づき、以下を具体化:
   - Requirements の粒度を上げる（例: 「認証機能」→「OAuth2.0ベースのログイン/ログアウト」）
   - Acceptance Criteria を具体化（例: 「認証できる」→「正しい認証情報でトークンが返却される」）
   - Constraints を追加（例: 「既存のセッション管理と互換性を保つこと」）
3. **注意**: 計画書は補助資料。重要な決定は README.md に反映すること

### Phase 6: Backlog ステータス更新の手順

1. po_to_sm.yaml の request_id を確認
2. README.md の Backlog テーブルで該当行を特定
3. Status を `done` に変更

**Status 遷移**:
```
ready → in_sprint → done
```

| Status | 意味 |
|--------|------|
| ready | 実装準備完了 |
| in_sprint | 現在のスプリントで実装中 |
| done | 完了（Human承認済み） |

## 更新時のチェックリスト

### 共通
- [ ] 更新対象のファイルを読み取ってから編集している
- [ ] セクション構造（見出し）を変更していない
- [ ] 既存の内容を不用意に削除していない
- [ ] 仕様の一貫性を確認している（Requirements ↔ Acceptance Criteria）

### Phase 1 固有
- [ ] `## 1. 存在意義（Purpose）` のみを更新している
- [ ] テンプレート文言が具体的な目的に置換されている
- [ ] 他のセクション（## 2〜6）を変更していない

### Phase 2 固有
- [ ] po_to_sm.yaml の acceptance_criteria が README.md に反映されている
- [ ] Backlog テーブルに新規エントリが追加されている
- [ ] Backlog の Status が `ready` になっている

### Phase 3 固有
- [ ] 計画書（docs/）の内容が README.md に反映されている
- [ ] Requirements が具体化されている
- [ ] Acceptance Criteria がテスト可能な条件になっている

### Phase 6 固有
- [ ] 正しい request_id の Status を更新している
- [ ] Status が `done` に変更されている
- [ ] Human 承認済みであることを確認している
