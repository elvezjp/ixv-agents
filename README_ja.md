# IXV-Agents

[English](./README.md) | [日本語](./README_ja.md)

[![Elvez](https://img.shields.io/badge/Elvez-Product-3F61A7?style=flat-square)](https://elvez.co.jp/)
[![IXV Ecosystem](https://img.shields.io/badge/IXV-Ecosystem-3F61A7?style=flat-square)](https://elvez.co.jp/ixv/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash-blue?style=flat-square&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![PowerShell](https://img.shields.io/badge/PowerShell-7+-blue?style=flat-square&logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![Stars](https://img.shields.io/github/stars/elvezjp/ixv-agents?style=social)](https://github.com/elvezjp/ixv-agents/stargazers)

仕様駆動型AI開発システム。複数のAIエージェントを固定されたロールベースのチームとして編成します。アジャイルのロールとイベントを仕様駆動開発と統合し、ガバナンス、トレーサビリティ、実用的なエンタープライズ利用を実現します。

[![IXV-Agents紹介動画](https://img.youtube.com/vi/LzGsj21opGI/maxresdefault.jpg)](https://www.youtube.com/watch?v=LzGsj21opGI)

## 特徴

- **固定ロール、進化するスキル**: 人間が意図と仕様を定義し、AIエージェントが構造化されたチームとして協働
- **仕様が唯一の信頼できる情報源**: 仕様（Spec）はリビングドキュメントであり、すべての開発のSSoT
- **ロールベースのエージェントチーム**: プロダクトオーナー、スクラムマスター、3名の開発エージェントが明確な責任境界を持つ
- **自動化されたワークフロー**: POからSMを経てDevエージェントへタスクが自動的に分解・配布
- **クロスプラットフォーム対応**: macOS（tmux）とWindows（psmux）に対応
- **複数AIエディタ対応**: OpenCodeとClaude Codeをサポート

## ユースケース

- **エンタープライズAI開発**: ガバナンスとトレーサビリティを備えた構造化されたAI駆動開発
- **仕様駆動プロジェクト**: 仕様を唯一の信頼できる情報源とするプロジェクト
- **マルチエージェント協働**: 分解されたタスクに対して複数のAIエージェントが並行開発
- **アジャイルAIワークフロー**: AIエージェントがスクラムロールを担うアジャイルスタイルの開発

## ドキュメント

- [IXV-Agents 仕様駆動開発ガイド](docs/ixv-agents-sdd-guide.md) - エージェント起動後の開発の進め方
- [SPEC.md](SPEC.md) - システムアーキテクチャ、ロール、ワークフロー、制約
- [CHANGELOG_ja.md](CHANGELOG_ja.md) - バージョン履歴
- [CONTRIBUTING_ja.md](CONTRIBUTING_ja.md) - コントリビューション方法
- [SECURITY_ja.md](SECURITY_ja.md) - セキュリティポリシー

## セットアップ

### 必要環境

- macOS / Windows
- ターミナルマルチプレクサ（[tmux](https://github.com/tmux/tmux/wiki) / [psmux](https://github.com/marlocarlo/psmux)）
- AIエディタ（以下のいずれか）
  - [OpenCode](https://github.com/anomalyco/opencode)（`opencode`）- デフォルト
  - [Claude Code](https://github.com/anthropics/claude-code)（`claude`）

### AIエディタのインストール

> **注意:** デスクトップアプリをインストールしただけでは CLI コマンド（`opencode` / `claude`）は使用できません。起動スクリプトには CLI が必要です。必ず以下の手順で CLI をインストールしてください。

**[OpenCode](https://github.com/anomalyco/opencode)**（デフォルト）

- CLI インストール: `curl -fsSL https://opencode.ai/install | bash`
- その他のインストール方法: [公式サイト](https://opencode.ai) を参照

**[Claude Code](https://github.com/anthropics/claude-code)**

- CLI インストール: `npm install -g @anthropic-ai/claude-code`
- その他のインストール方法: [公式ドキュメント](https://docs.anthropic.com/en/docs/claude-code) を参照

**確認方法:**

```bash
# OpenCode の場合
opencode --version

# Claude Code の場合
claude --version
```

### ターミナルマルチプレクサのインストール

**macOS: [tmux](https://github.com/tmux/tmux/wiki)**

- コマンドインストール: `brew install tmux`
- その他のインストール方法: [公式Wiki](https://github.com/tmux/tmux/wiki/Installing) を参照

**Windows: [psmux](https://github.com/marlocarlo/psmux)**（tmux互換）

- コマンドインストール: `irm https://raw.githubusercontent.com/marlocarlo/psmux/master/scripts/install.ps1 | iex`
- その他のインストール方法: [公式リポジトリ](https://github.com/marlocarlo/psmux) を参照
- PowerShell 7以上が必要

**確認方法:**

```bash
# macOS
tmux -V

# Windows (PowerShell)
tmux --version
```

## 使い方

### 1. エージェントの起動

**macOS:**

```bash
# OpenCodeで起動（デフォルト）
./scripts/boot.sh

# Claude Codeで起動
./scripts/boot.sh --claude-code

# モデルを指定
./scripts/boot.sh --model anthropic/claude-opus-4-5
```

**Windows (PowerShell):**

```powershell
# OpenCodeで起動（デフォルト）
.\scripts\boot.ps1

# Claude Codeで起動
.\scripts\boot.ps1 -ClaudeCode

# モデルを指定
.\scripts\boot.ps1 -Model anthropic/claude-opus-4-5
```

初回実行時、ワークスペースは自動的に初期化されます。

### 2. セッションレイアウト

単一のtmuxセッション（`ixv-agents`）が作成され、自動的にアタッチされます：

```
[ixv-agents] All Agents (5 panes)
┌─────────┬───────┬───────┬───────┐
│   PO    │ Dev1  │ Dev2  │ Dev3  │
│  (0.0)  │ (0.2) │ (0.3) │ (0.4) │
├─────────┤       │       │       │
│   SM    │       │       │       │
│  (0.1)  │       │       │       │
└─────────┴───────┴───────┴───────┘
```

**使い方：**
- **PO**（左上のペイン）に要件を伝えると、SMを経由してDevチームにタスクが割り当てられます
- その他のペイン（SM、Dev1-3）は自動で動作し、手動操作は不要です

**セッションからデタッチ：**
- `Ctrl+b d` でデタッチ（セッションはバックグラウンドで継続）

**セッションに再アタッチ：**

```bash
tmux attach-session -t ixv-agents
```

### 3. セッションの停止

```bash
# macOS
./scripts/stop.sh
./scripts/stop.sh --force    # プロセスが残っている場合は強制停止
```

```powershell
# Windows
.\scripts\stop.ps1
.\scripts\stop.ps1 -Force    # プロセスが残っている場合は強制停止
```

### 4. 新しいワークスペースのセットアップ

**macOS:**

```bash
./scripts/setup_workspace.sh

# バックアップをスキップして再初期化のみ
./scripts/setup_workspace.sh --no-backup
```

**Windows (PowerShell):**

```powershell
.\scripts\setup_workspace.ps1

# バックアップをスキップして再初期化のみ
.\scripts\setup_workspace.ps1 -NoBackup
```

既存の `workspace/` がある場合、`backups/` にバックアップされ、新しいワークスペースが作成されます。

### tmux クイックリファレンス

| アクション | コマンド |
|-----------|---------|
| セッションからデタッチ | `Ctrl+b d` |
| セッションに再アタッチ | `tmux attach-session -t ixv-agents` |
| セッション一覧 | `tmux ls` |

## エージェントチーム構成

| ロール | 人数 | 責務 |
|--------|------|------|
| プロダクトオーナー (PO) | 1 | ゴールと優先順位の定義、仕様の作成 |
| スクラムマスター (SM) | 1 | ワークフローの調整、タスクの分解と割り当て |
| 開発 (Dev) | 3 | 実装 |

## 4つの原則

1. 仕様はリビングドキュメントである
2. 仕様は唯一の信頼できる情報源（SSoT）である
3. 変更と反復を前提とする
4. AIがコストを削減し、人間が判断する

## 7つのプロセス

| # | プロセス | 出力 | 承認 |
|---|---------|------|------|
| 1 | 憲章策定 | CONSTITUTION.md | 人間 |
| 2 | 仕様策定 | README.md (SSoT) | 人間 |
| 3 | 計画 | docs/* | 人間(*) |
| 4 | タスク | queue/tasks/, dashboard.md | - |
| 5 | 実装 | コード + テスト, reports/*.yaml | - |
| 6 | 検証/受入 | dashboard.md, バックログ更新 | 人間 |
| 7 | 移行/運用 | → プロセス 2 or 4 | - |

(*) = 必要に応じて

> 各工程の詳細な流れとユーザー操作については[IXV-Agents 仕様駆動開発ガイド](docs/ixv-agents-sdd-guide.md)を参照してください。

## ディレクトリ構成

```
ixv-agents/
├── roles/              # ロール指示書（PO、SM、Dev）
├── skills/             # AI CLIスキル定義
├── templates/          # ワークスペース初期化テンプレート
│   └── queue/          # キューとレポートのテンプレート
├── scripts/            # 起動・管理スクリプト
│   ├── banner.sh / .ps1           # バナー表示
│   ├── boot.sh / .ps1             # エージェント起動
│   ├── stop.sh / .ps1             # エージェント停止
│   ├── setup_workspace.sh / .ps1  # ワークスペース初期化
│   └── tmux-help.txt              # ペイン内ヘルプテキスト
├── backups/            # ワークスペースバックアップ [.gitignore]
├── workspace/          # AIエディタ作業ディレクトリ [.gitignore]
├── docs/               # ドキュメント
├── SPEC.md             # システム仕様書
└── README.md
```

### workspace/ ディレクトリ

`workspace/` はAIエディタが実際に作業を行う隔離されたディレクトリです。エージェント間の通信は `queue/` 内のYAMLファイルで行われます。

> 詳細は[IXV-Agents 仕様駆動開発ガイド](docs/ixv-agents-sdd-guide.md#32-ワークスペース)を参照してください。

## 運用原則

- **唯一の信頼できる情報源**: 常に `workspace/README.md` を参照
- **トレーサビリティ**: `spec_ref` / `request_id` / `task_id` で追跡
- **ロール境界**: ロール範囲外のファイルへの書き込みは禁止

## セキュリティ

セキュリティに関する詳細は [SECURITY_ja.md](SECURITY_ja.md) を参照してください。

- AIエージェントは定義されたロール境界内で動作します
- ロール範囲外のファイルへの書き込みは禁止されています
- すべての変更は仕様参照とタスクIDで追跡可能です
- ワークスペースはリポジトリルートから分離されています

> **⚠ 注意:** 起動スクリプトはAIエディタに広範な権限を付与します（Claude Codeの `--dangerously-skip-permissions`、OpenCodeの全許可設定）。隔離された信頼できる環境でのみ実行してください。

## コントリビューション

コントリビューションを歓迎します。詳細は [CONTRIBUTING_ja.md](CONTRIBUTING_ja.md) を参照してください。

- バグ報告: [GitHub Issues](https://github.com/elvezjp/ixv-agents/issues)
- 機能提案: [GitHub Issues](https://github.com/elvezjp/ixv-agents/issues)
- プルリクエスト: [GitHub Pull Requests](https://github.com/elvezjp/ixv-agents/pulls)

## 変更履歴

詳細は [CHANGELOG_ja.md](CHANGELOG_ja.md) を参照してください。

## 開発の背景

本ツールは、日本語の開発文書・仕様書を対象とした開発支援AI **IXV（イクシブ）** の開発過程で生まれた小さな実用品です。

IXVでは、システム開発における日本語の文書について、理解・構造化・活用という課題に取り組んでおり、本リポジトリでは、その一部を切り出して公開しています。

## ライセンス

MIT License - 詳細は [LICENSE](LICENSE) を参照してください。

## 問い合わせ先

- **メールアドレス**: info@elvez.co.jp
- **宛先**: [株式会社Elvez](https://elvez.co.jp/)
