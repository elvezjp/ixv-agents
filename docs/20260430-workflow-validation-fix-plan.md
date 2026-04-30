# ワークフロー検証層 整備計画

**作成日**: 2026-04-30
**起票者**: 田中秀樹（Issue #31 / #32 / #33 / #40 の起票）
**トラッキング Issue**: [#57](https://github.com/elvezjp/20260130ixv-agents/issues/57)（4 issue 一括対応）
**対象Issue**: [#31](https://github.com/elvezjp/20260130ixv-agents/issues/31), [#32](https://github.com/elvezjp/20260130ixv-agents/issues/32), [#33](https://github.com/elvezjp/20260130ixv-agents/issues/33), [#40](https://github.com/elvezjp/20260130ixv-agents/issues/40)
**ステータス**: Draft（実装着手前のレビュー待ち）
**実装方式**: 単一 PR で一括対応

---

## 1. 背景

GitHub の `bug, high priority` ラベルが付いた 4 issue を個別 bug として見ると独立に見えるが、実装を読み解いた結果、**4件は「ワークフローに検証層が組み込まれていない」という単一の構造的欠陥から派生する症状**であることが判明した。本計画書は 4 issue を一括で解消する方針を定める。

### 1.1 設計制約（前提）

本計画は以下の制約のもとで設計する。

| 制約 | 対象 | 理由 |
|---|---|---|
| **既存 YAML スキーマを変更しない** | SPEC.md §2.3.2〜2.3.5、`queue/po_to_sm.yaml`, `queue/tasks/dev{N}.yaml`, `queue/reports/{task_id}.yaml` のフィールド定義 | 後方互換性の維持。検証に必要な情報は既存フィールドから全て読み取れる |
| **既存 dashboard 構成を変更しない** | SPEC.md §4.2、`workspace/queue/dashboard.md` のセクション構造 | 既存スクリプトや表示ツールへの波及を避ける。ブロッカー / 注記は既存の `## Blockers`, `## Notes` で表現可能 |
| **roles と skills の指示改善を主軸とする** | `roles/*.md`, `skills/*/SKILL.md`, `skills/*/references/*.md`, `skills/references/*.md` | 検証ロジックは指示書層で完結させる |
| **SPEC.md は「ルール/規約層」のみ追加** | 新規セクション §2.4 / §2.5 / §2.6 を追加するが、データスキーマ・状態遷移・dashboard 章には触れない | SSoT として規約を集約、skills が参照する根拠とする |

### 1.2 4 issue の要約

| # | タイトル | 症状 |
|---|---|---|
| #31 | feature/bugfix タスクのフェーズルーティングが曖昧 | SM が task_type=feature/bugfix を受信した際の振り分けロジックが SKILL 本体に存在しない |
| #32 | acceptance_criteria / definition_of_done が空でも通過する | 「最低1件必須」がルール表記載のみで、空配列を弾く Step が無い |
| #33 | 依存タスクの完了チェックと循環依存検出がない | dependencies の事前確認・状態確認・循環検出のいずれも未実装 |
| #40 | definition_of_done と実際の成果物の照合検証がない | Dev の `status: done` を SM が盲目的に信用、DoD 各項目との突合がない |

---

## 2. 根本原因分析

### 2.1 共通する構造的欠陥

| 構造的欠陥 | 現状 | 影響Issue |
|---|---|---|
| **A. ルールと手順の分離** | 各スキルの末尾の「Validation Rules」表に記載があるだけで、Step として実行されない | #32 |
| **B. クロスファイル検証の欠落** | 各スキルが対象 YAML を単独で扱う。依存先タスク／元タスクの DoD など、関連ファイルを参照する Step が無い | #33, #40 |
| **C. 判定ロジックが reference 任せ** | SKILL.md 本体に分岐ロジックが無く、`references/*.md` に追いやられている | #31 |
| **D. ハッピーパス前提** | バリデーション失敗時の「拒否」「差し戻し」「blocked 化」フローが書かれていない | 全件 |

### 2.2 SPEC.md レイヤーの不足

[SPEC.md](../SPEC.md) を確認した結果、以下が **データスキーマ層では定義済み** だが **ルール/規約層では未定義** であることが分かった。

| 領域 | 現状 | 不足 | 本計画の扱い |
|---|---|---|---|
| データスキーマ | §2.3.2〜2.3.5 で型と必須/任意を定義済み | ― | **変更しない**（制約） |
| dashboard 構成 | §4.2 でセクション構造を定義済み | ― | **変更しない**（制約） |
| 状態遷移 | §2.4 で `queued → in_progress → done/blocked/needs_review` の単純遷移のみ | 各遷移時の検証要件が未定義 | §2.4 を「検証ルール」セクションに置き換え（既存の状態遷移は維持しつつ検証要件を併記） |
| 検証ルール | **該当セクション無し** | 必須配列の空配列禁止、依存検証、DoD vs report 突合 | §2.4 として新設 |
| 依存関係 | §2.3.3 で `dependencies` フィールド定義のみ | DAG 必須、blocked 依存の扱い、循環禁止 | §2.5 として新設 |
| task_type 判定 | **該当セクション無し**（`task-type-routing.md` reference にあるのみ） | feature/bugfix の決定木 | §2.6 として新設 |

→ **SPEC.md にもルール層の追加が必要**。ただし既存のデータスキーマ（§2.3.x）と dashboard 構成（§4.2）は **完全に維持** する。skills は SPEC のルール層を参照する形で実行手順を追加する。

---

## 3. 修正方針

### 方針 1: SPEC.md に「ワークフロー検証ルール」セクションを新設

SPEC.md は Single Source of Truth として、各役割が遵守すべき検証ルールを集約する。skills はこのルールを **実行する手順書** として位置づけ直す。

**追加するセクション（案）**:
- `§ 2.4` 検証ルール（Validation Rules）— 必須配列の空配列禁止、DoD vs report 突合、必須フィールド欠落時の挙動
- `§ 2.5` 依存関係グラフ規約 — DAG 必須、循環検出、blocked 依存時の扱い
- `§ 2.6` task_type → フェーズ判定規則 — feature/bugfix の決定木
- 既存の `§ 2.4 タスク状態遷移`、`§ 2.5 排他/競合ルール` 等は番号繰り下げ

### 方針 2: 各 SKILL.md に「検証ステップ」を必須化

各 YAML 生成/受領スキルに、以下の3段階を明示的な Step として追加する。

```
Step N-1: 構造検証（必須フィールド、形式）
Step N  : 内容検証（空配列禁止、DoD突合、依存検証）
Step N+1: 失敗時アクション（拒否 / 差し戻し / blocked 化）
```

### 方針 3: 状態判定手段の明文化

- **依存タスクの状態確認**: `queue/reports/{task_id}.yaml` の `status` フィールドを参照する手順を SPEC で規定
- **DoD 突合の手段**: `definition_of_done` の各項目に対し、`changes` または `artifacts` のいずれかが対応していることを Dev/SM 双方で確認
- **循環依存の検出**: SM がタスク発行前に DAG バリデーションを実行（簡易：BFS で自タスクIDが現れたら循環）

---

## 4. 修正対象ファイル一覧

### 4.1 SPEC.md 改訂（ルール層のみ追加。データスキーマ §2.3 と dashboard §4.2 は不変）

| 箇所 | 変更内容 | 関連Issue |
|---|---|---|
| § 2.4（既存「タスク状態遷移」） | 「検証ルール」に拡張統合。状態遷移図は維持しつつ、各遷移時の検証要件（必須配列の空配列禁止、DoD vs report 突合、必須フィールド欠落時の挙動）を併記 | #32, #40 |
| § 2.5（既存「排他/競合ルール」） | 「依存関係グラフ規約」を併設。DAG 必須、循環禁止、blocked 依存時の扱い、依存先状態確認手段（既存 `reports/{task_id}.yaml` の status 参照） | #33 |
| § 2.6（新規） | task_type → フェーズ判定規則（feature/bugfix 決定木と判定優先順位） | #31 |
| § 2.6（既存「ファイル所有権マトリクス」）以降 | 番号繰り下げ | ― |

> **不変対象**: § 2.3.x（YAML フィールド定義）、§ 4.2（dashboard.md フォーマット）には一切手を入れない。検証は既存フィールドのみで完結する。

### 4.2 skills/ 改訂

#### 4.2.1 各 SKILL.md への Step 追加

| ファイル | 変更内容 | 関連Issue |
|---|---|---|
| [skills/po-request-yaml/SKILL.md](../skills/po-request-yaml/SKILL.md) | Step 4 と Step 5 の間に「Step 4.5: 必須項目検証」追加。`acceptance_criteria` 空配列を拒否、各項目が検証可能形式かをチェック | #32 |
| [skills/sm-receive-request/SKILL.md](../skills/sm-receive-request/SKILL.md) | (a) Step 1 末尾に「acceptance_criteria 空チェック」を Step 化（Error Recovery 表からの昇格）、(b) Step 2 を拡張し `task_type=feature/bugfix` の場合は決定木で判定 | #31, #32 |
| [skills/sm-write-task-yaml/SKILL.md](../skills/sm-write-task-yaml/SKILL.md) | Step 5 と Step 6 の間に「Step 5.5: 依存・DoD 検証」追加。`definition_of_done` 空配列拒否、`dependencies` の存在確認・状態確認・循環検出 | #32, #33 |
| [skills/dev-receive-task/SKILL.md](../skills/dev-receive-task/SKILL.md) | Step 4 を強化：`dependencies` がある場合、`queue/reports/{dep_task_id}.yaml` を読み取り `status: done` を確認。未完了なら `status: blocked` で報告 | #33 |
| [skills/dev-write-report/SKILL.md](../skills/dev-write-report/SKILL.md) | Step 2 と Step 3 の間に「Step 2.5: DoD セルフチェック」追加。`status: done` を選ぶ前に `definition_of_done` 各項目に対応する `changes` または `artifacts` の存在をレビュー。未対応項目は `issues` に明記し `status` を `needs_review` に格下げ | #40 |
| [skills/sm-scan-reports/SKILL.md](../skills/sm-scan-reports/SKILL.md) | Step 3 と Step 4 の間に「Step 3.5: DoD 突合検証」追加。`done` 報告について対応 task の `definition_of_done` を読み込み突合。未カバー項目があれば dashboard の既存 `## Notes` に記載し、Dev に追加作業を send-keys | #40 |

#### 4.2.2 共通リファレンスの新設・更新

| ファイル | 変更内容 | 関連Issue |
|---|---|---|
| [skills/references/dod-verification.md](../skills/references/dod-verification.md)（新規） | DoD 各項目と changes/artifacts の対応判定基準（キーワード一致、ファイルパス類推、明示マッピング）を共通化。dev-write-report と sm-scan-reports の両方から参照 | #40 |
| [skills/references/dependency-validation.md](../skills/references/dependency-validation.md)（新規） | 依存先状態テーブル（done/in_progress/blocked/needs_review/不在）と循環検出 BFS の擬似コードを共通化。sm-write-task-yaml と dev-receive-task の両方から参照 | #33 |
| [skills/sm-receive-request/references/task-type-routing.md](../skills/sm-receive-request/references/task-type-routing.md) | feature/bugfix の判定を表から決定木フローへ書き換え。各条件の確認手段（README.md grep / docs/ ls 等）と優先順位を明記 | #31 |

### 4.3 roles/ 改訂（最小限）

各役割に「役割としての検証義務」を1〜2行で追記する。詳細手順は SKILL.md / SPEC.md に委ねる。

| ファイル | 追記内容 | 関連Issue |
|---|---|---|
| [roles/po.md](../roles/po.md) | `acceptance_criteria` は最低1件・検証可能形式で記入する責任を明記 | #32 |
| [roles/sm.md](../roles/sm.md) | (a) DoD 1件以上必須、(b) タスク発行前の依存検証義務、(c) feature/bugfix の決定木振り分け義務、(d) done レポート受領時の DoD 突合義務 | #31, #32, #33, #40 |
| [roles/dev.md](../roles/dev.md) | (a) 依存タスクが未完了なら作業を始めず blocked 報告、(b) `status: done` 前に DoD セルフチェック必須 | #33, #40 |

---

## 5. 実装順序

### 5.1 実装方式の決定

**4 issue を単一の PR で一括対応する**。

#### 単一 PR を選択した理由

| 観点 | 評価 |
|---|---|
| ファイル重複 | `sm-write-task-yaml/SKILL.md` の Step 5.5 は #32 と #33 の検証を統合した1ステップ。`sm-receive-request/SKILL.md` は #31 と #32 の両方が触る。`roles/sm.md` は4件全てが追記する。これを issue ごとに分けると同一ファイルへの重複編集とマージコンフリクトが頻発する |
| 設計の一貫性 | 4 issue は「検証層の不在」という単一の構造的欠陥に由来する。一括対応により設計意図がレビュアーに伝わりやすい |
| SPEC.md 整合 | §2.4 / §2.5 / §2.6 の3変更は相互参照する。1コミットで完結させるべき |
| 中間状態の不整合回避 | 段階的マージでは、SPEC は変わったが skills/roles が追従していない不整合期間が生じる |
| 作業効率 | 1ブランチ・1レビューで完結 |

### 5.2 PR 内のコミット粒度

単一 PR でも、レビュアビリティのためコミットは論理単位で分ける。

| # | コミット | 主な変更ファイル | 関連Issue |
|---|---|---|---|
| 1 | SPEC.md ルール層追加 | SPEC.md §2.4 拡張 / §2.5 拡張 / §2.6 新設 | 全件（土台） |
| 2 | 共通リファレンス新設 | skills/references/dod-verification.md, skills/references/dependency-validation.md | #33, #40 |
| 3 | 必須項目検証（空配列拒否） | skills/po-request-yaml/SKILL.md, skills/sm-write-task-yaml/SKILL.md, skills/sm-receive-request/SKILL.md | #32 |
| 4 | DoD 突合 | skills/dev-write-report/SKILL.md, skills/sm-scan-reports/SKILL.md | #40 |
| 5 | 依存検証 | skills/sm-write-task-yaml/SKILL.md, skills/dev-receive-task/SKILL.md | #33 |
| 6 | フェーズ判定（feature/bugfix 決定木） | skills/sm-receive-request/SKILL.md, skills/sm-receive-request/references/task-type-routing.md, skills/po-request-yaml/SKILL.md | #31 |
| 7 | roles 改訂 | roles/po.md, roles/sm.md, roles/dev.md | 全件 |
| 8 | 検証用 YAML での回帰確認 | （必要に応じて）docs/* に検証ログ | 全件 |

### 5.3 PR / Issue クローズ方針

- PR タイトル: `ワークフロー検証層の整備（#31 / #32 / #33 / #40 一括対応）`
- PR の body に `Closes #31`, `Closes #32`, `Closes #33`, `Closes #40`, `Closes #57` を明記
- マージ時に5つの issue が一括 close される

---

## 6. SPEC.md 改訂案（詳細）

> **適用方針**: 既存の §2.4「タスク状態遷移」を拡張統合、既存の §2.5「排他/競合ルール」に依存関係規約を併設、§2.6 を新設。**§2.3.x（YAML スキーマ）と §4.2（dashboard）は不変**。既存の §2.6 以降は番号を繰り下げる。

### 6.1 § 2.4 拡張（タスク状態遷移 + 検証ルール）

```markdown
## 2.4. タスク状態遷移と検証ルール

### 2.4.1. 状態遷移（既存）

queued -> in_progress -> done
                    -> blocked
                    -> needs_review

### 2.4.2. 必須配列の空配列禁止

以下のフィールドは「1件以上必須」と定義されており、空配列のまま発行してはならない。
スキーマ自体は変更せず、発行スキルが Step として強制する。

| ファイル | フィールド | 検証者 | 違反時アクション |
|---------|---------|-------|--------------|
| queue/po_to_sm.yaml | acceptance_criteria | PO（発行前） | 発行を中断し、Human にヒアリング |
| queue/tasks/dev{N}.yaml | definition_of_done | SM（発行前） | 発行を中断し、PO に確認（po_to_sm.yaml の acceptance_criteria を再読） |

### 2.4.3. Definition of Done 突合

Dev は `status: done` を報告する際、対応するタスクの `definition_of_done` の各項目に対し、
`changes` または `artifacts` のいずれかが対応していることをセルフチェックする。
未カバーがあれば既存の `issues` フィールドに明記し、`status` を `needs_review` に格下げする。

SM は done レポート受領時に同様の突合を行い、未カバー項目があれば既存の dashboard.md
`## Notes` に記載し、Dev に追加作業を指示する（dashboard 構成は変更しない）。

### 2.4.4. 必須フィールド欠落時の挙動

| 受領者 | 欠落検出時 |
|--------|----------|
| SM（po_to_sm.yaml） | PO に send-keys で確認、処理を保留 |
| Dev（tasks/dev{N}.yaml） | status: blocked で SM に報告 |
| SM（reports/{task_id}.yaml） | dashboard.md の `## Notes` に記録、Dev に再作成依頼 |
```

### 6.2 § 2.5 拡張（排他/競合 + 依存関係グラフ規約）

```markdown
## 2.5. 排他/競合ルールと依存関係グラフ

### 2.5.1. 排他ルール（既存）

- 同一 task_id に対する同時編集は禁止
- 進行中タスクの中断は status: blocked で報告し、SM の判断で再割当て

### 2.5.2. 依存関係 DAG 必須

タスク間の `dependencies` は **有向非巡回グラフ（DAG）** でなければならない。
SM はタスク発行前に循環依存の有無を検証する（`queue/tasks/*.yaml` の dependencies を BFS）。

### 2.5.3. 依存先の状態要件

| 依存先 status | SM の対応（発行前） | Dev の対応（受領時） |
|---|---|---|
| done | 発行可 | 受領可 |
| in_progress | 発行可（順次実行）/ 発行延期も可 | 依存先完了まで待機（または blocked 報告） |
| blocked | 発行不可（解決後に再評価） | status: blocked で再報告 |
| needs_review | 発行不可（PO 判断後に再評価） | status: blocked で再報告 |
| 不在（task_id が存在しない） | 発行不可 | status: blocked で報告 |

### 2.5.4. 状態確認手段

依存先タスクの状態は **既存の `queue/reports/{dep_task_id}.yaml` の `status` フィールド** で確認する。
report ファイルが存在しない場合は「未着手 or in_progress」と判定する。
新たなフィールドやファイルは追加しない。
```

### 6.3 § 2.6 task_type → フェーズ判定規則（新規）

```markdown
## 2.6. task_type → フェーズ判定規則

### 2.6.1. 直接マッピング

| task_type | Phase |
|---|---|
| constitution_update | 1 |
| spec_update | 2 |
| plan | 3 |
| execute | 4 |
| verify | 6 |
| backlog_update | 6 |

### 2.6.2. feature / bugfix の決定木

feature/bugfix は汎用的な task_type であり、コンテキストに応じてフェーズを判定する。
SM は受領時に以下の決定木を上から順に評価し、最初にマッチした条件のフェーズを採用する。

1. 要件が README.md に未記載（grep で該当語句なし） → **Phase 2 (Specify)** = `spec_update` 相当
2. 要件は記載済みだが設計（docs/）未完了 → **Phase 3 (Plan)** = `plan` 相当
3. 設計済みだが実装未完了（成果物ファイル未作成） → **Phase 4 (Tasks)** = `execute` 相当
4. 実装済みだが検証未完了 → **Phase 6 (Verify)** = `verify` 相当

複数条件にマッチする場合は **より早いフェーズを優先**（前段が未完了なら戻る）。
判定後は SM が dashboard.md の `## Current Phase` を更新する（dashboard フォーマットは変更なし）。
```

---

## 7. テスト・検証計画

PR マージ後、実際にエージェントを起動して 4 issue が解決されていることと全体ワークフローが壊れていないことを確認する。
詳細な試験項目表は別ドキュメントに分離した:

- **[docs/20260430-workflow-validation-test-cases.md](20260430-workflow-validation-test-cases.md)** — 試験項目表（正常系4件・異常系7件・モバイル0件）

### 概要

| カテゴリ | 件数 | 主な検証観点 |
|---|---:|---|
| 正常系 | 4 | 全体ワークフロー1サイクル完走、feature/bugfix 決定木判定、依存タスクの順次実行、DoD 全カバー done の正常処理 |
| 異常系 | 7 | 空配列拒否（PO/SM 両側）、未完了依存・循環依存の発行拒否、Dev 受領時の blocked 化、DoD 未カバーの自動 needs_review 格下げ、SM 側の DoD 突合検知 |
| モバイル | 0 | 該当なし（CLI / エージェントシステム） |

### 検証実施タイミング

PR をマージしてから、`./scripts/setup_workspace.sh` で初期化したワークスペースに対して試験項目表に従い実施する。
合格基準は全11試験項目が PASS であること。FAIL があれば本 PR マージ後の追加 PR で対応する。

---

## 8. オープン課題

- **後方互換性**: 既に `queue/` に存在する YAML が新ルールに違反している場合の移行戦略（grandfather か再生成か）を要検討。
- **検証スキルの抽出**: 各スキルに散らばった検証ロジックを共通スキル `validate-yaml` として切り出すか、各スキル内に保持するかは実装時に判断。
- **DoD 突合の判定精度**: キーワード一致や類推では誤判定が起きうる。判定基準は `skills/references/dod-verification.md` で漸進的に磨いていく。
- **dashboard.md の `## Notes` 運用**: DoD 未カバー報告や依存関係ブロックの記載が `## Notes` に集中する可能性。フォーマット変更はしないが、記載粒度のガイドを SKILL.md に追記する余地あり。

---

## 9. 承認・実施

本計画書のレビュー後、トラッキング Issue [#57](https://github.com/elvezjp/20260130ixv-agents/issues/57) に紐付く **単一の PR** で一括実装する。

### 実施手順

1. 作業ブランチを作成（命名規則: `{ユーザー名}/{YYYYMMDD}-workflow-validation`）
2. §5.2 のコミット粒度に従って論理単位ごとにコミット
3. 各コミット後に該当箇所をセルフレビュー
4. §7 の検証ケースを `workspace/queue/` に投入して回帰確認
5. PR 作成（タイトル・body は §5.3 に従う）
6. レビュー → マージ
7. マージ時に #31 / #32 / #33 / #40 / #57 が一括 close されることを確認
