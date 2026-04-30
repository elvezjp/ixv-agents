---
name: sm-receive-request
description: |
  queue/po_to_sm.yaml を読み取り、task_typeに応じたフェーズとアクションを判定する。
  SMが起こされた際の最初のステップとして使用する。
  Use when: 「POから起こされた」「指示確認」「po_to_sm.yaml確認」「タスク受領」と言われた時。
metadata:
  author: IXV-Agents
  version: 1.0.0
  phase: "1, 2, 3, 4, 6, 7"
---

# SM Receive Request

POからの指示（`queue/po_to_sm.yaml`）を読み取り、`task_type` に基づいて適切なフェーズを判定し、フェーズ別のアクション指示を返す。

## When to Use

- POからの send-keys で起こされた時
- コンパクション復帰後に現在の指示を確認する時
- ワークフローサイクルの開始時

## Instructions

### Step 1: po_to_sm.yaml を読み取り

`queue/po_to_sm.yaml` を読み取り、以下のフィールドを確認する：

| フィールド | 確認内容 |
|-----------|---------|
| task_type | フェーズ判定の基準 |
| request_id | リクエスト追跡用 |
| priority | 優先度（P0/P1/P2） |
| summary | 要件概要 |
| acceptance_criteria | 受入条件 |

### Step 1.5: 受領時の必須項目検証

**SPEC.md §2.4.2 / §2.4.4 に基づく必須検証**。Step 2 に進む前に以下を **Step として実行** すること。

#### 検証1: 必須フィールド欠落チェック（SPEC.md §2.4.4）

`task_type` / `request_id` / `summary` / `acceptance_criteria` のいずれかが欠落している場合：

```
処理を保留
PO に send-keys で確認:
  「po_to_sm.yaml の {field} が欠落しています。確認してください。」
```

#### 検証2: acceptance_criteria 空配列チェック（SPEC.md §2.4.2）

`acceptance_criteria` が **空配列** の場合：

```
処理を保留
PO に send-keys で確認:
  「acceptance_criteria が空です。受入条件を最低1件記入してください。」
```

これは PO 側の `po-request-yaml` でも検証されるべきだが、SM 側でも二重に確認することで取りこぼしを防ぐ。

#### 違反時の挙動

| 違反内容 | アクション |
|---------|----------|
| 必須フィールド欠落 | PO に send-keys で確認、処理を保留（Step 2 に進まない） |
| `acceptance_criteria` 空 | PO に send-keys で確認、処理を保留 |
| `priority` 欠落のみ | P1 をデフォルトとして処理、`dashboard.md` の `## Notes` に注記 |

検証をすべてパスした場合のみ、Step 2 に進む。

### Step 2: task_type からフェーズを判定

**SPEC.md §2.6 に基づくフェーズ判定**。`task_type` の種別に応じて以下のいずれかのルートで判定する。

#### Step 2-A: 直接マッピング（SPEC.md §2.6.1）

`task_type` が以下のいずれかの場合、対応フェーズに直接マッピングする。

| task_type | Phase | Dashboard表記 | 次スキル/アクション |
|-----------|-------|--------------|-------------------|
| `constitution_update` | 1 | `工程1 Constitution — 原則決定` | sm-update-spec |
| `spec_update` | 2 | `工程2 Specify — 企画・要件定義` | sm-update-spec |
| `plan` | 3 | `工程3 Plan — 設計計画` | 複雑さ判断 → sm-write-task-yaml or docs/作成 → sm-update-spec |
| `execute` | 4 | `工程4 Tasks — タスク分割` | sm-write-task-yaml |
| `verify` | 6 | `工程6 Verify/Accept — 検証・受入` | 成果物検証 → PO通知 |
| `backlog_update` | 6 | `工程6 Verify/Accept — 検証・受入` | sm-update-spec |

#### Step 2-B: 決定木による判定（SPEC.md §2.6.2、`feature` / `bugfix` の場合）

`task_type` が `feature` または `bugfix` の場合は、以下の決定木を **上から順に評価** し、最初にマッチした条件のフェーズを採用する（前段が未完了なら戻る）。

