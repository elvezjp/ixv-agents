# Task Type Routing Reference

## Overview

`queue/po_to_sm.yaml` の `task_type` フィールドからフェーズとアクションを判定するための詳細ガイド。

## Routing Table

| task_type | Phase | Dashboard Current Phase 表記 | 次スキル | SM の主要アクション |
|-----------|-------|------------------------------|---------|-------------------|
| constitution_update | 1 | `工程1 Constitution — 原則決定` | sm-update-spec | CONSTITUTION.md 更新 |
| spec_update | 2 | `工程2 Specify — 企画・要件定義` | sm-update-spec | README.md 更新 |
| plan | 3 | `工程3 Plan — 設計計画` | sm-write-task-yaml / sm-update-spec | 計画策定 + 仕様詳細化 |
| execute | 4 | `工程4 Tasks — タスク分割` | sm-write-task-yaml | タスク分解 + Dev割り当て |
| verify | 6 | `工程6 Verify/Accept — 検証・受入` | - | 成果物検証 + PO報告 |
| backlog_update | 6 | `工程6 Verify/Accept — 検証・受入` | sm-update-spec | Backlog ステータス更新 |
| feature | - | フェーズ判定結果に依存 | varies | POの意図を解釈 |
| bugfix | - | 通常 `工程4 Tasks — タスク分割` | sm-write-task-yaml | バグ修正タスク分解 |

## Phase 3 (Plan) 複雑さ判定フロー

```
要件を確認
  ↓
単純な要件か？
  ├─ YES → SM が直接計画を策定
  │         → docs/ に計画書作成
  │         → sm-update-spec で README.md 詳細化
  │         → PO に通知
  │
  └─ NO  → sm-write-task-yaml で調査タスクを Dev に依頼
            → 停止（Dev 完了待ち）
            → Dev 完了報告後、調査結果を踏まえて計画策定
            → docs/ に計画書作成
            → sm-update-spec で README.md 詳細化
            → PO に通知
```

### 複雑さの判断基準

| 条件 | 判定 |
|------|------|
| 要件が明確で技術的に既知 | 単純 |
| 要件に不明点があり調査が必要 | 複雑 |
| 複数の技術選択肢の比較が必要 | 複雑 |
| 既存システムへの影響調査が必要 | 複雑 |
| 類似の実装経験がなく検証が必要 | 複雑 |

## feature/bugfix のフェーズ判定

`feature` と `bugfix` は汎用的な task_type であり、コンテキストに応じてフェーズを判定する。

| 状況 | 判定フェーズ |
|------|------------|
| 仕様に未反映の新機能 | Phase 2（Specify）→ spec_update として扱う |
| 仕様に反映済みだが計画未策定 | Phase 3（Plan）→ plan として扱う |
| 計画策定済み、未実行 | Phase 4（Tasks）→ execute として扱う |
| バグ修正（仕様変更不要） | Phase 4（Tasks）→ execute として扱う |

## Dashboard Current Phase 更新フォーマット

```markdown
## Current Phase
> **工程{N} {EnglishName}** — {日本語説明}
```

**例**:
```markdown
## Current Phase
> **工程1 Constitution** — 原則決定
```

```markdown
## Current Phase
> **工程4 Tasks** — タスク分割
```

## エッジケース

### 不明な task_type

po_to_sm.yaml に定義外の task_type が記載されている場合：

1. dashboard.md の「要対応」セクションに記載
2. PO に確認を求める（send-keys）
3. 確認が取れるまで処理を保留

### 必須フィールドの欠落

| 欠落フィールド | アクション |
|--------------|-----------|
| task_type | PO に確認（send-keys） |
| request_id | PO に確認（send-keys） |
| summary | PO に確認（send-keys） |
| acceptance_criteria | PO に確認（send-keys） |
| priority | P1 をデフォルトとして処理、dashboard に注記 |

### コンパクション復帰時

1. `queue/po_to_sm.yaml` を読み取る
2. 最新の未完了タスクを特定する
3. `queue/dashboard.md` と照合して現在のフェーズを確認
4. 中断した地点からワークフローを再開
