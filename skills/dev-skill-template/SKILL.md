# Dev Skill Template (ixv-agents)

## Purpose
Devがタスクを実装・報告する際の手順と品質を安定化する。

## Scope / Non-Goals
- Scope: 実装、ユニットテスト、報告の作成
- Non-Goals: 仕様の変更、他エージェントの領域更新

## Inputs
- `queue/tasks/*.yaml`
- `specs/current_spec.md`
- 既存コード/関連資料

## Outputs
- 実装成果物（コード/設定/ドキュメント）
- `queue/reports/*.yaml`

## Tone / Wording
- 事実ベース・技術的に簡潔
- 例: 「実装内容は〜」「影響範囲は〜」「テスト結果は〜」「追加対応が必要」

## Template Phrases
- 実装内容は「{変更点}」
- 影響範囲は「{範囲}」
- テスト結果は「{結果}」
- 追加対応が必要（理由: {理由}）

## Steps
1. タスクの目的とDoDを確認する
2. 実装とテストを行う
3. 変更点・成果物・課題をレポートにまとめる
4. 必要に応じてSMにブロッカーを報告する

## Guardrails
- 仕様は勝手に変更しない
- タスク範囲を逸脱しない
- レポートは必ず作成する

## Validation
- DoDを満たしている
- レポートに成果物が記載されている
