# Report Processing Guide

## Overview

Devからの報告（`queue/reports/*.yaml`）を処理するための詳細ガイド。
SPEC.md 2.3.4 に準拠。

## Report YAML Schema (SPEC.md 2.3.4)

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| schema_version | optional | string | `"1.0"` |
| created_at | optional | string | 作成日時 (ISO-8601 UTC) |
| updated_at | optional | string | 更新日時 (ISO-8601 UTC) |
| task_id | **required** | string | タスクID (`TASK-YYYYMMDD-###`) |
| status | **required** | string | `done` / `blocked` / `needs_review` |
| summary | **required** | string | 結果概要（200文字以内推奨） |
| changes | optional | string[] | 変更点 |
| artifacts | optional | string[] | 変更ファイル/成果物 |
| issues | optional | string[] | ブロッカーや不具合 |

## Status別処理フロー

### status: done

タスクが正常に完了した場合。

1. dashboard.md の成果セクションにタスクを追加
2. Agent Status を `idle` に更新
3. 全タスク完了の場合、PO に完了通知

**dashboard.md 更新例**:
```markdown
## ✅ 本日の成果

| 時刻 | タスク | 担当 | 内容 |
|------|--------|------|------|
| 15:30 | TASK-20260201-010 | Dev1 | 認証APIエンドポイントの実装完了 |
```

### status: blocked

タスクがブロッカーにより停止した場合。

1. dashboard.md の Blockers セクションにブロッカーを記載
2. Agent Status を `blocked` に更新
3. 解決策を検討：
   - SM が解決可能 → 新タスク発行 or 既存タスク更新
   - PO の判断が必要 → PO に相談（send-keys + dashboard.md の要対応セクション）

**dashboard.md 更新例**:
```markdown
## Blockers
- [ ] Redis接続情報が環境変数に設定されていない (Owner: SM / TASK-20260201-011)
```

**対応検討**:
| ブロッカー種別 | SM の対応 |
|--------------|----------|
| 技術的問題（環境設定等） | 別のDevに修正タスクを発行 |
| 仕様の不明点 | PO に確認を依頼 |
| 外部依存（API等） | dashboard.md に記録、PO に報告 |
| 他タスクへの依存 | 依存タスクの完了を待つ |

### status: needs_review

タスクは完了したが、レビューが必要な場合。

1. dashboard.md の Agent Status を `needs_review` に更新
2. レビュー対象の成果物を確認
3. PO に報告（send-keys）

## Dashboard 照合ロジック

各報告ファイルについて、以下の手順で照合する：

```
報告ファイルを読み取り
  ↓
task_id を取得
  ↓
dashboard.md の Backlog Status / Agent Status を確認
  ↓
dashboard に該当 task_id の最新状態が反映されているか？
  ├─ YES → Skip（既処理）
  └─ NO  → 未処理として処理する
```

### 照合の判定基準

| Dashboard の状態 | Report の status | 判定 |
|-----------------|-----------------|------|
| task_id が Agent Status に `working` で記載 | done | **未処理** → 成果に移動 |
| task_id が Agent Status に `working` で記載 | blocked | **未処理** → Blockers に追加 |
| task_id が成果テーブルに `done` で記載 | done | **既処理** → Skip |
| task_id が Blockers に記載済み | blocked | **既処理** → Skip |
| task_id が Dashboard に存在しない | any | **未処理** → 新規追加 |

## PO 通知メッセージテンプレート

### 全タスク完了時

**【1回目】**:
```bash
tmux send-keys -t ixv-agents:0.0 '全タスクが完了しました。queue/dashboard.md を確認してください。'
```

**【2回目】**:
```bash
tmux send-keys -t ixv-agents:0.0 Enter
```

### ブロッカー発生時

**【1回目】**:
```bash
tmux send-keys -t ixv-agents:0.0 'タスクにブロッカーが発生しました。queue/dashboard.md の Blockers セクションを確認してください。'
```

**【2回目】**:
```bash
tmux send-keys -t ixv-agents:0.0 Enter
```

### 一部完了・一部ブロック時

**【1回目】**:
```bash
tmux send-keys -t ixv-agents:0.0 'タスクの一部が完了し、一部にブロッカーがあります。queue/dashboard.md を確認してください。'
```

**【2回目】**:
```bash
tmux send-keys -t ixv-agents:0.0 Enter
```

## Agent Status 更新フォーマット

```markdown
## Agent Status
| Agent | Current Task | Status | Last Update |
|-------|--------------|--------|-------------|
| Dev1 | TASK-20260201-010 | idle | 15:30 |
| Dev2 | TASK-20260201-011 | blocked | 15:25 |
| Dev3 | TASK-20260201-012 | idle | 15:20 |
```

| Status値 | 意味 |
|---------|------|
| working | タスク実行中 |
| idle | 完了、次のタスク待ち |
| blocked | ブロッカーにより停止 |
| needs_review | レビュー待ち |
