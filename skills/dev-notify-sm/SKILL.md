---
name: dev-notify-sm
description: |
  報告ファイル書き込み後、SMにsend-keysで完了通知を送る。
  idle確認、リトライロジック、2回分割send-keysを実行する。
  Use when: 「SM通知」「完了通知」「send-keys」「SMに報告」と言われた時。
metadata:
  author: IXV-Agents
  version: 1.0.0
  phase: "3, 5"
---

# Dev Notify SM

報告ファイル（`queue/reports/{task_id}.yaml`）を書き込んだ後、SMに send-keys で完了通知を送る。通信ロスト対策として idle 確認とリトライロジックを含む。

## When to Use

- `dev-write-report` で `queue/reports/{task_id}.yaml` を書き込んだ直後
- **タスク完了後の通知は義務**（省略禁止）

## Prerequisites

- `queue/reports/{task_id}.yaml` が既に書き込まれていること
- 報告ファイルが存在しない状態で通知を送らないこと

## Instructions

### Step 1: SMの状態確認

```bash
tmux capture-pane -t ixv-agents:0.1 -p | tail -5
```

### Step 2: idle / busy 判定

| 表示 | 状態 | Action |
|------|------|--------|
| `❯ `（末尾） | idle | → Step 4 へ |
| `bypass permissions on` | idle | → Step 4 へ |
| `thinking` | busy | → Step 3 へ |
| `Esc to interrupt` | busy | → Step 3 へ |
| `Effecting…` | busy | → Step 3 へ |
| `Boondoggling…` | busy | → Step 3 へ |
| `Puzzling…` | busy | → Step 3 へ |
| `Calculating…` | busy | → Step 3 へ |
| `Fermenting…` | busy | → Step 3 へ |
| `Crunching…` | busy | → Step 3 へ |

### Step 3: busy の場合 — リトライ（最大3回）

```bash
sleep 10
```

10秒待機して Step 1 に戻る。

- **リトライ上限**: 最大3回
- **3回リトライ後も busy の場合**: Step 4 へ進む
  - 報告ファイルは既に書かれているため、SMが `sm-scan-reports` で発見できる

### Step 4: send-keys 送信（2回に分ける）

**【1回目】** メッセージを送る：
```bash
tmux send-keys -t ixv-agents:0.1 'Dev{N}、タスク完了しました。報告書を確認してください。'
```

**【2回目】** Enterを送る：
```bash
tmux send-keys -t ixv-agents:0.1 Enter
```

**重要**: 必ず **2回の別々のBash呼び出し** で実行する。1回にまとめてはいけない。

### Step 5: 停止

通知送信後、処理を終了する。次のタスクはSMから send-keys で起こされるまで待つ。

```
「報告を送信しました。ここで停止します。」
```

## Examples

### Example 1: SM が idle の場合（即時送信）

**Step 1**: SM の状態確認
```bash
tmux capture-pane -t ixv-agents:0.1 -p | tail -5
```
出力:
```
  tasks/dev1.yaml を確認します。
  ...
  ❯
```

**Step 2**: `❯` が表示 → **idle** → Step 4 へ

**Step 4**: send-keys 送信
```bash
tmux send-keys -t ixv-agents:0.1 'Dev1、タスク完了しました。報告書を確認してください。'
```
```bash
tmux send-keys -t ixv-agents:0.1 Enter
```

### Example 2: SM が busy → リトライ後に送信

**Step 1（1回目）**: SM の状態確認
```
  Esc to interrupt
```
→ **busy** → Step 3 へ

**Step 3（1回目）**: 10秒待機
```bash
sleep 10
```

**Step 1（2回目）**: SM の状態確認
```
  ❯
```
→ **idle** → Step 4 へ

**Step 4**: send-keys 送信（通常通り）

### Example 3: SM が3回リトライ後も busy → 強制送信

**Step 1〜3**: 3回リトライしても全て busy

**Step 4**: 3回リトライ後なので、busy でも送信に進む
```bash
tmux send-keys -t ixv-agents:0.1 'Dev2、タスク完了しました。報告書を確認してください。'
```
```bash
tmux send-keys -t ixv-agents:0.1 Enter
```

※ 報告ファイル `queue/reports/{task_id}.yaml` は既に存在するため、万が一 send-keys が届かなくても、SMの `sm-scan-reports` による全スキャンで報告が処理される。

## Validation Rules

| Rule | Description |
|------|-------------|
| 2回分割 | メッセージとEnterは必ず別々のBash呼び出し |
| idle確認 | 送信前にSMの状態を確認する |
| リトライ上限 | 最大3回（10秒間隔） |
| 報告ファイル存在 | 通知前に `queue/reports/{task_id}.yaml` が書き込み済み |
| 送信先 | `ixv-agents:0.1`（SMペイン）のみ |

## Prohibited Patterns

```bash
# ダメな例1: 1行で書く
tmux send-keys -t ixv-agents:0.1 'メッセージ' Enter

# ダメな例2: &&で繋ぐ
tmux send-keys -t ixv-agents:0.1 'メッセージ' && tmux send-keys -t ixv-agents:0.1 Enter

# ダメな例3: idle確認なしで送信
tmux send-keys -t ixv-agents:0.1 'メッセージ'  # ← idle確認をスキップ

# ダメな例4: PO ペインに送信
tmux send-keys -t ixv-agents:0.0 'メッセージ'  # ← Dev は PO に送信しない
```

## Notes

- このスキルは **Devロールのみ** が使用する
- send-keys の送信先は常に `ixv-agents:0.1`（SMペイン）
- DevはPO（`ixv-agents:0.0`）や他のDevペインには送信しない
- タスク完了後の通知は **義務**。報告なしではタスク完了扱いにならない
- 万が一 send-keys が届かなくても、報告ファイルはSMの `sm-scan-reports` で発見される（安全策）