```
1. 要件が README.md に未記載か？
   → grep で summary のキーワードを検索
   → ヒットなし → Phase 2 (Specify) として spec_update 相当で処理

2. 要件は記載済みだが、設計計画（docs/）が未完了か？
   → ls docs/ で関連する計画書（要件のキーワードを含むファイル名）を確認
   → 関連計画書なし → Phase 3 (Plan) として plan 相当で処理

3. 設計済みだが、実装が未完了か？
   → docs/ の計画書で言及される成果物ファイルが存在するか確認
   → 成果物未作成 → Phase 4 (Tasks) として execute 相当で処理

4. 実装済みだが、検証が未完了か？
   → 該当タスクの reports に done レポートはあるが、acceptance_criteria の検証が未済
   → Phase 6 (Verify) として verify 相当で処理
```

複数条件にマッチする場合は **より早いフェーズを優先** する。

##### 確認手段（具体的なコマンド例）

```bash
# 1. 要件が README.md に記載されているか
grep -i "{summary のキーワード}" workspace/README.md

# 2. 関連計画書が docs/ にあるか
ls workspace/docs/ | grep -i "{キーワード}"

# 3. 成果物ファイルが存在するか
ls workspace/{outputs から推測されるパス}

# 4. done レポートが存在するか
grep -l "status: done" queue/reports/*.yaml
```

##### Dashboard 表記

| 判定結果 | Dashboard 表記 |
|---|---|
| Phase 2 と判定 | `工程2 Specify — 企画・要件定義` |
| Phase 3 と判定 | `工程3 Plan — 設計計画` |
| Phase 4 と判定 | `工程4 Tasks — タスク分割` |
| Phase 6 と判定 | `工程6 Verify/Accept — 検証・受入` |

##### feature/bugfix 判定の例

```yaml
# 例: po_to_sm.yaml
task_type: feature
summary: "ダークモード切り替え機能の追加"
acceptance_criteria:
  - "設定画面でダークモードに切り替えられる"
```

→ `grep -i "ダークモード" workspace/README.md` を実行
   - ヒットなし → **Phase 2 (Specify)** と判定、`spec_update` 相当で処理
   - ヒットあり → 次の条件へ

```yaml
# 例: po_to_sm.yaml
task_type: bugfix
summary: "タスク一覧が表示されないバグの修正"
```

→ 該当機能は通常 README.md に記載済み、docs/ にも設計済みのため、ステップ3に進む
   → 成果物ファイルは存在するが動作不良 → **Phase 4 (Tasks)** と判定、`execute` 相当で処理

判定後、Step 3 で `dashboard.md` の `## Current Phase` を更新する。

### Step 3: dashboard.md の Current Phase を更新

`queue/dashboard.md` の `## Current Phase` セクションを更新する。

```markdown
## Current Phase
> **工程{N} {PhaseName}** — {説明}
```

タイムスタンプは `date "+%Y-%m-%d %H:%M"` で取得すること。

### Step 4: フェーズ別アクション指示を返す

判定結果に基づき、次のアクションを指示する。

**Phase 1（Constitution）の場合**:
```
フェーズ判定: 工程1 原則決定（Constitution）
task_type: constitution_update
request_id: {request_id}

→ 次のアクション:
  1. sm-update-spec スキルで CONSTITUTION.md を更新
  2. PO に完了通知（send-keys）
```

**Phase 2（Specify）の場合**:
```
フェーズ判定: 工程2 企画・要件定義（Specify）
task_type: spec_update
request_id: {request_id}

→ 次のアクション:
  1. sm-update-spec スキルで README.md を更新
  2. PO に完了通知（send-keys）
```

**Phase 3（Plan）の場合**:
```
フェーズ判定: 工程3 設計計画（Plan）
task_type: plan
request_id: {request_id}

→ 次のアクション:
  1. 要件の複雑さを判断
     - 単純: 直接計画を策定
     - 複雑: sm-write-task-yaml で調査タスクをDevに依頼 → 結果を待つ
  2. 計画書を docs/ に作成
  3. sm-update-spec スキルで README.md を詳細化
  4. PO に計画完了と関連する仕様更新を通知（send-keys）
```

