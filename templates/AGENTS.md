<!--
IMPORTANT:
This file defines AI agent behavior rules.
Modify only via Issue + PR approval.
-->

# ixv-agents 行動規範（AI向け）

## 参照順序（必須）
1. CONSTITUTION.md
2. README.md
3. PROCESS.md
4. roles/*

## 基本ルール
- README.mdが唯一の仕様（Single Source of Truth）
- 仕様を読まずに実装しない
- Issueで合意 → PRで承認 → README更新
- AI出力は必ず人間がレビュー
- 補助ドキュメント（設計メモ等）は作ってよいが、重要な決定はREADMEへ要点を反映する（READMEに無い内容を仕様として扱わない）

## OpenCode前提
- 1体のエージェント = 1つのOpenCodeが動くターミナル
- エージェント間の共有はIssue/PRコメントで行う
- 他エージェントの状態を推測しない

## 禁止事項
- CONSTITUTION.mdの無断変更
- README.mdを更新せずに実装を進めること
- Issue無しの仕様変更

---

## 変更時のテンプレ（運用仕様）
- IssueのDecision更新 → PR本文へ転記
- README / PROCESS / AGENTS の整合性を必ず確認
