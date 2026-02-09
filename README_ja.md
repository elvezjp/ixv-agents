# IXV-Agents

## 概要

**IXV-Agents** は、仕様駆動開発を実現するAI開発システムです。固定された役割ベースのチームとして複数のAIエージェントを編成し、アジャイルの役割とイベントを仕様駆動開発に統合することで、ガバナンス・トレーサビリティ・実運用性を確保します。

---

## コアコンセプト

**固定された役割、進化するスキル。**
人間が意図と仕様を定義し、AIエージェントは構造化されたチームとして協働します。

- **仕様（Specs）** が唯一の信頼できる情報源（Single Source of Truth）
- **役割（Roles）** による責任分担
- **イベント（Events）** によるリズム形成

---

## センチネル構成（計画）

Mac Studio（512GB）1台に1つ、24時間稼働のローカルエージェント **Sentinel** を導入する計画です。Sentinel はローカル LLM（Brain）で自律的に動作し、既存の API エージェント（PO/SM/Dev）を必要な時だけ起動します。Sentinel は独立した Python アプリケーションであり、フレームワークやクラス階層は導入しません。

```
Mac Studio 512GB（24時間稼働）
│
├── Sentinel（ローカル LLM、常時起動、API コスト $0）
│   ├── Brain: MLX で 70B クラスを常時ロード
│   ├── Heartbeat: 全エージェントの生存確認・同期
│   ├── Doc Triage: ドキュメント構造解析・重要ページ特定
│   └── Machine Monitor: マシン全体の監視（プロセス/リソース/FS）
│
├── PO Agent  (Claude Code CLI / API)  ← オンデマンド
├── SM Agent  (Claude Code CLI / API)  ← オンデマンド
├── Dev1〜3   (Claude Code CLI / API)  ← オンデマンド
│
├── Cursor (リポジトリ A)  ← Sentinel が監視
├── Cursor (リポジトリ B)  ← Sentinel が監視
└── その他プロセス          ← Sentinel が監視
```

既存の動作（`roles/*.md`, YAML キュー, `scripts/*.sh`, tmux）は変更しない。Sentinel は追加であり、なくても従来通り運用可能。Heartbeat は全エージェント共通の YAML スキーマで、Sentinel が読み取り、PO/SM/Dev が書き込みます。

計画書: `docs/20260209-baseagent-plan.md`

---

## 4つの原則

1. 仕様は「生きたドキュメント」である
2. 仕様は「信頼できる唯一の情報源（SSoT）」とする
3. 仕様は「変更と反復が前提」とする
4. AIでコストを抑えて実現する（人間が最終判断）

---

## 7つの工程

