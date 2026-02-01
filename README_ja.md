# IXV-Agents

## 概要

**IXV-Agents** は、仕様主導のAI開発システムです。固定された役割ベースのチームとして複数のAIエージェントを編成し、アジャイルの役割とイベントを仕様主導開発に統合することで、ガバナンス・トレーサビリティ・実運用性を確保します。

---

## ステータス

| 項目 | 状態 |
|------|------|
| 仕様（Spec.md） | Draft v0.2.0 |
| 実装 | 基盤完成（tmux + AI CLI） |

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
| Development (Dev) | 8 | 実装 |

---

## 前提条件

- macOS / Linux
- tmux
- AI CLI（以下のいずれか）
  - [OpenCode](https://github.com/opencode-ai/opencode) (`opencode`) - デフォルト
  - [Claude Code](https://github.com/anthropics/claude-code) (`claude`)
- Bash 4.0+

---

## クイックスタート

### 1. ワークスペースの初期化

```bash
./scripts/setup_workdir.sh
```

これにより `workspace/` ディレクトリが作成され、テンプレートから初期ファイルが配置されます。
既存の `workspace/` がある場合は `backups/` にバックアップされます。

### 2. エージェントの起動

```bash
# OpenCode（デフォルト）で起動
./scripts/boot.sh

# Claude Codeで起動
./scripts/boot.sh --claude-code

# モデルを指定して起動
./scripts/boot.sh --model opus
```

起動すると以下のtmuxセッションが作成されます：
- **ixv-po**: Product Owner用（1ペイン）
- **ixv-agents**: SM + Dev1-Dev8用（3x3グリッド）

### 3. POに接続して開発を開始

```bash
tmux attach-session -t ixv-po
```

POに要望を伝えると、SM経由でDevチームにタスクが割り当てられます。

### 4. エージェントチームを確認

```bash
tmux attach-session -t ixv-agents
```

### 5. セッションの停止

```bash
# IXVセッションを停止
./scripts/stop.sh

# 全tmuxセッションを停止
./scripts/stop.sh --all-tmux
```

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
├── instructions/       # 各ロールへの指示書 (PO, SM, Dev)
├── skills/             # AI CLIのスキル定義
├── templates/          # ワークスペース初期化用テンプレート
├── scripts/            # 起動・管理スクリプト
│   ├── boot.sh         # エージェント起動
│   ├── stop.sh         # エージェント停止
│   └── setup_workdir.sh # ワークスペース初期化
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
├── instructions -> ../instructions  (symlink)
├── .claude/skills -> ../../skills   (symlink)
├── .opencode/skills -> ../../skills (symlink)
├── specs/              # 仕様書 (Single Source of Truth)
│   ├── current_spec.md
│   └── backlog.md
├── queue/              # エージェント間通信
│   ├── po_to_sm.yaml   # PO -> SM
│   ├── tasks/          # SM -> Dev
│   └── reports/        # Dev -> SM
├── dashboard.md        # プロジェクト状況ボード
└── (成果物)            # 実装コード、テスト等
```

---

## 運用原則

- **Single Source of Truth**: `workspace/specs/current_spec.md` を必ず参照
- **Traceability**: `spec_ref` / `request_id` / `task_id` で追跡
- **Role Boundaries**: 役割外のファイル更新は禁止

---

## 主要ドキュメント

- `Spec.md`: システム構成、役割、ワークフロー、制約
- `docs/skill-guide.md`: ixv-agents 向けスキル設計ガイド

---

## ライセンス

TBD
