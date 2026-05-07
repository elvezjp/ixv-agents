# 依存関係検証（Dependency Validation）

タスクの `dependencies` フィールドに記載された依存先タスクの状態確認と、循環依存の検出方法を定める共通リファレンス。
SPEC.md §2.5.2〜2.5.4 を実装するために、`sm-write-task-yaml` と `dev-receive-task` の両スキルから参照する。

## 適用範囲

| スキル | 利用タイミング | 検証対象 |
|--------|--------------|---------|
| `sm-write-task-yaml` | タスク発行前 | (1) 依存先の存在 (2) 依存先の状態 (3) 循環依存 |
| `dev-receive-task` | タスク受領時 | (1) 依存先の存在 (2) 依存先の状態 |

循環検出は SM のみが行う（Dev は単一タスクしか見ないため検出不可能）。

## 検証 1: 依存先タスクの存在確認

`dependencies` の各 `task_id` が **発行済み** であることを確認する。

### 確認手順

1. `queue/tasks/*.yaml` を全件読み取り、`task_id` の一覧を取得
2. 過去の `queue/reports/*.yaml` も走査し、レポートが存在する `task_id` を一覧に追加
3. `dependencies` の各 ID が一覧に含まれることを確認

### 違反時アクション

| 状況 | SM の対応 | Dev の対応 |
|------|---------|----------|
| 依存先 `task_id` が一覧に存在しない | 発行を中断、PO に確認を求める | `status: blocked` で報告（理由: `dependencies` の `TASK-XXX` が存在しない） |

## 検証 2: 依存先タスクの状態確認

依存先タスクの `status` を `queue/reports/{dep_task_id}.yaml` の `status` フィールドから取得する。

### 確認手順

```bash
# 依存先 task_id ごとに対応するレポートを参照
cat queue/reports/{dep_task_id}.yaml
```

レポートが **存在しない** 場合は「未着手 or in_progress」と判定する（新たなフィールド・ファイルは追加しない）。

### 状態別の判定（SPEC.md §2.5.3 と同期）

| 依存先 status | SM の対応（発行前） | Dev の対応（受領時） |
|---|---|---|
| `done` | 発行可 | 受領可 |
| `in_progress`（report 不在含む） | 発行可（順次実行）/ 発行延期も可 | 依存先完了まで待機（または `status: blocked` 報告） |
| `blocked` | 発行不可（解決後に再評価） | `status: blocked` で再報告 |
| `needs_review` | 発行不可（PO 判断後に再評価） | `status: blocked` で再報告 |
| 不在（task_id が存在しない） | 発行不可 | `status: blocked` で報告 |

### 違反時アクション

#### SM 側（`sm-write-task-yaml`）

依存先が `blocked` / `needs_review` / 不在 の場合：

1. タスク発行を **中断**
2. `dashboard.md` の `## Blockers` に該当 task_id と理由を記載
3. PO に send-keys で報告

#### Dev 側（`dev-receive-task`）

依存先が `blocked` / `needs_review` / 不在 の場合：

1. 作業を **開始しない**
2. `dev-write-report` で `status: blocked` を発行
3. `issues` フィールドに依存先の状態と未解決理由を明記

## 検証 3: 循環依存の検出（SM のみ）

タスク発行前に、`queue/tasks/*.yaml` 全体の `dependencies` を辿って循環がないことを確認する。

### 検出アルゴリズム（BFS / 擬似コード）

```
function has_cycle(new_task_id, new_dependencies, all_tasks):
  for each dep in new_dependencies:
    visited = {}
    queue = [dep]
    while queue is not empty:
      current = queue.pop_front()
      if current in visited:
        continue
      visited.add(current)
      if current == new_task_id:
        return true   # 循環検出
      current_task = all_tasks.find(task_id == current)
      if current_task is null:
        continue
      for each child_dep in current_task.dependencies:
        queue.push_back(child_dep)
  return false
```

### 検出例

#### 例1: 直接循環（A → B → A）

```yaml
# tasks/dev1.yaml (既存)
task_id: TASK-20260430-001
dependencies:
  - TASK-20260430-002

# tasks/dev2.yaml (新規発行を検証中)
task_id: TASK-20260430-002
dependencies:
  - TASK-20260430-001   # ← 循環！
```

→ 発行を **中断**。

#### 例2: 間接循環（A → B → C → A）

```yaml
# tasks/dev1.yaml: TASK-A depends on TASK-B
# tasks/dev2.yaml: TASK-B depends on TASK-C
# 新規発行: TASK-C depends on TASK-A
```

BFS で TASK-A から辿ると `A → B → C → A` で循環を検出。発行を **中断**。

### 違反時アクション

循環を検出した場合：

1. タスク発行を **中断**
2. 循環パス（例: `A → B → C → A`）を `dashboard.md` の `## Blockers` に記載
3. PO に send-keys で報告し、依存関係の見直しを依頼

## 完全な検証フロー（SM の `sm-write-task-yaml` 用）

```
1. タスクYAML を生成（メモリ上）
2. dependencies の各 task_id について:
   a. 検証1: 一覧に存在するか
   b. 検証2: status が done/in_progress か（blocked/needs_review/不在は拒否）
3. 検証3: 循環依存がないか（BFS）
4. すべての検証をパスしたら queue/tasks/dev{N}.yaml に書き込み
5. いずれかが NG なら発行中断、Blockers/Notes に記録、PO に通知
```

## 完全な検証フロー（Dev の `dev-receive-task` 用）

```
1. queue/tasks/dev{N}.yaml を読み取り
2. dependencies が空なら作業開始
3. dependencies が空でない場合、各 dep について:
   a. 検証1: queue/reports/{dep}.yaml が存在するか
   b. 検証2: 存在する場合、status を確認
4. 全 dep が done なら作業開始
5. いずれかが done でなければ、dev-write-report で status: blocked を発行
   - issues に未完了の dep_task_id と現在の状態を明記
```

## 参照元スキル

このリファレンスを参照すべきスキル:

- `sm-write-task-yaml`（Step 5.5: 依存・DoD 検証）
- `dev-receive-task`（Step 4: 依存先 status 確認）

## 関連仕様

- SPEC.md §2.3.3（タスク `dependencies` フィールド定義）
- SPEC.md §2.3.4（レポート `status` フィールド定義）
- SPEC.md §2.5.2（依存関係 DAG 必須）
- SPEC.md §2.5.3（依存先の状態要件）
- SPEC.md §2.5.4（状態確認手段）
