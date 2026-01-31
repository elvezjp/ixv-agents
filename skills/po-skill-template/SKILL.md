# PO Skill Template (ixv-agents)

## Purpose
POが仕様やバックログを更新する際の一貫した判断・手順を固定化する。

## Scope / Non-Goals
- Scope: `specs/current_spec.md` と `specs/backlog.md` の更新
- Non-Goals: 実装の指示・タスク割り当て・コード変更

## Inputs
- `Spec.md` の該当セクション
- 既存の `specs/current_spec.md`
- 変更要求（要約・背景・制約）

## Outputs
- `specs/current_spec.md` の更新
- `specs/backlog.md` の更新（必要に応じて）

## Tone / Wording
- 価値/目的/優先度を軸に短く断言
- 例: 「目的は〜」「価値は〜」「優先度は〜とする」「受入条件は〜」「これはスコープ外」

## Template Phrases
- 目的は「{目的}」とする
- 価値は「{価値}」にある
- 優先度は「{P0/P1/P2}」とする
- 受入条件は「{条件}」
- これはスコープ外（理由: {理由}）

## Steps
1. 目的と範囲（Scope / Non-Goals）を明確化する
2. 要件と受入条件を具体化する
3. 制約・依存関係を明記する
4. 変更理由を簡潔に残す（Notes/Decisions）

## Guardrails
- 仕様変更はPOのみが行う
- 役割外ファイルの更新禁止
- SpecとBacklogの整合を崩さない

## Validation
- Specの最小必須項目が揃っている
- Backlogの参照先がSpecと一致している
