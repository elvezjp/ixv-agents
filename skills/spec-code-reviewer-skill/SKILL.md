# Spec-to-Code Semantic Review

## Purpose

設計仕様（Markdown）とソースコード実装の間のセマンティックな整合性を検証し、ロジックのギャップを特定する。

## Scope / Non-Goals

- Scope: 機能レベル/モジュールレベルのレビュー（仕様セクションと実装コードを比較）
- Non-Goals: フォーマット/スタイルチェック（linter/formatter使用）、大規模バッチ処理（専用ツール使用）

## Inputs

- **仕様書**（Markdown）
  - 要件は明示的に記述（Must/Shall/Should）
  - **要件ID**（`AUTH-001`）またはセクションヘッダーで識別
- **ソースコード**
  - 仕様を実装する関連ファイル/モジュール
  - 大きい場合はスコープを絞った抜粋とファイルパスを含める

## Outputs

- **Summary**: `Highly Consistent / Partially Consistent / Inconsistent`
- **Findings table**（各行に証拠を引用）:
  - `Requirement ID / Section`
  - `Status`（OK / NG / 要確認）
  - `Observation`（何が欠落/乖離/曖昧か、コードのどこか）
- **Suggested Improvements**: 次のアクション（実装または仕様の明確化）

## Steps

1. **入力の収集**: 仕様書とソースコードを取得
   - Excel仕様の場合: `xlsx2csv spec.xlsx | csvtomd` または Pandoc で変換
2. **コンテキスト把握**: 仕様を読み、意図、データ構造、エッジケースを理解
3. **要件IDの付与**（未付与の場合）: セクションヘッダーを識別子として使用（`[AUTH-001]`, `[API-002]`）
4. **クロスリファレンス**: 仕様の各要件を実装にマッピング
5. **分析**: 以下を検出
   - **Missing Logic**: 未実装の要件
   - **Divergent Logic**: 仕様と異なる実装
   - **Ambiguity**: 曖昧な仕様による疑わしい実装
6. **レポート生成**: ギャップと改善案を含むレポートを作成

## Guardrails

- **チャンキング戦略**（大きな入力の場合）:
  - 仕様: 対象機能に関連するセクションに絞る
  - コード: モジュール/クラス/関数境界で分割、10-20行のオーバーラップを維持
- 要件 → ファイルパス → シンボル（関数/クラス）のマッピングを安定させる
- 役割外ファイルの更新禁止

## Validation

- 全要件に対して OK/NG/要確認 のいずれかが付与されている
- Summary が適切に判定されている
- Suggested Improvements が具体的なアクションを示している

## References

- [review-criteria.md](./references/review-criteria.md)
- [case-study.md](./references/case-study.md)
- [human-in-the-loop.md](./references/human-in-the-loop.md)
- [comparison-report.md](./references/comparison-report.md)
- [comparison-report_ja.md](./references/comparison-report_ja.md)

## Execution

- [review_prompt.md](./assets/review_prompt.md)