| # | 工程 | 成果物 | 承認 |
|---|------|--------|------|
| 1 | Constitution（原則決定） | CONSTITUTION.md | Human |
| 2 | Specify（企画・要件定義） | README.md (SSoT) | Human |
| 3 | Plan（設計計画） | docs/* | Human(*) |
| 4 | Tasks（タスク分割） | queue/tasks/, dashboard.md | - |
| 5 | Implement（実装） | コード + テスト, reports/*.yaml | - |
| 6 | Verify/Accept（検証・受入） | dashboard.md, Backlog更新 | Human |
| 7 | Migration/Op（移行・運用） | → 工程2 または 工程4 | - |

(*) = 必要時のみ

> 詳細は `templates/PROCESS.md` を参照。

---

## エージェント構成（固定）

| 役割 | 人数 | ランタイム | 責任 |
|------|------|-----------|------|
| Sentinel | 1 | ローカル LLM（24時間） | 監視、トリアージ、ルーティング、API エージェント起動 |
| Product Owner (PO) | 1 | API（オンデマンド） | 目標と優先順位を定義、仕様策定 |
| Scrum Master (SM) | 1 | API（オンデマンド） | ワークフロー統制、タスク分解・割り当て |
| Development (Dev) | 3 | API（オンデマンド） | 実装 |

---

## 前提条件

- macOS / Windows
- ターミナルマルチプレクサ（[tmux](https://github.com/tmux/tmux/wiki) / [psmux](https://github.com/marlocarlo/psmux)）
- AIエディタ（以下のいずれか）
  - [OpenCode](https://github.com/anomalyco/opencode) (`opencode`) - デフォルト
  - [Claude Code](https://github.com/anthropics/claude-code) (`claude`)

---

## セットアップ

### AIエディタ

以下のいずれかをインストールしてください。

**[OpenCode](https://github.com/anomalyco/opencode)**（デフォルト）

- デスクトップアプリ: [opencode.ai/download](https://opencode.ai/download) からダウンロード
- コマンドでインストール: `curl -fsSL https://opencode.ai/install | bash`
- その他のインストール方法は [公式サイト](https://opencode.ai) を参照

**[Claude Code](https://github.com/anthropics/claude-code)**

- デスクトップアプリ: [claude.ai/download](https://claude.ai/download) からダウンロード
- コマンドでインストール: `curl -fsSL https://claude.ai/install.sh | bash`
- その他のインストール方法は [公式ドキュメント](https://code.claude.com/docs/en/overview) を参照

### ターミナルマルチプレクサ

**macOS: [tmux](https://github.com/tmux/tmux/wiki)**

- コマンドでインストール: `brew install tmux`
- その他のインストール方法は [公式Wiki](https://github.com/tmux/tmux/wiki/Installing) を参照

**Windows: [psmux](https://github.com/marlocarlo/psmux)**（tmux 互換）

- コマンドでインストール: `irm https://raw.githubusercontent.com/marlocarlo/psmux/master/scripts/install.ps1 | iex`
- その他のインストール方法は [公式リポジトリ](https://github.com/marlocarlo/psmux) を参照
- PowerShell 7+ が必要です

---

## 使い方

### 1. エージェントの起動

**macOS:**

```bash
# OpenCode（デフォルト）で起動
./scripts/boot.sh

# Claude Codeで起動
./scripts/boot.sh --claude-code

# モデルを指定して起動
./scripts/boot.sh --model anthropic/claude-opus-4-5
```

**Windows (PowerShell):**

```powershell
# OpenCode（デフォルト）で起動
.\scripts\boot.ps1

# Claude Codeで起動
.\scripts\boot.ps1 -ClaudeCode

# モデルを指定して起動
.\scripts\boot.ps1 -Model anthropic/claude-opus-4-5
```

初回起動時は自動的にワークスペースが初期化されます。

### 2. セッション構成

起動すると1つのtmuxセッション（`ixv-agents`）が作成され、自動的に接続されます：

```
【ixv-agents】全エージェント（5ペイン）
┌─────────┬───────┬───────┬───────┐
│   PO    │ Dev1  │ Dev2  │ Dev3  │
│  (0.0)  │ (0.2) │ (0.3) │ (0.4) │
├─────────┤       │       │       │
│   SM    │       │       │       │
│  (0.1)  │       │       │       │
└─────────┴───────┴───────┴───────┘
```

**使い方：**
- **PO**（左上ペイン）に要望を伝えると、SM経由でDevチームにタスクが割り当てられます
- 他のペイン（SM, Dev1-3）は自動で動作するため、操作する必要はありません

**セッションから抜ける：**
- `Ctrl+b d` でセッションをデタッチ（バックグラウンドで動作継続）

**セッションに再接続：**

```bash
tmux attach-session -t ixv-agents
```

### 3. セッションの停止

```bash
# macOS
./scripts/stop.sh
./scripts/stop.sh --force    # プロセスが残った場合
```

```powershell
# Windows
.\scripts\stop.ps1
.\scripts\stop.ps1 -Force    # プロセスが残った場合
```

### 4. 新しいワークスペースのセットアップ

**macOS:**

```bash
./scripts/setup_workspace.sh

# バックアップをスキップして初期化のみ
./scripts/setup_workspace.sh --no-backup
```

**Windows (PowerShell):**

```powershell
.\scripts\setup_workspace.ps1

# バックアップをスキップして初期化のみ
.\scripts\setup_workspace.ps1 -NoBackup
```

既存の `workspace/` がある場合は `backups/` にバックアップされ、新しいワークスペースが作成されます。

### tmux操作メモ

| 操作 | コマンド |
|------|----------|
| セッションをデタッチ | `Ctrl+b d` |
| セッションに再接続 | `tmux attach-session -t ixv-agents` |
| セッション一覧 | `tmux ls` |

---

## ディレクトリ構成

```
ixv-agents/
├── roles/              # 各ロールへの指示書 (PO, SM, Dev)
├── skills/             # AI CLIのスキル定義
├── templates/          # ワークスペース初期化用テンプレート
│   └── queue/          # キュー・レポートのテンプレート
├── scripts/            # 起動・管理スクリプト
│   ├── banner.sh / .ps1           # バナー表示
│   ├── boot.sh / .ps1             # エージェント起動
│   ├── stop.sh / .ps1             # エージェント停止
│   ├── setup_workspace.sh / .ps1  # ワークスペース初期化
│   └── tmux-help.txt              # ペイン内ヘルプテキスト
├── OLD/                # 旧資産（参考用）
├── backups/            # ワークスペースのバックアップ [.gitignore]
├── workspace/          # AIエディタの作業ディレクトリ [.gitignore]
├── docs/               # ドキュメント
├── Spec.md             # システム仕様書
└── README.md
```

### workspace/ ディレクトリ

`workspace/` はAIエディタが実際に作業を行うディレクトリです。
リポジトリルートとは分離されており、AIエディタがツールのREADME等にアクセスすることを防ぎます。

```
workspace/
├── README.md           # 仕様書（Single Source of Truth）
├── CONSTITUTION.md     # プロジェクト憲章
├── PROCESS.md          # 工程と運用フロー
├── AGENTS.md           # AI行動規範
├── roles -> ../roles  (symlink)
├── .claude/skills -> ../../skills   (symlink)
├── .opencode/skills -> ../../skills (symlink)
├── queue/              # エージェント間通信
│   ├── dashboard.md    # プロジェクト状況ボード
│   ├── po_to_sm.yaml   # PO -> SM
│   ├── tasks/          # SM -> Dev
│   └── reports/        # Dev -> SM
└── (成果物)            # 実装コード、テスト等
```

---

## 運用原則

- **Single Source of Truth**: `workspace/README.md` を必ず参照
- **Traceability**: `spec_ref` / `request_id` / `task_id` で追跡
- **Role Boundaries**: 役割外のファイル更新は禁止

---

## 主要ドキュメント

- `Spec.md`: システム構成、役割、ワークフロー、制約
- `docs/20260129implementation-plan.md`: 実装計画
- `docs/20260201directory-restructure-plan.md`: ディレクトリ再編計画

---

## ライセンス

TBD
