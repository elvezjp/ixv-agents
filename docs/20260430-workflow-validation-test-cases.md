# 試験項目表：ワークフロー検証層の整備

**作成日**: 2026-04-30
**対象 PR**: トラッキング Issue [#57](https://github.com/elvezjp/20260130ixv-agents/issues/57)（#31 / #32 / #33 / #40 一括対応）
**関連計画**: [20260430-workflow-validation-fix-plan.md](20260430-workflow-validation-fix-plan.md)
**検証方針**: 実装の細部ではなく、4件の元 issue が解決されていること、および全体ワークフローに影響がないことを issue レベルで確認する。

## 検証環境

| 項目 | 値 |
|---|---|
| 起動コマンド | `./scripts/boot.sh` |
| tmux セッション | `ixv-agents` |
| 操作対象 | PO (0.0), SM (0.1), Dev1 (0.2), Dev2 (0.3), Dev3 (0.4) |
| ワークスペース | `workspace/`（必要に応じて `setup_workspace.sh` で初期化） |

## 試験項目の対応 issue

| 試験 No | 検証する Issue | 検証観点 |
|---|---|---|
| N-001 | 全体（4件） | 検証層追加が既存ワークフローを壊していない |
| N-002 | #31 | feature/bugfix が決定木で正しいフェーズに振り分けられる |
| N-003 | #33 | 依存タスクが順次完了し、後続タスクが正常開始される |
| N-004 | #40 | DoD 全カバーの done レポートが正常に処理される |
| E-001 | #32 | 空 acceptance_criteria が PO 側で拒否される |
| E-002 | #32 | 空 definition_of_done が SM 側で拒否される |
| E-003 | #33 | 未完了依存を持つタスクが SM 側で発行拒否される |
| E-004 | #33 | 循環依存を持つタスクが SM 側で発行拒否される |
| E-005 | #33 | Dev が未完了依存タスクを受領した場合に blocked 報告する |
| E-006 | #40 | Dev が DoD 未カバーで done 報告しようとした場合、自動的に needs_review に格下げされる |
| E-007 | #40 | SM が DoD 未カバーの done レポート受領時に dashboard `## Notes` に記載する |

---

## 1. 正常系

| No | 試験項目 | 前提条件 | 手順 | 期待結果 |
|---|---|---|---|---|
| N-001 | 全体ワークフローが7工程を1サイクル完走できること | `setup_workspace.sh` で初期化済み、エージェント起動済み、CONSTITUTION.md と README.md は初期テンプレート状態 | 1. PO に Human が「ダークモード切替機能を追加してほしい」と依頼<br>2. PO が憲章未記入を検出して `constitution_update` を発行<br>3. SM が CONSTITUTION.md を更新、Human が承認<br>4. PO が `spec_update` を発行、SM が README.md を更新、Human が承認<br>5. PO が `plan` を発行、SM が docs/ に計画書作成、Human が承認<br>6. PO が `execute` を発行、SM がタスク分解、Dev が実装<br>7. PO が `verify` を発行、検証通過、Human が最終承認<br>8. PO が `backlog_update` を発行、SM が Backlog を done に更新 | 全7工程がエラーなく完走し、`README.md` の Backlog で該当 REQ が `done` になっている。`dashboard.md` の `## Notes` に異常記録がない |
| N-002 | feature の決定木で要件未記載の場合に Phase 2 と判定されること（#31） | README.md に「タグ機能」の記載がない | 1. PO が `task_type: feature`、`summary: "投稿にタグ機能を追加"` で `po_to_sm.yaml` を発行<br>2. SM を send-keys で起動<br>3. SM が `sm-receive-request` の Step 2-B を実行 | SM が `grep "タグ" workspace/README.md` 等で未記載を確認 → **Phase 2 (Specify)** と判定、`dashboard.md` の `## Current Phase` が「工程2 Specify — 企画・要件定義」に更新される |
| N-003 | 依存タスクが順次完了して後続タスクが正常開始できること（#33） | TASK-A→TASK-B（B は A に依存）の2タスク発行可能な状態 | 1. SM が TASK-A を Dev1 に発行（dependencies なし）<br>2. SM が TASK-B を Dev2 に発行（`dependencies: [TASK-A]`）<br>3. Dev1 が TASK-A を完了し reports/TASK-A.yaml を `status: done` で書き込み<br>4. Dev2 を send-keys で起動 | Dev2 が `dev-receive-task` の Step 4.5 で `reports/TASK-A.yaml` の `status: done` を確認 → 作業を開始する。Dev2 の最終レポートも `status: done` で完了する |
| N-004 | DoD 全カバーの done レポートが正常に処理されること（#40） | Dev1 にタスク発行済み（DoD 3項目: 認証 API 実装・テスト作成・README 更新） | 1. Dev1 が指示通り全 DoD を満たす実装を完了<br>2. Dev1 が `dev-write-report` で `status: done` を生成<br>3. SM を send-keys で起動 | Dev1 のセルフチェック（Step 2.5）で 3/3 がカバー済みと判定 → `status: done` のまま発行。SM の Step 3.5 でも全カバー確認 → `dashboard.md` の Backlog/Agent Status に done として反映される |

## 2. 異常系

| No | 試験項目 | 前提条件 | 手順 | 期待結果 |
|---|---|---|---|---|
| E-001 | 空 acceptance_criteria を含む po_to_sm.yaml が PO 側で発行中断されること（#32） | PO が起動済み | 1. Human が「ダークモード対応してほしい」とだけ要望（受入条件は伝えない）<br>2. PO が `po-request-yaml` で YAML 生成を試行 | `po-request-yaml` の Step 4.5 で空配列を検出 → YAML 書き込みを中断し、Human に「完了条件は最低1件必要です。どうなったらOKですか？」とヒアリング |
| E-002 | 空 definition_of_done を含む tasks/dev*.yaml が SM 側で発行中断されること（#32） | PO から正常な po_to_sm.yaml を受領済み | 1. SM が `sm-write-task-yaml` で意図的に `definition_of_done: []` のままタスクを発行しようとする | `sm-write-task-yaml` の Step 5.5 検証1で空配列を検出 → タスク発行を中断、`po_to_sm.yaml` の `acceptance_criteria` を再読し、派生できなければ PO に send-keys で確認 |
| E-003 | 未完了依存を持つタスクが SM 側で発行拒否されること（#33） | `queue/reports/TASK-DEPENDENCY-001.yaml` が存在しない（または status が `blocked`） | 1. SM が新規タスクの dependencies に `TASK-DEPENDENCY-001` を含めて発行を試行<br>2. SM が `sm-write-task-yaml` Step 5.5 検証3-2 を実行 | SM が依存先 status を確認 → `done` / `in_progress` でないため発行を中断、`dashboard.md` の `## Blockers` に該当 task_id と理由を記載、PO に send-keys で報告 |
| E-004 | 循環依存を持つタスクが SM 側で発行拒否されること（#33） | `queue/tasks/dev1.yaml` に `TASK-A`（dependencies: [TASK-B]）が既に発行済み | 1. SM が新規タスク `TASK-B`（dependencies: [TASK-A]）を発行しようとする<br>2. SM が `sm-write-task-yaml` Step 5.5 検証3-3（BFS）を実行 | BFS で TASK-B → TASK-A → TASK-B の循環を検出 → 発行を中断、`## Blockers` に循環パスを記載、PO に依存関係見直しを send-keys で依頼 |
| E-005 | Dev が未完了依存タスクを受領した場合に blocked 報告すること（#33） | 何らかの理由で SM の検証をすり抜けて、依存先未完了のタスクが Dev に届いている状態（手動で `tasks/dev1.yaml` を作成） | 1. Dev1 を send-keys で起動<br>2. Dev1 が `dev-receive-task` を実行 | Dev1 の Step 4.5 で `queue/reports/{dep_task_id}.yaml` を読み取り、`status: done` でないことを検出 → 作業を開始せず `dev-write-report` で `status: blocked` を発行、`issues` に未完了の依存先 ID と現在の状態を明記 |
| E-006 | Dev が DoD 未カバーで done 報告しようとした場合に自動的に needs_review に格下げされること（#40） | Dev1 にタスク発行済み（DoD 3項目）、Dev1 が DoD のうち2項目しか実装できていない | 1. Dev1 が `dev-write-report` で `status: done` を選択しようとする<br>2. `dev-write-report` の Step 2.5（DoD セルフチェック）が実行される | キーワード一致／ファイルパス類推いずれでも未カバーな1項目が検出される → `status` が `done` から `needs_review` に **自動格下げ**、`issues` に未対応理由（例: `"DoD: ユニットテスト8件作成 が未対応"`）が記載される、`summary` にも「DoD 一部未対応」が反映される |
| E-007 | SM が DoD 未カバーの done レポート受領時に dashboard ## Notes に記載すること（#40） | Dev のセルフチェックをすり抜けて `status: done` が報告されている（手動で reports を `status: done` に編集して再現） | 1. SM が `sm-scan-reports` を実行<br>2. SM の Step 3.5（DoD 突合検証）が実行される | SM が対応 task の `definition_of_done` を読み込んで突合 → 未カバー項目を検出 → `dashboard.md` の `## Notes` に該当 task_id と未カバー項目を記載、Backlog Status の該当タスクを `done` にせず `needs_review` 相当の扱いにする、Dev に追加作業を send-keys で指示 |

## 3. モバイル

（該当する試験項目なし：0件）

---

## 検証実施手順

### 事前準備

1. PR をレビュー後、`tominaga/20260430-workflow-validation` ブランチを `main` にマージ
2. 検証用ワークスペースを初期化:
   ```bash
   ./scripts/setup_workspace.sh
   ```
3. エージェントを起動:
   ```bash
   ./scripts/boot.sh
   ```

### 異常系のセットアップ補助

E-003 / E-004 / E-005 / E-007 では「異常な状態」を意図的に作る必要がある。手動で `queue/` 配下に該当 YAML を配置するか、SM/Dev に「以下の状態を再現せよ」と send-keys で指示する。

| 試験 No | セットアップ方法 |
|---|---|
| E-003 | `queue/tasks/dev1.yaml` を手動作成（dependencies に存在しない task_id を記載） |
| E-004 | `queue/tasks/dev1.yaml` に TASK-A を発行後、SM に「TASK-A に依存する TASK-B を発行せよ」と指示 |
| E-005 | `queue/tasks/dev1.yaml` に未完了依存の dependencies を含めて手動作成、Dev1 を起動 |
| E-007 | Dev に正常な実装をさせず、`queue/reports/*.yaml` を手動編集して `status: done` に変えてから SM を起動 |

### 検証ログの記録

各試験の実施結果は以下のフォーマットで `docs/20260430-workflow-validation-test-results.md`（実施時に新規作成）に記録する。

```markdown
## 試験 No: X-NNN

- **実施日時**: YYYY-MM-DD HH:MM
- **結果**: PASS / FAIL
- **観測事項**: （実際の挙動を簡潔に）
- **乖離**: （期待結果との差分。なければ「なし」）
- **対応**: （FAIL の場合の対応方針。PASS なら「なし」）
```

### 合格基準

- 全11試験項目（N-001〜N-004、E-001〜E-007）が **PASS** であること
- FAIL があった場合は本 PR をマージ後の追加 PR で対応する（または本 PR にコミット追加してから再検証）

## 関連仕様

- [SPEC.md §2.4](../SPEC.md) — タスク状態遷移と検証ルール
- [SPEC.md §2.5](../SPEC.md) — 排他/競合ルールと依存関係グラフ
- [SPEC.md §2.6](../SPEC.md) — task_type → フェーズ判定規則
- [skills/references/dod-verification.md](../skills/references/dod-verification.md) — DoD 突合判定基準
- [skills/references/dependency-validation.md](../skills/references/dependency-validation.md) — 依存検証・循環検出
