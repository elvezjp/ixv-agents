# Dev Skill: Task Report

## Purpose
実装結果を `queue/reports/*.yaml` に統一形式で報告する。

## Scope / Non-Goals
- Scope: 実装結果の報告
- Non-Goals: 仕様変更、SM/QAの作業領域更新

## Inputs
- `queue/tasks/*.yaml`
- 実装結果（変更点/成果物/課題）

## Outputs
- `queue/reports/*.yaml`

## Tone / Wording
- 事実ベースで簡潔に報告
- 例: 「実装内容は〜」「影響範囲は〜」「テスト結果は〜」「追加対応が必要」

## Template Phrases
- 実装内容は「{変更点}」
- 影響範囲は「{範囲}」
- テスト結果は「{結果}」
- 追加対応が必要（理由: {理由}）

## Steps
1. `task_id` を確認する
2. `status` と `summary` を記入する
3. `changes` / `artifacts` / `issues` を箇条書きで埋める

## Guardrails
- 役割外ファイルを更新しない
- レポートを省略しない

## Validation
- 必須項目が埋まっている
