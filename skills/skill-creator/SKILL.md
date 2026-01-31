# Skill Creator

## Purpose

汎用的な作業パターンを再利用可能なスキルとして固定化する。

## Scope / Non-Goals

- Scope: スキルの設計・作成・保存
- Non-Goals: 仕様変更、タスク管理、実装作業

## Inputs

- スキル化候補のパターン（手順/判断基準/知識）
- `docs/skill-guide.md`（テンプレート参照）

## Outputs

- `skills/{skill-name}/SKILL.md`
- 必要に応じて `scripts/` や `resources/`

## Tone / Wording

- 簡潔・具体的に記述
- 例: 「このスキルは〜する」「対象は〜」「手順は〜」

## Steps

1. **パターンの特定**: 何が汎用的か、どこで再利用できるか
2. **スキル名の決定**: kebab-case（例: api-error-handler）
3. **テンプレートに沿って記述**: `docs/skill-guide.md` を参照
4. **保存**: `skills/{skill-name}/SKILL.md` に配置

## スキル化の基準

以下の条件を満たす場合、スキル化を検討する：

- 同じ判断を **2回以上** 繰り返す
- 手順が **5ステップ以上** になり、毎回の迷いが生じる
- 役割境界・フォーマット・スキーマに **逸脱しやすい**

## スキル構造

```
skill-name/
├── SKILL.md          # 必須
├── scripts/          # オプション（実行スクリプト）
└── resources/        # オプション（参照ファイル）
```

## 使用フロー（ixv-agents）

1. Dev/QA がスキル化候補を発見 → SM に報告
2. SM が妥当性を確認 → PO に報告
3. PO がスキル設計を承認（または修正指示）
4. PO が人間に承認を依頼（dashboard.md 経由）
5. 人間が承認
6. SM → Dev に作成を指示
7. Dev がこの skill-creator を使用してスキルを作成
8. QA がスキルの動作を確認
9. 完了報告

## Guardrails

- `docs/skill-guide.md` のテンプレートに準拠する
- 役割境界を明確にする（Scope / Non-Goals）
- 既存スキルと名前が被らないか確認する

## Validation

- テンプレートの必須セクションが揃っている
- スキルが実際に動作する（最小ケースで確認）

## Examples of Good Skills

### Example 1: API Response Handler
```markdown
---
name: api-response-handler
description: REST APIのレスポンス処理パターン。エラーハンドリング、リトライロジック、レスポンス正規化を含む。API統合作業時に使用。
---
```

### Example 2: Meeting Notes Formatter
```markdown
---
name: meeting-notes-formatter
description: 議事録を標準フォーマットに変換する。参加者、決定事項、アクションアイテムを抽出・整理。会議後のドキュメント作成時に使用。
---
```

### Example 3: Data Validation Rules
```markdown
---
name: data-validation-rules
description: 入力データのバリデーションパターン集。メール、電話番号、日付、金額などの検証ルール。フォーム処理やデータインポート時に使用。
---
```

## Reporting Format

スキル生成時は以下の形式で報告：

```
[Skill Created]
- スキル名: {name}
- 用途: {description}
- 保存先: skills/{name}/SKILL.md
```
