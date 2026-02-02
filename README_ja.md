# IXV-Agents

## 概要

**IXV-Agents** は、仕様駆動開発を実現するAI開発システムです。固定された役割ベースのチームとして複数のAIエージェントを編成し、アジャイルの役割とイベントを仕様駆動開発に統合することで、ガバナンス・トレーサビリティ・実運用性を確保します。

---

## ステータス

| 項目 | 状態 |
|------|------|
| 仕様（Spec.md） | Draft v0.3.0 |
| 実装 | 基盤完成（tmux + AI CLI + ワークスペース初期化） |

---

## コアコンセプト

**固定された役割、進化するスキル。**
人間が意図と仕様を定義し、AIエージェントは構造化されたチームとして協働します。

- **仕様（Specs）** が唯一の信頼できる情報源（Single Source of Truth）
- **役割（Roles）** による責任分担
- **イベント（Events）** によるリズム形成

---

## エージェント構成（固定）

| 役割 | 人数 | 責任 |
|------|------|------|
| Product Owner (PO) | 1 | 目標と優先順位を定義、仕様策定 |
| Scrum Master (SM) | 1 | ワークフロー統制、タスク分解・割り当て |
| Development (Dev) | 3 | 実装 |

---

## 前提条件

- macOS / Linux
- [tmux](https://github.com/tmux/tmux/wiki)
- AI CLI（以下のいずれか）
  - [OpenCode](https://github.com/opencode-ai/opencode) (`opencode`) - デフォルト
  - [Claude Code](https://github.com/anthropics/claude-code) (`claude`)
- Bash 4.0+

---

## クイックスタート

### 1. エージェントの起動

```bash
# OpenCode（デフォルト）で起動
./scripts/boot.sh

# Claude Codeで起動
./scripts/boot.sh --claude-code

# モデルを指定して起動
./scripts/boot.sh --model opus

# tmuxのみセットアップ（CLIは起動しない）
./scripts/boot.sh --setup-only
```

初回起動時は自動的にワークスペースが初期化されます。

### 2. セッションに接続

起動すると以下の2つのtmuxセッションが作成されます：

```
【ixv-manage】管理層      【ixv-dev】開発層
┌─────────────┐         ┌────┬────┬────┐
│     PO      │         │    │    │    │
├─────────────┤         │ D1 │ D2 │ D3 │
│     SM      │         │    │    │    │
└─────────────┘         └────┴────┴────┘
```

**接続コマンド（別々のターミナルで実行）：**

```bash
# 管理層（PO + SM）に接続
tmux attach-session -t ixv-manage

# 開発層（Dev1-3）に接続
tmux attach-session -t ixv-dev
```

**使い方：**
- **ixv-manage** の **PO**（上部ペイン）に要望を伝えると、SM経由でDevチームにタスクが割り当てられます
- 他のペイン（SM, Dev1-3）は自動で動作するため、操作する必要はありません

**セッションから抜ける：**
- `Ctrl+b d` でセッションをデタッチ（バックグラウンドで動作継続）

### 3. セッションの停止

```bash
# IXVセッションを停止
./scripts/stop.sh

# 全tmuxセッションを停止
./scripts/stop.sh --all-tmux
```

### 4. 新しいワークスペースのセットアップ

```bash
./scripts/setup_workspace.sh

# バックアップをスキップして初期化のみ
./scripts/setup_workspace.sh --no-backup
```

既存の `workspace/` がある場合は `backups/` にバックアップされ、新しいワークスペースが作成されます。

### tmux操作メモ

| 操作 | コマンド |
|------|----------|
| セッションをデタッチ | `Ctrl+b d` |
| セッション一覧 | `tmux ls` |
| ペイン間移動 | `Ctrl+b 矢印キー` |

---

## ディレクトリ構成

```
ixv-agents/
├── roles/              # 各ロールへの指示書 (PO, SM, Dev)
├── skills/             # AI CLIのスキル定義
├── templates/          # ワークスペース初期化用テンプレート
│   └── queue/          # キュー・レポートのテンプレート
├── scripts/            # 起動・管理スクリプト
│   ├── banner.sh       # バナー表示
│   ├── boot.sh         # エージェント起動
│   ├── flow_check.sh   # フローチェック
│   ├── stop.sh         # エージェント停止
│   └── setup_workspace.sh # ワークスペース初期化
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
