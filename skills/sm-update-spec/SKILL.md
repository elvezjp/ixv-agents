---
name: sm-update-spec
description: |
  フェーズに応じて CONSTITUTION.md または README.md を更新する。
  Phase 1: CONSTITUTION.md の存在意義セクション更新。
  Phase 2: README.md の Requirements/Acceptance Criteria/Backlog 更新。
  Phase 3: README.md の仕様詳細化。
  Phase 6: README.md の Backlog ステータスを done に更新。
  Use when: 「仕様更新」「README更新」「憲章更新」「CONSTITUTION更新」「Backlog完了」「spec更新」と言われた時。
metadata:
  author: IXV-Agents
  version: 1.0.0
  phase: "1, 2, 3, 6"
---

# SM Update Spec

フェーズコンテキストに応じて、プロジェクトの仕様文書（CONSTITUTION.md / README.md）を更新する。

## When to Use

- Phase 1: POから `constitution_update` タスクを受領した時
- Phase 2: POから `spec_update` タスクを受領した時
- Phase 3: 計画に基づく仕様詳細化が必要な時
- Phase 6: POから `backlog_update` タスクを受領した時

## Instructions

### Step 1: 現在のフェーズを確認

`queue/po_to_sm.yaml` の `task_type` から現在のフェーズを確認する。

| task_type | Phase | 更新対象 |
|-----------|-------|---------|
| constitution_update | 1 | CONSTITUTION.md |
| spec_update | 2 | README.md |
| plan | 3 | README.md（詳細化） |
| backlog_update | 6 | README.md（Backlog） |

### Step 2: フェーズ別の更新対象を特定

#### Phase 1: CONSTITUTION.md 更新

**更新対象セクション**: `## 1. 存在意義（Purpose）`

**更新手順**:
1. `CONSTITUTION.md` を読み取り
2. `## 1. 存在意義（Purpose）` セクションを確認
3. `po_to_sm.yaml` の `summary` / `acceptance_criteria` / `notes` に基づき内容を記入
4. テンプレート文言（「このプロジェクトが存在する理由を明記する」）を具体的な目的に置換

**未記入判定パターン**（テンプレート文言のまま/空/プレースホルダー）:
- 「このプロジェクトが存在する理由を明記する」
- 「TODO」「TBD」「要記入」
- `{purpose}` / `[目的を記入]`

#### Phase 2: README.md 更新（仕様策定）

**更新対象セクション**:
| セクション | 更新内容 |
|-----------|---------|
| `## Goal` | 目的/達成したい価値の追加・修正 |
| `## Scope` | 含める範囲/Non-Goalsの追加・修正 |
| `## Requirements` | 機能要件の追加 |
| `## Acceptance Criteria` | 受入条件（テスト観点）の追加 |
| `## Constraints` | 技術/運用/セキュリティ制約の追加 |
| `## Backlog` | 新規エントリ追加（Status: ready） |

**更新手順**:
1. `README.md` を読み取り
2. `po_to_sm.yaml` の `summary` / `acceptance_criteria` / `constraints` / `notes` を確認
3. 該当セクションに要件を追加
4. Backlog テーブルに新規エントリを追加

**Backlog エントリ追加例**:
```markdown
## Backlog
| ID | Priority | Summary | Status |
|----|----------|---------|--------|
| REQ-20260201-001 | P1 | ダークモード対応 | ready |
```

#### Phase 3: README.md 更新（仕様詳細化）

**更新手順**:
1. `docs/` の計画書を読み取り
2. 計画内容に基づき、README.md の Requirements / Acceptance Criteria を具体化
3. 必要に応じて Constraints を追加

**注意**: 計画書（docs/）は補助資料。仕様として有効なのは README.md の記載のみ。
計画書に重要な決定がある場合、README.md の該当セクションへ要点を反映する。

#### Phase 6: README.md 更新（Backlog ステータス更新）

**前提**: 本スキルは Phase 6 の **ACCEPT 分岐**（PO が `backlog_update` を発行した場合）で起動する。REJECT / REVIEW_NEEDED 分岐では起動しない（SPEC.md §5.6 参照）。

**更新手順**:
1. `po_to_sm.yaml` から対象の `request_id` を確認
2. README.md の `## Backlog` テーブルで該当エントリの Status を `done` に更新

**更新例**:
```markdown
## Backlog
| ID | Priority | Summary | Status |
|----|----------|---------|--------|
| REQ-20260201-001 | P1 | ダークモード対応 | done |
```

**完了後の挙動**: PO に完了通知（send-keys）を送ったら **idle 状態**で停止し、次の `po_to_sm.yaml` を待つ。追加の task_type を自発的に発行してはならない。

