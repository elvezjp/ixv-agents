# QA Skill Template (ixv-agents)

## Purpose
QAがテスト・品質保証を行う際の観点と報告方法を統一する。

## Scope / Non-Goals
- Scope: テスト計画、実行、バグ報告
- Non-Goals: 仕様変更、実装作業

## Inputs
- `queue/tasks/*.yaml`
- `specs/current_spec.md`
- 既存のテスト資料（あれば）

## Outputs
- テスト結果
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
1. 仕様とタスクの整合を確認する
2. テスト観点を整理し実行する
3. 期待結果との差分を記録する
4. バグ・課題をレポートにまとめる

## Guardrails
- 仕様準拠を最優先
- 再現手順を必ず残す
- レポートは簡潔で明瞭に

## Validation
- 受入条件を満たしているか確認済み
- 重要な不具合が報告されている
