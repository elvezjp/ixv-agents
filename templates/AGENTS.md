<!--
IMPORTANT:
This file defines AI agent behavior rules.
Modify only via PO approval.
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
- POが指示 → SMがタスク分解・実行 → dashboard更新
- AI出力は必ず人間がレビュー
- 補助ドキュメント（設計メモ等）は作ってよいが、重要な決定はREADMEへ要点を反映する（READMEに無い内容を仕様として扱わない）

## ガバナンスと責任
- 最終判断: プロダクトオーナー（PO）
- 運用監督: スクラムマスター（SM）
- 実行責任: デベロッパー（Dev）

## 合意形成と承認
- 指示は PO が `queue/po_to_sm.yaml` で発行する
- 決定事項は SM が `queue/dashboard.md` に記録する
- 最終承認は人間（ユーザー）が行う

## マルチエージェント前提
- 1体のエージェント = 1つのAIエディタが動くターミナル
- エージェント間の共有はqueue/*.yaml、queue/*.md で行う
- 他エージェントの状態を推測しない

## 禁止事項
- CONSTITUTION.mdの無断変更
- README.mdを更新せずに実装を進めること
