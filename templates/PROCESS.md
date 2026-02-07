# 7つの工程と運用フロー

> **通信規約**: 工程間の指示・伝達は queue/po_to_sm.yaml（PO → SM）、queue/tasks/dev{N}.yaml（SM → Dev）、queue/reports/{task_id}.yaml（Dev → SM）を経由する。

## 1. 原則決定（Constitution）

プロジェクトの存在意義と基本原則を定める。変更は例外的。

- 入力: Human からのプロジェクト目的
- 出力: CONSTITUTION.md
- 承認: **Human**

## 2. 企画・要件定義（Specify）

Human の要望を仕様に反映する。

- 入力: Human からの要望
- 出力: README.md（Why / What / Scope / Constraints / AC）
- 承認: **Human**

## 3. 設計計画（Plan）

段階的な実行計画を立てる。単純な要件ではスキップ可。

- 入力: queue/po_to_sm.yaml
- 出力: docs/*（計画書・設計メモ）
- 承認: **Human**（必要時）
- 注意: 設計メモは補助資料。**仕様（SSoT）は README.md のみ**。重要な決定は README.md に反映する。
- 注意（必要時）: 調査が必要な場合は queue/tasks/dev{N}.yaml で Dev に依頼し、結果を queue/reports/{task_id}.yaml で受け取る。

## 4. タスク分割（Tasks）

SM が仕様をタスクに分解し、Dev に割り当てる。

- 入力: queue/po_to_sm.yaml
- 出力: queue/tasks/dev{N}.yaml, queue/dashboard.md
- 承認: なし

## 5. 実装（Implement）

Dev がタスクに従い実装する。

- 入力: queue/tasks/dev{N}.yaml
- 出力: コード + テスト, queue/reports/{task_id}.yaml
- 承認: なし

## 6. 検証・受入（Verify/Accept）

仕様と実装の整合性を確認し、受入基準に基づき検証する。

- 入力: queue/reports/*.yaml
- 出力: queue/dashboard.md（SM が更新）, README.md Backlog（SM が Status: done に更新）
- 承認: **Human**

## 7. 移行・運用（Migration/Operation）

運用からのフィードバックを適切なフェーズへ振り分ける。

- 入力: Human からのフィードバック
- 出力: queue/po_to_sm.yaml（振り分け指示 → 工程2 または 工程4）
- 承認: なし（振り分け先で承認）
