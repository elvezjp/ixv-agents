---
name: heartbeat-update
description: |
  queue/heartbeat/{agent}.yaml を更新してエージェントの状態を通知する。
  進捗・完了・ブロックを Sentinel に伝えるために使用する。
  Use when: 「Heartbeat更新」「状態通知」「進捗更新」「完了通知」「ブロック報告」と言われた時。
metadata:
  author: IXV-Agents
  version: 1.0.0
  phase: "all"
---

# Heartbeat Update

Heartbeat 用の YAML を `queue/heartbeat/{agent}.yaml` に書き込む。

## When to Use

- タスク開始時
- タスク完了時
- ブロック発生時
- 長時間作業の進捗更新時

## Instructions

### Step 1: タイムスタンプを取得

```bash
date "+%Y-%m-%dT%H:%M:%S%z"
```

**必須**: タイムスタンプは必ず `date` コマンドで取得する。推測しないこと。

### Step 2: status を決定

| status | 条件 |
|--------|------|
| `idle` | 待機中 |
| `working` | 作業中 |
| `done` | タスク完了 |
| `error` | ブロック/エラー |

### Step 3: YAML を生成

```yaml
schema_version: "1.0"
agent: "dev1"
status: "working"
task_id: "TASK-YYYYMMDD-###"
progress: 0.3
updated_at: "YYYY-MM-DDTHH:MM:SS+0900"
message: "optional summary"
```

**各フィールドの方針**:

| Field | 記載内容 |
|-------|---------|
| agent | `po` / `sm` / `dev1`〜`dev3` |
| status | `idle` / `working` / `done` / `error` |
| task_id | 作業中の `TASK-...`（待機中は省略可） |
| progress | 0.0〜1.0（任意） |
| updated_at | `date` で取得した値 |
| message | 50文字以内の短い説明（任意） |

### Step 4: ファイルに書き込み

ファイルパス: `queue/heartbeat/{agent}.yaml`

**ディレクトリがない場合**:

```bash
mkdir -p queue/heartbeat
```

```
例: queue/heartbeat/dev1.yaml
```

### Step 5: 書き込み後の確認

- [ ] `agent` が正しい
- [ ] `status` が正しい
- [ ] `updated_at` が `date` 由来

## Notes

- Heartbeat は **Sentinel が読む**、PO/SM/Dev が **書く**
- 進捗更新は **最短30秒、最長5分** の間隔で行う
