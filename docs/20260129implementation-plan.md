# IXV-Agents Implementation Plan (Plan.md)

**Version**: 0.1.0
**Last Updated**: 2026-01-29

**この計画書はPR#1で対応完了しました。今後は最新のREADMEと仕様書を参照してください。**

---

## Goal

`multi-agent-shogun` をベースに、仕様主導型AI開発チーム `ixv-agents` を構築する。
PO(1), SM(1), Dev(8), QA(2) の計12エージェント体制を実現する。

## Scope / Non-Goals

**Scope**:
- 12エージェントの起動・分離・通信ファイルの運用
- 仕様→タスク→レポートのトレーサビリティ確立
- ダッシュボード/キュー状況を確認できる **ローカルWeb UI** の提供

**Non-Goals**:
- 具体的なプロダクト実装やアプリ開発
- エージェントの自律判断による仕様変更

## Success Criteria (受入条件)

- 12エージェントが起動でき、役割ごとの入力ファイルが分離されていること
- PO→SM→Dev/QA→SM のフローが **YAMLで追跡可能** であること
- 仕様(`specs/current_spec.md`)と成果物の対応関係が明確であること
- Web UI でダッシュボードとキュー状況が参照できること

## Assumptions / Constraints

- `multi-agent-shogun` の実装と依存関係は利用可能である
- 仕様は `Spec.md` を単一の指針とし、実装はこれに準拠する
- ネットワークアクセスや外部API利用は **明示許可** のみ
- 仕様/タスクのテンプレートは **最小構成** から開始し、運用の負荷に応じて拡張する

## Role I/O Mapping (入出力ファイル)

- **PO**: `specs/current_spec.md`, `specs/backlog.md` → `queue/po_to_sm.yaml`
- **SM**: `queue/po_to_sm.yaml` → `queue/tasks/*.yaml`, `dashboard.md`
- **Dev/QA**: `queue/tasks/*.yaml` → `queue/reports/*.yaml`

## Phase 1: Environment Setup (基盤構築)

**依存関係**: なし（初期フェーズ）

`multi-agent-shogun` のスクリプトをフォークし、12エージェント体制に対応させる。

### Tasks

- [ ] **Repository Setup**: 新規プロジェクトディレクトリの初期化。
- [ ] **Script Adaptation**:
  - `shutsujin_departure.sh` を `ixv_boot.sh` に改名・改造。
  - **tmuxセッション構成** (決定):
    - **Session 1: `ixv-management`** - PO, SM (2 panes, vertical split)
    - **Session 2: `ixv-dev`** - Dev1〜Dev8 (2x4 grid, 8 panes)
    - **Session 3: `ixv-qa`** - QA1〜QA2 (2 panes, vertical split)
  - 理由: 役割ごとにセッションを分離し、モニタリングと操作を容易にする。
- [ ] **Directory Structure**: `queue/`, `instructions/`, `specs/` ディレクトリの作成。

### Exit Criteria
- [ ] `ixv_boot.sh` が12ペインを起動できる
- [ ] 主要ディレクトリと空のテンプレートファイルが存在する

## Phase 2: Role Definition (役割実装)

**依存関係**: Phase 1 (Directory Structure)

各ロールの指示書（System PromptにあたるMarkdown）を作成する。

### Tasks

- [ ] **Create Instructions**:
  - `instructions/po.md`: `shogun.md` をベースに、Spec管理機能を強化。
  - `instructions/sm.md`: `karo.md` をベースに、Dev/QAへの振り分けロジックを追加。
  - `instructions/dev.md`: `ashigaru.md` をベースに、実装・設計機能を強化。
  - `instructions/qa.md`: 新規作成。テスト・品質保証に特化。
- [ ] **Persona Configuration**: 戦国風から近代的なアジャイルチームのトーンへの調整（オプション）。

### Exit Criteria
- [ ] `instructions/*.md` が役割ごとに分離されている
- [ ] 役割外ファイル更新の禁止が明文化されている

## Phase 3: Communication Pipeline (通信制御)