### Step 3: 更新を実行

対象ファイルを更新する。更新時の注意：

- **セクション構造を維持する**: 既存のセクション見出しを変更しない
- **追記を優先する**: 既存の内容を不用意に削除しない
- **仕様の一貫性**: Requirements と Acceptance Criteria が対応していることを確認

### Step 4: PO に完了通知

**【1回目】** メッセージを送る：
```bash
tmux send-keys -t ixv-agents:0.0 '{対象ファイル} を更新しました。確認してください。'
```

**【2回目】** Enterを送る：
```bash
tmux send-keys -t ixv-agents:0.0 Enter
```

**フェーズ別メッセージ**:

| Phase | メッセージ |
|-------|----------|
| 1 | `CONSTITUTION.md の存在意義セクションを更新しました。確認してください。` |
| 2 | `README.md に仕様を反映しました。確認してください。` |
| 3 | `README.md の仕様を詳細化しました。計画書（docs/）と合わせて確認してください。` |
| 6 | `README.md の Backlog を更新しました（{request_id}: done）。確認してください。` |

## Examples

### Example 1: Phase 1 - CONSTITUTION.md 更新

**po_to_sm.yaml**:
```yaml
task_type: "constitution_update"
request_id: "REQ-20260201-001"
summary: "CONSTITUTION.mdの存在意義セクションを記入"
notes: "目的: AIエージェントによる効率的なソフトウェア開発プロセスの実現"
```

**更新前（CONSTITUTION.md）**:
```markdown
## 1. 存在意義（Purpose）
- このプロジェクトが存在する理由を明記する
```

**更新後（CONSTITUTION.md）**:
```markdown
## 1. 存在意義（Purpose）
- AIエージェントによる効率的なソフトウェア開発プロセスを実現する
```

### Example 2: Phase 2 - README.md 仕様策定

**po_to_sm.yaml**:
```yaml
task_type: "spec_update"
request_id: "REQ-20260201-002"
summary: "README.mdにダークモード対応の要件を追加"
acceptance_criteria:
  - "Requirements セクションにダークモード対応が記載されている"
  - "Acceptance Criteria にテスト観点が追加されている"
  - "Backlog に REQ-20260201-002 がエントリされている"
notes: "ユーザー要望: ダークモードに切り替えられるようにしたい"
```

**更新後（README.md の該当部分）**:
```markdown
## Requirements
- ダークモード対応: ユーザーがライト/ダークモードを切り替えられる

## Acceptance Criteria
- ダークモード切替ボタンが設定画面に表示される
- 切替時にUIテーマが即時反映される
- 設定がlocalStorageに保存され、リロード後も維持される

## Backlog
| ID | Priority | Summary | Status |
|----|----------|---------|--------|
| REQ-20260201-002 | P1 | ダークモード対応 | ready |
```

### Example 3: Phase 6 - Backlog ステータス更新

**po_to_sm.yaml**:
```yaml
task_type: "backlog_update"
request_id: "REQ-20260201-002"
summary: "REQ-20260201-002 のステータスを done に更新"
```

**更新前**:
```markdown
| REQ-20260201-002 | P1 | ダークモード対応 | in_sprint |
```

**更新後**:
```markdown
| REQ-20260201-002 | P1 | ダークモード対応 | done |
```

## Error Recovery

| 異常パターン | 検知方法 | 対応 |
|-------------|---------|------|
| CONSTITUTION.md / README.md が存在しない | ファイル読み取り失敗 | `scripts/setup_workspace.sh` で再初期化を検討。PO に報告 |
| 更新対象セクションが見つからない | セクション見出し検索失敗 | テンプレート構造が変更された可能性。現状の構造を確認し、PO に報告 |
| task_type と現在のフェーズが不一致 | dashboard.md の Current Phase と照合 | `sm-receive-request` のフェーズ判定を再実行 |
| PO への send-keys が届かない | PO ペインが busy | 更新は完了しているため、PO が idle になるまで待機（最大3回リトライ） |

## References

詳細な更新手順は `references/spec-update-guide.md` を参照。
フェーズ遷移条件は `../references/phase-gate.md` を参照。

## Notes

- このスキルはSMロールのみが使用する
- SMが直接更新する文書である（F001の例外: 仕様文書の更新はSMの責任）
- 仕様変更の Human 承認は PO が取得する（SMは更新のみ担当）
- README.md は唯一の仕様書（Single Source of Truth）
- 計画書（docs/*）は補助資料であり、仕様として有効なのは README.md のみ
