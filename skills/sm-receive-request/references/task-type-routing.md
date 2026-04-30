# Task Type Routing Reference

## Overview

`queue/po_to_sm.yaml` の `task_type` フィールドからフェーズとアクションを判定するための詳細ガイド。
SPEC.md §2.6 を実装するためのリファレンスとして、`sm-receive-request` スキルから参照する。

## 判定方式

`task_type` には2種類ある：

| 種類 | task_type | 判定方式 |
|------|-----------|---------|
| 直接指定型 | `constitution_update`, `spec_update`, `plan`, `execute`, `verify`, `backlog_update` | 直接マッピング表（§A） |
| 汎用型 | `feature`, `bugfix` | 決定木フロー（§B） |

## §A. 直接マッピング表（SPEC.md §2.6.1）

| task_type | Phase | Dashboard Current Phase 表記 | 次スキル | SM の主要アクション |
|-----------|-------|------------------------------|---------|-------------------|
| `constitution_update` | 1 | `工程1 Constitution — 原則決定` | sm-update-spec | CONSTITUTION.md 更新 |
| `spec_update` | 2 | `工程2 Specify — 企画・要件定義` | sm-update-spec | README.md 更新 |
| `plan` | 3 | `工程3 Plan — 設計計画` | sm-write-task-yaml / sm-update-spec | 計画策定 + 仕様詳細化 |
| `execute` | 4 | `工程4 Tasks — タスク分割` | sm-write-task-yaml | タスク分解 + Dev割り当て |
| `verify` | 6 | `工程6 Verify/Accept — 検証・受入` | - | 成果物検証 + PO報告 |
| `backlog_update` | 6 | `工程6 Verify/Accept — 検証・受入` | sm-update-spec | Backlog ステータス更新 |

## §B. feature / bugfix の決定木フロー（SPEC.md §2.6.2）

`feature` / `bugfix` は汎用的な task_type であり、コンテキストに応じてフェーズを判定する。
SM は受領時に以下の決定木を **上から順に評価** し、**最初にマッチした条件** のフェーズを採用する。

### 決定木

```
                  feature / bugfix を受領
                          │
                          ▼
            ┌─────────────────────────────┐
            │ 条件1: 要件が README.md に  │
            │        未記載か？            │
            └─────────────────────────────┘
                ├─ YES → Phase 2 (Specify) = spec_update 相当
                │
                └─ NO ─▼
            ┌─────────────────────────────┐
            │ 条件2: 設計計画（docs/）が   │
            │        未完了か？            │
            └─────────────────────────────┘
                ├─ YES → Phase 3 (Plan) = plan 相当
                │
                └─ NO ─▼
            ┌─────────────────────────────┐
            │ 条件3: 実装が未完了か？      │
            │ （成果物ファイル未作成）     │
            └─────────────────────────────┘
                ├─ YES → Phase 4 (Tasks) = execute 相当
                │
                └─ NO ─▼
            ┌─────────────────────────────┐
            │ 条件4: 検証が未完了か？      │
            └─────────────────────────────┘
                ├─ YES → Phase 6 (Verify) = verify 相当
                │
                └─ NO  → 既に完了済み、PO に確認
```

### 判定の優先順位

複数条件にマッチする場合は **より早いフェーズを優先** する。
これは「前段が未完了なら戻る」原則に基づく。

例: 要件は記載済みだが計画も実装も両方未完了の場合は、Phase 3 (Plan) を採用する（Phase 4 は飛ばさない）。

### 各条件の確認手段

| 条件 | 確認方法 | 判定 YES の意味 |
|------|---------|---------------|
| 1. 要件が README.md に未記載 | `grep -i "{summary のキーワード}" workspace/README.md` | ヒットなし = 未記載 |
| 2. 設計計画（docs/）未完了 | `ls workspace/docs/ \| grep -i "{キーワード}"` | 関連計画書なし = 未完了 |
| 3. 実装未完了 | `ls workspace/{outputs パス}` または計画書で言及される成果物の存在確認 | 成果物未作成 = 未完了 |
| 4. 検証未完了 | `grep -l "status: done" queue/reports/*.yaml` で done レポート確認、その後 acceptance_criteria の検証履歴を確認 | done あるが検証未済 = 未完了 |

確認手段は環境やプロジェクト構成により調整可能だが、**判定の順序と優先順位は固定** である。

## 判定例

### 例1: 新規機能（仕様未反映）

```yaml
task_type: feature
summary: "ダークモード切り替え機能の追加"
acceptance_criteria:
  - "設定画面でダークモードに切り替えられる"
```

**判定フロー**:
1. `grep -i "ダークモード" workspace/README.md` → ヒットなし
2. → **Phase 2 (Specify)** と判定、`spec_update` 相当で処理

### 例2: バグ修正（仕様・計画ありで実装が動作不良）

```yaml
task_type: bugfix
summary: "タスク一覧が表示されないバグの修正"
```

**判定フロー**:
1. README.md にタスク一覧機能の記載あり → 条件1 NO
2. docs/ に該当機能の計画書あり → 条件2 NO
3. 実装ファイルは存在するが動作不良（バグ） → 条件3 YES
4. → **Phase 4 (Tasks)** と判定、`execute` 相当で処理

### 例3: 検証フェーズの差し戻し

```yaml
task_type: bugfix
summary: "認証機能の検証で発見した不具合の修正"
```

**判定フロー**:
1. 認証機能は仕様にあり → 条件1 NO
2. 計画書あり → 条件2 NO
3. 実装済み（done レポートあり） → 条件3 NO
4. 検証中に不具合発見 = 検証未完了 → 条件4 YES
5. → **Phase 6 (Verify)** ではなく、修正が必要なため再度 **Phase 4 (Tasks)** に戻すと判断（PO に確認）

> Note: 例3のような微妙なケースでは、SM は判定結果と理由を PO に send-keys で報告し、PO の判断を仰ぐこと。

## Phase 3 (Plan) 複雑さ判定フロー

`plan` または決定木で Phase 3 と判定された場合、SM はさらに要件の複雑さを判定する。

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

`po_to_sm.yaml` に定義外の task_type が記載されている場合：

1. `dashboard.md` の `## Notes` セクションに記載
2. PO に確認を求める（send-keys）
3. 確認が取れるまで処理を保留

### 必須フィールドの欠落

| 欠落フィールド | アクション |
|--------------|-----------|
| `task_type` | PO に確認（send-keys） |
| `request_id` | PO に確認（send-keys） |
| `summary` | PO に確認（send-keys） |
| `acceptance_criteria` | PO に確認（send-keys、空配列も含む） |
| `priority` | P1 をデフォルトとして処理、`dashboard.md` の `## Notes` に注記 |

詳細は `sm-receive-request/SKILL.md` の Step 1.5 を参照。

### コンパクション復帰時

1. `queue/po_to_sm.yaml` を読み取る
2. 最新の未完了タスクを特定する
3. `queue/dashboard.md` と照合して現在のフェーズを確認
4. 中断した地点からワークフローを再開

## 関連仕様

- SPEC.md §2.6.1（直接マッピング）
- SPEC.md §2.6.2（feature/bugfix 決定木）
- SPEC.md §2.4.4（必須フィールド欠落時の挙動）
- skills/sm-receive-request/SKILL.md（実行スキル）
