[English](./CHANGELOG.md) | [日本語](./CHANGELOG_ja.md)

# 変更履歴

このプロジェクトに対するすべての重要な変更はこのファイルに記録されます。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づき、
バージョン管理は [セマンティックバージョニング](https://semver.org/lang/ja/) に準拠しています。

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
| 0.1.0      | 初回パブリックリリース: ロールベースマルチエージェントシステム、7プロセスワークフロー、クロスプラットフォームサポート |
