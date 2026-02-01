# 7つの工程と運用フロー

## 1. 原則決定（Constitution）
- 出力: CONSTITUTION.md
- 変更は例外。POが指示し、人間（ユーザー）が最終承認。

## 2. 企画・要件定義（Specify）
- 出力: README.md（Why/What/Scope/Constraints/AC）

## 3. 設計計画（Plan）
- 出力: 必要に応じて設計メモ（docs/ など）
- 注意: 設計メモは補助資料。**仕様（SSoT）はREADME.mdのみ**。重要な決定はREADMEに要点を反映する。

## 4. タスク分割（Tasks）
- 出力: queue/tasks/dev{N}.yaml
- SMがPOの指示を分解し、各Devに割り当て

## 5. 実装（Implement）
- 出力: コード + 仕様更新
- DevがSMの指示に従い実行

## 6. 検証・受入（Verify/Accept）
- 仕様と実装の整合性確認
- 受入基準に基づく検証

## 7. 移行・運用（Migration/Operation）
- 運用からの学びを仕様へ反映
