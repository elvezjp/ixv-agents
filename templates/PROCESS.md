# 7つの工程と運用フロー

> **通信規約**: 工程間の指示・伝達は queue/po_to_sm.yaml（PO → SM）、queue/tasks/dev{N}.yaml（SM → Dev）、queue/reports/{task_id}.yaml（Dev → SM）を経由する。

## 1. 原則決定（Constitution）

プロジェクトの存在意義と基本原則を定める。定義後は変更不可。

- 入力: Human からのプロジェクト目的
- 出力: queue/dashboard.md（SM）, CONSTITUTION.md（SM）
- 承認: **Human**

## 2. 企画・要件定義（Specify）

Human の要望を仕様に反映する。

- 入力: Human からの要望
- 出力: queue/dashboard.md（SM）, README.md（SM）
- 承認: **Human**

## 3. 設計計画（Plan）

実行計画を立てる。計画が長大になる場合、段階的な実行計画を作成する。

- 入力: queue/po_to_sm.yaml（PO が計画策定を依頼）
- 出力: queue/dashboard.md（SM）, docs/*（SM）, README.md（SM）
- 承認: **Human**
- 注意: 計画書・設計メモは補助資料。**仕様（SSoT）は README.md のみ**。重要な決定は README.md に反映する。

## 4. タスク分割（Tasks）

PO が計画に応じて実行を指示し、SM がタスクに分解して Dev に割り当てる。

- 入力: queue/po_to_sm.yaml（PO が実行指示）, docs/（計画書）
- 出力: queue/dashboard.md（SM）, queue/tasks/dev{N}.yaml（SM）
- 承認: なし

## 5. 実装（Implement）

Dev がタスクに従い実装する。SM が進捗を管理し、PO に報告する。

- 入力: queue/tasks/dev{N}.yaml
- 出力: コード・テスト等（Dev）, queue/reports/{task_id}.yaml（Dev）, queue/dashboard.md（Current Phase, Backlog Status, Agent Status）（SM）
- 承認: **Human**（成果物確認。完了 / 次フェーズへ / 修正指示 のいずれかを判断）

## 6. 検証・受入（Verify/Accept）

PO が検証開始を指示し、SM が仕様・計画に基づいて成果物を検証。PO が受入判断する。

- 入力: queue/po_to_sm.yaml（PO が検証開始を記録）, README.md, docs/
- 出力: queue/dashboard.md, Backlog（SM 問題なし時完了ステータスに更新）
- 承認: **Human**

## 7. 移行・運用（Migration/Operation）

運用からのフィードバックを分析し、適切なフェーズへ振り分ける。

- 入力: Human からのフィードバック
- 出力: queue/po_to_sm.yaml（PO が SM に伝達）, queue/dashboard.md（SM）
- 承認: なし（振り分け先のフェーズで承認。仕様更新必要 → 工程2、仕様変更不要 → 工程4）