**依存関係**: Phase 1 (Directory Structure), Phase 2 (Role Definitions)

エージェント間のメッセージング基盤を整備する。

### Tasks

- [ ] **Queue Files Setup**:
  - `queue/po_to_sm.yaml`
  - `queue/tasks/dev[1-8].yaml`
  - `queue/tasks/qa[1-2].yaml`
  - `queue/reports/...`
- [ ] **Dashboard Update**: `dashboard.md` のフォーマットを、Sprint / Backlog / QA Status を含む形に拡張。
- [ ] **Web UI Skeleton**: `frontend/` (React + Tailwind) と `backend/` (read-only) を最小構成で用意。

### Exit Criteria
- [ ] PO/SM/Dev/QA の入出力YAMLがテンプレートとして揃う
- [ ] `dashboard.md` がSpecに定義された形式と一致する
- [ ] Web UI が `localhost` で起動し、dashboard と queue を表示できる

## Phase 4: Workflow Integration (ワークフロー実装)

**依存関係**: Phase 1, 2, 3 すべて完了

スプリントのイベントをシミュレートするワークフローを定義。

### Tasks

- [ ] **Testing Workflow**:
  - POがSpecを作成 -> SMがタスク分解 -> Devが実装 -> QAがテスト -> POが承認 というサイクルの疎通確認。
- [ ] **Scripting Events**: 必要に応じて、定形イベント（Daily Scrum等）のトリガースクリプトを用意。

### Exit Criteria
- [ ] PO→SM→Dev/QA→SM の一連フローが手動実行で成立する

## Phase 5: Verification (検証)

**依存関係**: Phase 4 完了

実際に小さな機能を開発させ、チームが機能するか検証する。

### Tasks

- [ ] **Pilot Project**: 「Hello World Web App」等の単純な開発を指示。
- [ ] **Review**: エージェント間の連携、Specの維持、成果物の品質を確認。

### Exit Criteria
- [ ] `spec_ref` と `task_id` が実運用ログで追跡可能である
- [ ] 主要イベント（Planning/Daily/Review）が **ドキュメントで再現可能** である

## Deliverables

- `Spec.md` (Architecture & Roles)
- `Plan.md` (This file)
- `scripts/ixv_boot.sh` (Startup script)
- `instructions/*.md` (Role definitions: po.md, sm.md, dev.md, qa.md)
- `dashboard.md` (Status board)
- `frontend/` (Local Web UI: React + Tailwind)
- `backend/` (Local read-only service)
- `specs/current_spec.md` (Initial specification template)
- `specs/backlog.md` (Product backlog template)
- `queue/` (Communication buffers: po_to_sm.yaml, tasks/, reports/)
- `config/` (Project configuration files)
- `memory/` (MCP Memory directory)

## Risks / Mitigations

- **役割越権**: ファイル境界の明確化とガードレールの明文化
- **トレーサビリティ欠如**: YAMLスキーマとキーの統一
- **運用の複雑化**: 最小構成での試験導入 → 拡張
- **仕様/計画の乖離**: `Spec.md` と `Plan.md` の更新を同日に行う運用ルール

## Decisions

- `specs/current_spec.md` の最小必須セットは **Goal / Scope(Non-Goals含む) / Requirements / Acceptance Criteria / Constraints** とする。
- `type: doc` は **Phase 2/3/4** におけるドキュメント更新（指示書・テンプレート・ダッシュボード等）に用いる。仕様変更はPOが直接行い、`type: doc` には含めない。

## Traceability Rules (最小ルール)

- `request_id` は **Spec/Backlog** 側の起点として保持し、`task_id` に紐付ける
- `queue/reports/*.yaml` は必ず `task_id` を持ち、対応するタスクファイルと相互参照できる

## Validation Checklist

- [ ] 12エージェントの起動と継続稼働が確認できる
- [ ] PO/SM/Dev/QA の入出力ファイルが仕様通りに更新される
- [ ] `spec_ref` と `task_id` により追跡ができる
