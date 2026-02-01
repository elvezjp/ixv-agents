# PO Skill: Spec Update

## Purpose
`specs/current_spec.md` を一貫した品質で更新する。

## Scope / Non-Goals
- Scope: Specの更新、Backlogの整合確認
- Non-Goals: タスク割り当て、実装指示

## Inputs
- 変更要求（要約/背景/制約）
- 既存の `specs/current_spec.md`
- `specs/backlog.md`

## Outputs
- 更新済み `specs/current_spec.md`
- 必要に応じて更新された `specs/backlog.md`

## Tone / Wording
- 価値/優先度/受入条件を明確に断言
- 例: 「目的は〜」「優先度は〜とする」「受入条件は〜」「これはスコープ外」

## Template Phrases
- 目的は「{目的}」とする
- 優先度は「{P0/P1/P2}」とする
- 受入条件は「{条件}」
- これはスコープ外（理由: {理由}）

## Steps
1. Goal / Scope / Requirements / Acceptance Criteria / Constraints を埋める
2. 変更理由を Notes に短く残す
3. Backlog の Spec Ref を確認する

## Guardrails
- 仕様変更はPOのみ
- 役割外ファイルの更新禁止

## Validation
- 最小必須セクションが揃っている
- Backlog 参照が一致している