**Phase 4（Tasks）の場合**:
```
フェーズ判定: 工程4 タスク分割（Tasks）
task_type: execute
request_id: {request_id}

→ 次のアクション:
  1. docs/ の計画書を読み取り
  2. 今回のタスクで実施する範囲を判断
  3. sm-write-task-yaml スキルでタスクを分解・割り当て
  4. dashboard.md の Backlog Status を更新
```

**Phase 6（Verify - verify）の場合**:
```
フェーズ判定: 工程6 検証・受入（Verify/Accept）
task_type: verify
request_id: {request_id}

→ 次のアクション:
  1. 計画（docs/）と仕様（README.md）に基づき成果物を検証
  2. 検証結果をPOに報告（send-keys）
```

**Phase 6（Verify - backlog_update）の場合**:
```
フェーズ判定: 工程6 検証・受入（Verify/Accept）
task_type: backlog_update
request_id: {request_id}

→ 次のアクション:
  1. sm-update-spec スキルで README.md の Backlog ステータスを done に更新
  2. PO に完了通知（send-keys）
```

## Examples

### Example 1: constitution_update

**po_to_sm.yaml の内容**:
```yaml
task_type: "constitution_update"
request_id: "REQ-20260201-001"
priority: "P0"
summary: "CONSTITUTION.mdの存在意義セクションを記入"
acceptance_criteria:
  - "## 1. 存在意義（Purpose）に具体的な目的が記載されている"
```

**判定結果**:
```
フェーズ判定: 工程1 原則決定（Constitution）
task_type: constitution_update
request_id: REQ-20260201-001

→ 次のアクション:
  1. sm-update-spec スキルで CONSTITUTION.md を更新
  2. PO に完了通知（send-keys）
```

### Example 2: execute

**po_to_sm.yaml の内容**:
```yaml
task_type: "execute"
request_id: "REQ-20260201-004"
priority: "P0"
summary: "認証機能フェーズ1の実行を開始"
acceptance_criteria:
  - "タスクが tasks/dev{N}.yaml に分解されている"
```

**判定結果**:
```
フェーズ判定: 工程4 タスク分割（Tasks）
task_type: execute
request_id: REQ-20260201-004

→ 次のアクション:
  1. docs/ の計画書を読み取り
  2. 今回のタスクで実施する範囲を判断
  3. sm-write-task-yaml スキルでタスクを分解・割り当て
  4. dashboard.md の Backlog Status を更新
```

### Example 3: verify

**po_to_sm.yaml の内容**:
```yaml
task_type: "verify"
request_id: "REQ-20260201-004"
priority: "P1"
summary: "認証機能の実装結果を検証"
acceptance_criteria:
  - "SMが計画と仕様に基づき成果物を検証している"
```

**判定結果**:
```
フェーズ判定: 工程6 検証・受入（Verify/Accept）
task_type: verify
request_id: REQ-20260201-004

→ 次のアクション:
  1. 計画（docs/）と仕様（README.md）に基づき成果物を検証
  2. 検証結果をPOに報告（send-keys）
```

## Error Recovery

| 異常パターン | 検知方法 | 対応 |
|-------------|---------|------|
| po_to_sm.yaml が存在しない | ファイル読み取り失敗 | PO に確認を求める（send-keys） |
| po_to_sm.yaml の YAML 構文エラー | パース失敗 | PO に再作成を依頼（send-keys） |
| task_type が未知の値 | ルーティングテーブルに該当なし | dashboard.md の Notes に記録し、PO に確認（send-keys） |
| request_id が欠落 | フィールド検証 | PO に確認を求める（send-keys） |
| Dev が全員 busy（工程3,4） | tmux capture-pane で確認 | dashboard.md の Blockers に記録し、PO に報告 |

## References

詳細なルーティングロジックは `references/task-type-routing.md` を参照。
フェーズ遷移条件は `../references/phase-gate.md` を参照。

## Notes

- このスキルはSMロールのみが使用する
- dashboard.md の Current Phase 更新は毎回必須
- タイムスタンプは `date` コマンドで取得する（推測しない）
- 不明な task_type を受け取った場合は、POに確認を求める（dashboard.md の要対応セクションに記載）
