# ディレクトリ構成変更計画書

## 概要

AIエディタの作業ディレクトリを分離し、ツールリポジトリと成果物を明確に区別する。

## 課題

現在の構成では以下の問題がある：

1. AIエディタがリポジトリのREADMEなど関係ないファイルにアクセスできてしまう
2. AIエディタの成果物（実装されたプログラムなど）がリポジトリルートに作成されてしまう
3. ツールのコードと作業データが混在している

## 現在のディレクトリ構成

```
20260130ixv-agents/
├── .claude/
│   ├── settings.local.json
│   └── skills -> ../skills
├── .opencode/
│   ├── .gitignore
│   ├── bun.lock
│   ├── node_modules/
│   ├── package.json
│   └── skills -> ../skills
├── .gitignore
├── README.md
├── README_ja.md
├── Spec.md
├── config/
│   └── settings.yaml
├── docs/
├── instructions/
│   ├── po.md
│   ├── sm.md
│   └── dev.md
├── logs/
│   └── backup_YYYYMMDD_HHMMSS/
├── queue/
│   ├── po_to_sm.yaml
│   ├── tasks/
│   └── reports/
├── scripts/
│   ├── boot.sh
│   └── setup_workdir.sh
└── skills/
    ├── po-request-yaml/
    ├── sm-task-breakdown/
    ├── dev-task-report/
    └── ...
```

## 新しいディレクトリ構成

```
20260130ixv-agents/
├── .gitignore                    # workspace/, backups/ を除外
├── README.md
├── README_ja.md
├── Spec.md
├── config/
│   └── settings.yaml
├── docs/
├── instructions/                 # [読み取り専用] ツールの一部
│   ├── po.md
│   ├── sm.md
│   └── dev.md
├── scripts/
│   ├── boot.sh
│   └── setup_workdir.sh
├── skills/                       # [読み取り専用] ツールの一部
│   ├── po-request-yaml/
│   ├── sm-task-breakdown/
│   ├── dev-task-report/
│   └── ...
│
├── backups/                      # [.gitignore] バックアップ保存先
│   └── backup_YYYYMMDD_HHMMSS/
│       ├── dashboard.md
│       ├── queue/
│       └── specs/
│
└── workspace/                    # [.gitignore] AIエディタの作業ディレクトリ
    ├── .claude/
    │   ├── settings.local.json
    │   └── skills -> ../../skills    (symlink)
    ├── .opencode/
    │   ├── .gitignore
    │   ├── bun.lock
    │   ├── node_modules/
    │   ├── package.json
    │   └── skills -> ../../skills    (symlink)
    ├── instructions -> ../instructions   (symlink)
    ├── queue/
    │   ├── po_to_sm.yaml
    │   ├── tasks/
    │   │   └── dev1-8.yaml
    │   └── reports/
    │       └── TEMPLATE.yaml
    ├── specs/
    │   ├── current_spec.md
    │   └── backlog.md
    ├── dashboard.md
    └── (成果物: src/, tests/, etc.)
```

## シンボリックリンク一覧

| リンクパス | リンク先 | 用途 |
|------------|----------|------|
| `workspace/instructions` | `../instructions` | 役割定義の参照 |
| `workspace/.claude/skills` | `../../skills` | Claude Code用スキル |
| `workspace/.opencode/skills` | `../../skills` | OpenCode用スキル |

## .gitignore の変更

```gitignore
# 作業ディレクトリ（成果物含む）
workspace/

# バックアップ
backups/

# 旧ディレクトリ（移行後に削除）
logs/
queue/
.claude/
.opencode/
```

## 移行手順

### Phase 1: 準備

1. [ ] 現在の作業データをバックアップ
2. [ ] `.gitignore` を更新

### Phase 2: ディレクトリ作成

3. [ ] `backups/` ディレクトリを作成
4. [ ] `workspace/` ディレクトリを作成
5. [ ] `workspace/.claude/` ディレクトリを作成
6. [ ] `workspace/.opencode/` ディレクトリを作成

### Phase 3: シンボリックリンク作成

7. [ ] `workspace/instructions -> ../instructions` を作成
8. [ ] `workspace/.claude/skills -> ../../skills` を作成
9. [ ] `workspace/.opencode/skills -> ../../skills` を作成

### Phase 4: 設定ファイル移動

10. [ ] `.claude/settings.local.json` を `workspace/.claude/` に移動
11. [ ] `.opencode/` の設定ファイルを `workspace/.opencode/` に移動

### Phase 5: スクリプト更新

12. [ ] `scripts/setup_workdir.sh` を更新
    - 作業ディレクトリを `./workspace/` に変更
    - バックアップ先を `./backups/` に変更
    - シンボリックリンク作成処理を追加
13. [ ] `scripts/boot.sh` を更新
    - AIエディタの作業ディレクトリを `$ROOT_DIR/workspace` に変更

### Phase 6: クリーンアップ

14. [ ] 旧ディレクトリを削除（ルートの queue/, logs/, .claude/, .opencode/）
15. [ ] 動作確認

## スクリプト変更詳細

### setup_workdir.sh の変更点

```bash
# 変更前
BACKUP_DIR="./logs/backup_$(date '+%Y%m%d_%H%M%S')"
# 作業ファイルはルートに作成

# 変更後
BACKUP_DIR="./backups/backup_$(date '+%Y%m%d_%H%M%S')"
WORKSPACE_DIR="./workspace"
# 作業ファイルは $WORKSPACE_DIR 内に作成

# シンボリックリンク作成を追加
ln -sfn ../instructions "$WORKSPACE_DIR/instructions"
ln -sfn ../../skills "$WORKSPACE_DIR/.claude/skills"
ln -sfn ../../skills "$WORKSPACE_DIR/.opencode/skills"
```

### boot.sh の変更点

```bash
# 変更前
tmux send-keys -t "ixv-po:0.0" "cd $ROOT_DIR && ..."

# 変更後
WORKSPACE_DIR="$ROOT_DIR/workspace"
tmux send-keys -t "ixv-po:0.0" "cd $WORKSPACE_DIR && ..."
```

## 影響範囲

| ファイル | 変更内容 |
|----------|----------|
| `scripts/setup_workdir.sh` | workspace/配下に作業ファイルを作成、シンボリックリンク作成 |
| `scripts/boot.sh` | 作業ディレクトリを workspace/ に変更 |
| `.gitignore` | workspace/, backups/ を追加 |
| `instructions/*.md` | パス参照の確認（変更不要の見込み） |

## ロールバック手順

問題が発生した場合：

1. `backups/` から最新のバックアップを復元
2. git で変更をrevert
3. 旧ディレクトリ構成に戻す

## 備考

- AIエディタは `workspace/` 内で作業するため、リポジトリのREADME等にはアクセスしにくくなる
- 成果物は `workspace/` 内に作成されるため、必要に応じて手動で取り出す
- skills, instructions はシンボリックリンク経由で参照するため、ツール側の更新が即座に反映される
