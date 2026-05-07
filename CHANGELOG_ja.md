[English](./CHANGELOG.md) | [日本語](./CHANGELOG_ja.md)

# 変更履歴

このプロジェクトに対するすべての重要な変更はこのファイルに記録されます。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づき、
バージョン管理は [セマンティックバージョニング](https://semver.org/lang/ja/) に準拠しています。

## [0.2.0] - 2026-05-07

ワークフロー検証層の整備リリース。既存の PO → SM → Dev ワークフローに対し、必須フィールド／Definition of Done／依存関係／タスク種別ごとのフェーズ判定の各検証ステップを明示的に組み込んだ。`0.1.0` と後方互換（スキーマ変更なし）。既存ワークスペースは `setup_workspace` を再実行することで更新後のスキル・ロール定義を取り込める。

### 追加

- リポジトリルートに `VERSION` ファイルを追加
- ワークフロー検証層 — 発行スキル側に検証ステップを組み込み（#31, #32, #33, #40）：
  - `po_to_sm.yaml` および `tasks/dev{N}.yaml` 発行時の必須フィールド／必須配列の空配列禁止チェック
  - Dev のセルフチェックおよび SM 受領時の Definition of Done 突合検証。未カバー項目がある場合は `done` を `needs_review` に降格
  - 依存関係検証：循環依存（DAG 違反）の検出、依存先タスクの状態（`done` / `in_progress` / `blocked` / `needs_review` / 不在）ごとの発行可否ルール
  - `task_type` → フェーズ判定ルール（汎用的な `feature` / `bugfix` 用の決定木を含む）
- ロールの検証義務 — PO / SM / Dev のロール指示書に各ロールの検証責任を明記（`roles/po.md`, `roles/sm.md`, `roles/dev.md`）
- スキル共通リファレンス — `skills/references/dod-verification.md`, `skills/references/dependency-validation.md`
- GitHub Actions CI — pre-commit ジョブと、Ubuntu / macOS / Windows でのワークスペースセットアップスモークテスト（`.github/workflows/ci.yml`）
- `shellcheck` による静的解析と `shfmt` による整形チェックを pre-commit / CI に統合
- ワークフロー検証層の試験項目表と試験実施結果（`docs/20260430-workflow-validation-test-cases.md`, `docs/20260430-workflow-validation-test-results.md`）
- ワークフロー検証層の整備計画書（`docs/20260430-workflow-validation-fix-plan.md`）

### 変更

- `SPEC.md` を v0.2.0 に拡張：
  - §2.3 YAML データスキーマをフィールド表（必須／任意、許容値）として整理
  - §2.4 タスク状態遷移と検証ルール（必須配列の空配列禁止、DoD 突合、必須フィールド欠落時の挙動）
  - §2.5 排他ルールと依存関係 DAG、依存先タスクの状態要件
  - §2.6 `task_type` → フェーズ判定規則（直接マッピング表 + `feature` / `bugfix` の決定木）
  - §2.7 ファイル所有権マトリクス（ロールごとの書き込み／読み取り権限）
- 検証ステップを呼び出すようスキル指示を拡充：`po-request-yaml`, `sm-receive-request`, `sm-write-task-yaml`, `sm-scan-reports`, `dev-receive-task`, `dev-write-report`
- シェルスクリプトのインデントを 2 スペースに統一（`shfmt` で pre-commit 強制）
- `gitleaks` の pre-commit フックを `v8.22.1` から `v8.30.0` に更新

### 修正

- `shellcheck` で検出された未使用のシェル変数を削除

### ドキュメント

- 公開準備ドキュメントの更新（`docs/20260304publishing-preparation.md`）
- README からの参照を新しい SPEC セクションに合わせて整合

### 既知の制限事項

- 検証は発行スキル側（プロンプトレベル）で強制される。YAML 層でのハードスキーマ検証ではないため、スキルを経由せずに発行された YAML は検証を回避し得る。
- ワークフロー検証層の異常系検証シナリオは、本リリース時点では未検証。現状は `docs/20260430-workflow-validation-test-results.md` を参照。
- `0.1.x` の項目に記載されていた「13 個の AI CLI スキル」は誤記で、実際は 12 個。`0.2.0` でスキルの追加・削除はない。

## [0.1.0] - 2026-03-04

初回パブリックリリース。

### 追加

- ロールベースのマルチエージェントチーム: プロダクトオーナー（PO）、スクラムマスター（SM）、3つの開発エージェント
- 7プロセスの仕様駆動ワークフロー（Constitution → Specify → Plan → Tasks → Implement → Verify/Accept → Migration/Op）
- tmuxベースのセッション管理と5ペインレイアウト（`boot.sh` / `boot.ps1`）
- クロスプラットフォームサポート: macOS（tmux）および Windows（psmux / PowerShell）
- 複数AIエディタサポート: OpenCode（デフォルト）および Claude Code
- ワークスペース分離（`workspace/`）- AIエディタの作業ディレクトリをリポジトリルートから分離
- YAMLベースのエージェント間通信（`queue/`）: PO→SM、SM→Dev、Dev→SM
- 開発ワークフロー全体をカバーする13のAI CLIスキル
- ワークスペースのセットアップとバックアップスクリプト（`setup_workspace.sh` / `setup_workspace.ps1`）
- グレースフルシャットダウンと強制シャットダウンに対応した停止スクリプト（`stop.sh` / `stop.ps1`）
- トークンリフレッシュの競合を防ぐ段階的エージェント起動
- クイックリファレンス用のtmuxペイン内ヘルプテキスト
- READMEにデモ動画を埋め込み

### ドキュメント

- システム仕様書（`SPEC.md`）
- 英語版README（`README.md`）と日本語版README（`README_ja.md`）
- コントリビューションガイドライン（CONTRIBUTING.md）とコードスタイル・PRガイドライン
- セキュリティポリシー（SECURITY.md）と脆弱性報告・エージェント権限の詳細

### セキュリティ

- リポジトリルートからのワークスペース分離
- エージェント指示によるロール境界の強制
- シェルスクリプトで `set -euo pipefail` を使用した厳格なエラー処理
- ユーザー提供パラメータ（例: モデル名）の入力検証
- 無関係なプロセスへの影響を防ぐ完全一致プロセス管理

### 既知の制限事項

- ワークスペース分離とロール境界は、技術的に強制されたセキュリティ境界ではなく、プロンプトベースの運用ガイドラインです
- ブートスクリプトはAIエディタに広範な権限を付与しています（Claude Codeの `--dangerously-skip-permissions`、OpenCodeの全許可）。信頼できる隔離された環境でのみ実行してください

## リンク

- [リポジトリ](https://github.com/elvezjp/ixv-agents)
- [Issues](https://github.com/elvezjp/ixv-agents/issues)

## バージョン一覧

| バージョン | 概要 |
|------------|------|
| 0.2.0      | ワークフロー検証層（必須フィールド／DoD／依存関係／フェーズ判定）、SPEC.md の拡張、GitHub Actions CI |
| 0.1.0      | 初回パブリックリリース: ロールベースマルチエージェントシステム、7プロセスワークフロー、クロスプラットフォームサポート |
