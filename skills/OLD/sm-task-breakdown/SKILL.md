# SM Skill: Task Breakdown

## Purpose
Specからタスクへ分解し、YAMLで整合性を保つ。

## Scope / Non-Goals
- Scope: `queue/tasks/*.yaml` の作成/更新
- Non-Goals: 仕様変更、実装作業

## Inputs
- `queue/po_to_sm.yaml`
- `specs/current_spec.md`

## Outputs
- `queue/tasks/*.yaml`

## Tone / Wording
- 手順/合意/進捗を明確にする
- 例: 「次のステップは〜」「ブロッカーは〜」「合意事項として〜」「進捗は〜」

## Template Phrases
- 次のステップは「{ステップ}」
- ブロッカーは「{内容}」
- 合意事項として「{内容}」
- 進捗は「{状況}」

## Steps
1. Specの要件/受入条件を抽出する
2. タスクに分割し `definition_of_done` を付ける
3. `task_id` / `spec_ref` / `assignee` を記入する

## Guardrails
- タスク粒度は実行可能な最小単位
- 役割境界の遵守

## Validation
- 必須項目が全て存在する
