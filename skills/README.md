# Skills ディレクトリについて

本ディレクトリには、IXV-Agents のエージェントが使用するスキル定義が格納されています。

## スキルとは

各スキルは [Claude Code のカスタムスラッシュコマンド](https://docs.anthropic.com/en/docs/claude-code/skills)に準拠しており、`SKILL.md` ファイルにスキルの名前・説明・実行手順を定義しています。

```
skills/
├── po-request-yaml/        # PO用スキル
│   ├── SKILL.md             # スキル定義（YAML Front Matter + 手順）
│   └── references/          # スキル固有の参照資料
├── sm-write-task-yaml/      # SM用スキル
│   └── SKILL.md
├── dev-receive-task/        # Dev用スキル
│   └── SKILL.md
├── references/              # スキル間で共有する参照資料
│   ├── phase-gate.md
│   └── task-yaml-schema.md
└── README.md                # 本ファイル
```

## ワークスペースでの利用

ワークスペース初期化時に、`workspace/.claude/skills` および `workspace/.opencode/skills` からシンボリックリンクが作成されます。これにより、各ペインで起動した AI エディタがスキルをスラッシュコマンドとして認識し、エージェントのワークフロー内で自動的に呼び出します。

エージェントがスキルを使ってどのように開発を進めるかの全体像は、[IXV-Agents 仕様駆動開発ガイド](../docs/ixv-agents-sdd-guide.md)を参照してください。

---

## 7工程とスキル対応表

| 工程 | 名称 | PO スキル | SM スキル | Dev スキル |
|------|------|-----------|-----------|------------|
| 1 | 原則決定（Constitution） | `po-check-constitution` → `po-request-yaml` | `sm-receive-request` → `sm-update-spec` | - |
| 2 | 企画・要件定義（Specify） | `po-check-spec` → `po-request-yaml` | `sm-receive-request` → `sm-update-spec` | - |
| 3 | 設計計画（Plan） | `po-request-yaml` | `sm-receive-request` → `sm-write-task-yaml`（調査）→ `sm-update-spec` | `dev-receive-task` → `dev-write-report` → `dev-notify-sm` |
| 4 | タスク分割（Tasks） | `po-request-yaml` | `sm-receive-request` → `sm-write-task-yaml` | - |
| 5 | 実装（Implement） | - | `sm-scan-reports` | `dev-receive-task` → `dev-write-report` → `dev-notify-sm` |
| 6 | 検証・受入（Verify/Accept） | `po-request-yaml` → `po-verify-acceptance` | `sm-receive-request` → 検証 → `sm-update-spec`（Backlog） | - |
| 7 | 移行・運用（Migration/Op） | `po-request-yaml` | `sm-receive-request`（振り分け） | - |

### 横断スキル（工程共通）

| スキル | 用途 |
|--------|------|
| `spec-code-reviewer-skill` | 仕様とコードのセマンティック整合性レビュー |

## データフロー

```
PO                          SM                          Dev
 │                           │                           │
 │  queue/po_to_sm.yaml      │                           │
 │ ────────────────────────► │                           │
 │  (po-request-yaml)        │  queue/tasks/dev{N}.yaml  │
 │                           │ ────────────────────────► │
 │                           │  (sm-write-task-yaml)      │
 │                           │                           │
 │                           │  queue/reports/{id}.yaml   │
 │                           │ ◄──────────────────────── │
 │                           │  (dev-write-report)        │
 │                           │                           │
 │  send-keys (通知)          │  send-keys (通知)          │
 │ ◄──────────────────────── │ ◄──────────────────────── │
 │  (sm → po)                │  (dev-notify-sm)           │
```

## スキル実行フロー（全体像）

```
[Human] 要望
    │
    ▼
┌─ 工程1: 原則決定 ─────────────────────────────────────────┐
│  PO: po-check-constitution                                │
│    ├─ 記入済み → 工程2へ                                   │
│    └─ 未記入 → po-request-yaml (constitution_update)       │
│         └─ SM: sm-receive-request → sm-update-spec         │
│              └─ PO → [Human] ★ 憲章承認                    │
└───────────────────────────────────────────────────────────┘
    │
    ▼
┌─ 工程2: 企画・要件定義 ──────────────────────────────────┐
│  PO: po-check-spec                                        │
│    ├─ 反映済み → 工程3へ                                   │
│    └─ 未反映 → po-request-yaml (spec_update)               │
│         └─ SM: sm-receive-request → sm-update-spec         │
│              └─ PO → [Human] ★ 仕様承認                    │
└───────────────────────────────────────────────────────────┘
    │
    ▼
┌─ 工程3: 設計計画 ────────────────────────────────────────┐
│  PO: po-request-yaml (plan)                               │
│  SM: sm-receive-request                                    │
│    ├─ 単純 → SM が直接計画策定                              │
│    └─ 複雑 → sm-write-task-yaml (調査タスク)               │
│         └─ Dev: dev-receive-task → 調査 → dev-write-report │
│              └─ dev-notify-sm → SM: sm-scan-reports        │
│  SM: docs/ に計画作成 → sm-update-spec (README 詳細化)     │
│  PO → [Human] ★ 計画承認                                  │
└───────────────────────────────────────────────────────────┘
    │
    ▼
┌─ 工程4: タスク分割 ──────────────────────────────────────┐
│  PO: po-request-yaml (execute)                            │
│  SM: sm-receive-request → sm-write-task-yaml              │
│    └─ queue/tasks/dev{N}.yaml を生成 → Dev に send-keys    │
└───────────────────────────────────────────────────────────┘
    │
    ▼
┌─ 工程5: 実装 ────────────────────────────────────────────┐
│  Dev: dev-receive-task → 実装作業                          │
│    └─ dev-write-report → dev-notify-sm                     │
│  SM: sm-scan-reports → dashboard 更新 → PO に send-keys    │
│  PO → [Human] 成果物確認                                   │
│    ├─ 完了 → 工程6へ                                       │
│    ├─ 次フェーズへ → 工程4へ                                │
│    └─ 修正指示 → 工程4へ                                   │
└───────────────────────────────────────────────────────────┘
    │
    ▼
┌─ 工程6: 検証・受入 ──────────────────────────────────────┐
│  PO: po-request-yaml (verify)                             │
│  SM: sm-receive-request → 成果物検証 → PO に send-keys     │
│  PO: po-verify-acceptance                                  │
│    ├─ OK → [Human] ★ 最終承認                              │
│    │    └─ po-request-yaml (backlog_update)                │
│    │         └─ SM: sm-update-spec (Backlog: done)         │
│    └─ NG → [Human] 報告 → 工程3へ差し戻し                  │
└───────────────────────────────────────────────────────────┘
    │
    ▼
┌─ 工程7: 移行・運用 ──────────────────────────────────────┐
│  [Human] フィードバック                                    │
│  PO: po-request-yaml (feature/bugfix)                     │
│  SM: sm-receive-request                                    │
│    ├─ 仕様更新必要 → 工程2へ                               │
│    └─ 仕様変更不要 → 工程4へ                               │
└───────────────────────────────────────────────────────────┘
```

## スキル依存関係マップ

### PO ワークフロー

```
po-check-constitution → po-check-spec → po-request-yaml → [SM待ち] → po-verify-acceptance
```

### SM ワークフロー

```
sm-receive-request → sm-update-spec
                   → sm-write-task-yaml → [Dev待ち] → sm-scan-reports
```

### Dev ワークフロー

```
dev-receive-task → [実装] → dev-write-report → dev-notify-sm
```

## Queue ファイル一覧

| ファイル | 方向 | 書き込み | 読み取り |
|---------|------|---------|---------|
| `queue/po_to_sm.yaml` | PO → SM | PO (`po-request-yaml`) | SM (`sm-receive-request`) |
| `queue/tasks/dev{N}.yaml` | SM → Dev | SM (`sm-write-task-yaml`) | Dev (`dev-receive-task`) |
| `queue/reports/{task_id}.yaml` | Dev → SM | Dev (`dev-write-report`) | SM (`sm-scan-reports`) |
| `queue/dashboard.md` | SM 管理 | SM | PO, Dev (読み取りのみ) |

## スキル一覧（全12スキル）

| スキル | ロール | 工程 | 概要 |
|--------|--------|------|------|
| `po-check-constitution` | PO | 1 | CONSTITUTION.md の存在意義確認 |
| `po-check-spec` | PO | 2 | README.md への要望反映確認 |
| `po-request-yaml` | PO | 1,2,3,4,6,7 | PO → SM リクエスト YAML 生成 |
| `po-verify-acceptance` | PO | 6 | 受入基準の検証・判断 |
| `sm-receive-request` | SM | 1,2,3,4,6,7 | PO リクエストの受領・フェーズ判定 |
| `sm-update-spec` | SM | 1,2,3,6 | CONSTITUTION.md / README.md 更新 |
| `sm-write-task-yaml` | SM | 3,4,5 | タスク分解・Dev 割り当て YAML 生成 |
| `sm-scan-reports` | SM | 5 | 報告ファイル全スキャン・未処理検出 |
| `dev-receive-task` | Dev | 3,5 | タスク YAML 受領・検証 |
| `dev-write-report` | Dev | 3,5 | 完了報告 YAML 生成 |
| `dev-notify-sm` | Dev | 3,5 | SM への send-keys 完了通知 |
| `spec-code-reviewer-skill` | 横断 | 全工程 | 仕様 vs コードのセマンティックレビュー |

## 共有リファレンス

スキル間で共有するスキーマ定義は `skills/references/` に一元管理する。

| ファイル | 内容 | 参照元スキル |
|---------|------|-------------|
| `references/phase-gate.md` | フェーズ遷移条件 | 全スキル |
| `references/task-yaml-schema.md` | SM → Dev タスク YAML スキーマ | `sm-write-task-yaml`, `dev-receive-task` |
