# QA Skill: Test Report

## Purpose
テスト結果を一貫した形式で報告する。

## Scope / Non-Goals
- Scope: テスト実行と報告
- Non-Goals: 仕様変更、実装作業

## Inputs
- `queue/tasks/*.yaml`
- テスト結果

## Outputs
- `queue/reports/*.yaml`

## Tone / Wording
- 客観/再現性/差分を重視
- 例: 「再現手順は〜」「期待結果は〜」「実測結果は〜」「受入条件に未達」

## Template Phrases
- 再現手順は「{手順}」
- 期待結果は「{期待}」
- 実測結果は「{実測}」
- 受入条件に未達（理由: {理由}）

## Steps
1. 受入条件の観点でテストを実行する
2. `status` と `summary` を記入する
3. `issues` と再現手順を明記する

## Guardrails
- 仕様準拠を最優先
- レポートは簡潔に

## Validation
- 受入条件の確認ができている
