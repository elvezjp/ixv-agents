# Skill 設計ガイド（ixv-agents）

このガイドは、Claude Skills のベストプラクティスを ixv-agents 向けに整理したものです。  
主に **設計・実装・テスト・配布** の最小セットを示します。

---

## 1. 目的

- よく使う判断や手順を **再利用可能なスキル** として固定化する
- 役割（PO/SM/Dev/QA）ごとに **一貫した動作** を担保する
- 仕様主導の運用（Spec/Plan/Queue）に **適合** させる

---

## 2. スキルの粒度

以下のいずれかに該当する時にスキル化します。

- 同じ判断を **2回以上** 繰り返す
- 手順が **5ステップ以上** になり、毎回の迷いが生じる
- 役割境界・フォーマット・スキーマに **逸脱しやすい**

---

## 3. 構成（推奨テンプレ）

```
# Skill Name

## Purpose
なぜこのスキルが必要か（1-2行）

## Scope / Non-Goals
このスキルが扱う範囲 / 扱わない範囲

## Inputs
必要な入力（ファイル/パラメータ/前提）

## Outputs
期待する成果物（ファイル/更新箇所）

## Steps
手順（具体的・最小・順序を明確に）

## Guardrails
禁止事項 / 注意点 / 役割境界

## Validation
完了の確認方法
```

**テンプレートファイル**: `skills/skill-template/SKILL.md`

**役割別テンプレート**:
- `skills/po-skill-template/SKILL.md`
- `skills/sm-skill-template/SKILL.md`
- `skills/dev-skill-template/SKILL.md`
- `skills/qa-skill-template/SKILL.md`

**初期スキル例**:
- `skills/po-spec-update/SKILL.md`
- `skills/sm-task-breakdown/SKILL.md`
- `skills/dev-task-report/SKILL.md`
- `skills/qa-test-report/SKILL.md`

---

## 4. 役割別の推奨例

- **PO**: 仕様更新のチェックリスト、受入条件の整理
- **SM**: タスク分解テンプレ、優先順位付け基準
- **Dev**: 設計レビュー手順、実装前の仕様確認
- **QA**: テスト観点テンプレ、バグ報告フォーマット

---

## 5. テスト方法

- **最小ケース**: 1つの入力 → 1つの成果物で正常に動くか
- **境界ケース**: 例外/未記入/不足入力で破綻しないか
- **役割境界**: 役割外ファイルを触らないか

---

## 6. 配布と共有

- `skills/` 配下に配置し、READMEにリンクを追加
- バージョン更新は変更履歴に簡潔に追記

---

## 7. 参考リンク

- Claude Skills ガイド（公式）  
  https://claude.com/blog/complete-guide-to-building-skills-for-claude
