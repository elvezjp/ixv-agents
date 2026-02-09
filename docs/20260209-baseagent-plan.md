# Sentinel Introduction Plan

Date: 2026-02-09
Status: Draft

## Goal

Mac Studio (512GB) 上に**24時間稼働のローカルエージェント（Sentinel）**を導入する。Sentinel はローカル LLM（Brain）で自律的に動作し、既存の API エージェント（PO/SM/Dev）を必要な時だけ起動する。

### 実現したいこと

- 1台のマシンに1つの特別なエージェント（Sentinel）を常駐させる
- Sentinel はローカル LLM で動作し、API コスト $0 で24時間稼働する
- 他のエージェント（PO/SM/Dev）は現状通り Claude Code CLI + API を使う
- Sentinel が全体を監視し、必要な時だけ API エージェントを起こす

### 設計判断

- **BaseAgent クラスは導入しない** — Sentinel は独立した Python アプリケーション。PO/SM/Dev をラップする Python クラスは存在しない
- **Brain は Sentinel の内部実装** — フレームワークとして外部に公開しない。Sentinel だけがローカル LLM を持つ
- **Heartbeat は全エージェント共通** — 共通にするのは YAML スキーマ（データ形式）であり、Python クラスではない。PO/SM/Dev はスキルまたはロール定義への追記で Heartbeat に参加する

### 用語の統一

- **Sentinel**: 24時間稼働のローカル常駐エージェント（単一プロセス）
- **API エージェント**: PO/SM/Dev（Claude Code CLI + API）
- **Heartbeat**: 共有 YAML スキーマの状態通知（読み取り: Sentinel / 書き込み: PO/SM/Dev）
- **Queue**: `queue/*.yaml` の指示・報告ファイル

### 制約

- `roles/*.md` は引き続きロール定義の権威ソース
- YAML キューは引き続き通信プロトコル
- `scripts/*.sh` と tmux ベースの実行は既存のまま動作する

## Non-Goals

- `scripts/*.sh` の書き換え
- 既存の tmux セッションレイアウトや send-keys の動作変更
- YAML キューを別のトランスポートに置き換え
- BaseAgent / ApiAgent 等のクラス階層の導入

## Architecture

### 全体構成

```
Mac Studio 512GB（24時間稼働）
│
├── Sentinel（ローカル LLM、常時起動、API コスト $0）
│   ├── Brain: MLX で 70B クラスを常時ロード
│   ├── Heartbeat 監視: 全エージェントの生存確認・同期（読み取り側）
│   ├── Doc Triage: ドキュメント構造解析・重要ページ特定
│   ├── Queue Watcher: キュー変更のイベント監視（fsevents）
│   └── Machine Monitor: マシン全体の監視
│       ├── プロセス監視（Cursor, ビルド, テスト等）
│       ├── リソース監視（CPU / メモリ / ディスク）
│       └── ファイルシステム監視（fsevents）
│
│   ← 必要な時だけ起動 →
│
├── PO Agent  (Claude Code CLI / API + Heartbeat 書き込み)  ← オンデマンド
├── SM Agent  (Claude Code CLI / API + Heartbeat 書き込み)  ← オンデマンド
├── Dev1〜3   (Claude Code CLI / API + Heartbeat 書き込み)  ← オンデマンド
│
│   Sentinel のスコープは IXV-Agents に閉じない。
│   マシン上の全活動（他のリポジトリ、IDE、ビルドプロセス等）を把握する。
│
├── Cursor (リポジトリ A)  ← Sentinel が見える
├── Cursor (リポジトリ B)  ← Sentinel が見える
└── その他プロセス          ← Sentinel が見える
```

### コスト構造

```
現状:    全操作が API 課金対象
提案後:  日常業務（監視・前処理・判断）はローカル $0
         高度な作業（仕様策定・コード実装）だけ API 課金
```

### Sentinel の内部構成

Sentinel は独立した Python アプリケーション。フレームワークではない。

```
src/sentinel/
├── main.py            # イベントループ
├── brain.py           # ローカル LLM 呼び出し（MLX）
├── heartbeat.py       # Heartbeat 監視（読み取り側）
├── machine.py         # マシン監視（プロセス/リソース/FS）
├── queue_watcher.py   # キュー変更の検知
├── router.py          # ルーティング判断（どのエージェントを起こすか）
├── tmux.py            # tmux send-keys 操作
└── config.py          # 設定ローダー
```

### API エージェントの Heartbeat 参加

PO/SM/Dev は Claude Code CLI そのまま。Heartbeat 参加はスキルとロール定義で実現する。

```
skills/
└── heartbeat-update/
    └── SKILL.md       # タスク開始/完了/エラー時に heartbeat YAML を更新

roles/
├── sentinel.md        ← 新規
├── po.md              ← Heartbeat 更新ルールを追記
├── sm.md              ← Heartbeat 更新ルールを追記
└── dev.md             ← Heartbeat 更新ルールを追記
```

## Sentinel の役割

### 責務

| 責務 | 具体例 |
|---|---|
| **キュー監視** | キューの変更検知、エージェントの生存確認 |
| **マシン監視** | CPU/メモリ/ディスク使用率、プロセス状態、ビルド・テストの成否検知 |
| **前処理** | Doc Triage（構造解析・重要ページ特定）、ドキュメント差分検出 |
| **判断** | 「これは PO に送るべきか、SM に送るべきか」のルーティング、リソース競合時の優先度調整 |
| **起動** | 必要な API エージェントを tmux send-keys で起こす |
| **記録** | 全イベントのログ、dashboard.md の自動更新 |

### 禁止事項

- 仕様書を書かない（PO の仕事）
- タスクを分解しない（SM の仕事）
- コードを書かない（Dev の仕事）
- 人間に直接報告しない（PO の仕事）

Sentinel は**判断と実行を分離する存在**。判断だけして、実行は適切なエージェントに委譲する。

## Brain（ローカル LLM）

Brain は Sentinel の内部実装。外部に公開するインターフェースやフレームワークではない。

### ターゲットマシン

- Mac Studio（Apple Silicon, 512GB 統合メモリ）
- MLX フレームワークでモデルを実行

### モデル候補

| モデル | メモリ使用量 | 用途適性 |
|---|---|---|
| Qwen 2.5 72B (MLX) | ~40GB | コード生成・推論に強い |
| Llama 3.1 70B (MLX) | ~38GB | 汎用的 |
| DeepSeek-R1 70B (MLX) | ~38GB | 推論チェーンに強い |

512GB メモリがあるため、1つのモデルサーバーを常時ロードし、Sentinel が繰り返しリクエストを投げる構成。

### Brain の責務

- Queue に投入されたタスクの分析・分類
- Doc Triage Stage 2 のスコアリング（ローカル実行、$0）
- 「この作業は API エージェントに委譲すべきか」の判断
- dashboard.md の要約・更新

## Heartbeat

### 目的

現状の「tmux send-keys で通知して結果を待てない」問題を解決する。

### 設計原則

- 全エージェントが共通の YAML スキーマで状態を書き込む
- Sentinel が読み取り側（監視）、PO/SM/Dev が書き込み側
- PO/SM/Dev の書き込みは Python クラスではなく、スキルまたはロール定義で実現

### プロトコル

ファイルベース（既存の YAML 通信と一貫性を保つ）。

### YAML スキーマ（ドラフト）

共通フィールドは最小限にし、既存の YAML 方針（Spec.md）と整合する。

```yaml
schema_version: "1.0"
agent: "dev1"                 # sentinel | po | sm | dev1 | dev2 | dev3
status: "working"             # idle | working | done | error
task_id: "TASK-20260209-001"   # optional (idle の場合は省略可)
progress: 0.3                 # 0.0〜1.0 (optional)
updated_at: "2026-02-09T14:30:00+09:00"
message: "optional summary"   # optional: 状態の短い説明
```

#### 書き込みタイミング（API エージェント）

- タスク開始時: `status=working`
- タスク完了時: `status=done`
- ブロック発生時: `status=error` + `message`
- 長時間作業時: `progress` を更新（最短 30 秒、最長 5 分の範囲で）

#### 書き込みタイミング（Sentinel）

- 起動時: `status=idle` で作成
- タスク処理中（Doc Triage 等）: `status=working`
- 停止前: `status=idle` に戻し `updated_at` を更新

```
queue/heartbeat/
├── sentinel.yaml     # Sentinel の状態
├── po.yaml           # PO の状態
├── sm.yaml           # SM の状態
├── dev1.yaml         # Dev1 の状態
├── dev2.yaml         # Dev2 の状態
└── dev3.yaml         # Dev3 の状態
```

```yaml
# queue/heartbeat/dev1.yaml（例）
schema_version: "1.0"
agent: "dev1"
status: "working"                    # idle | working | done | error
task_id: "TASK-20260209-001"         # optional
progress: 0.3                        # 0.0〜1.0 (optional)
updated_at: "2026-02-09T14:30:00+09:00"
message: "implementing auth module"  # optional
```

### Sentinel の監視ロジック

- Sentinel は heartbeat の更新をイベント監視（fsevents）で検知する
- イベント監視が使えない場合のみ、低頻度のバックオフ・ポーリングを許容する
- `updated_at` が一定時間（例: 60秒）更新されなければ、エージェントがフリーズしたと判断
- `status: done` を検知したら、SM に完了を通知（または次タスクを判断）
- `status: error` を検知したら、ログに記録し、必要に応じて再起動

## Machine Monitor（マシン全体の監視）

### 目的

Sentinel のスコープを IXV-Agents のキュー監視に閉じず、マシン上の全活動を把握する。複数リポジトリや IDE が同一マシンで稼働する環境で、Sentinel が「マシンの意識」として機能する。

### 監視対象

| 対象 | 取得方法 | 用途 |
|---|---|---|
| CPU / メモリ使用率 | `psutil` | リソース競合の検知、重いタスクの後回し判断 |
| ディスク使用率 | `psutil` | 容量逼迫の検知、中間ファイルのクリーンアップ提案 |
| プロセス一覧 | `psutil` | ビルド・テスト・IDE の稼働状態を把握 |
| ファイルシステム変更 | `fsevents`（macOS） | リポジトリへのファイル投入検知、git 操作の追跡 |

### 判断例

- リポジトリ A でビルドが CPU 100% → リポジトリ B の重いタスクを後回しにする
- ディスク 90% 超過 → `.triage/` の古い中間ファイルや不要な `node_modules` を特定し、クリーンアップを提案
- git log に `revert` が連続 → 開発難航と判断し、関連ドキュメントを Doc Triage で準備
- CI/CD の webhook やログファイルの変更を検知 → 失敗時に自律的に原因分析・Dev 起動

### fsevents の一元化

fsevents で全監視対象のイベントを一元的に受信し、パスに応じてルーティングする。

```
fsevents（一元的にイベント受信）
├── queue/*.yaml の変更       → queue_watcher.py → router.py
├── queue/heartbeat/ の変更   → heartbeat.py
└── それ以外のパス変更         → machine.py → brain.py
```

## Doc Triage との接続

Doc Triage の Stage 2 LLM スコアリングは Sentinel の Brain が実行する。詳細仕様は別途策定する。

```
[PDF が投入される]
    │
    ▼ Sentinel: Stage 1 (PP-DocLayout)   → ローカル、即座
    ▼ Sentinel: Stage 2 (Brain)          → ローカル、$0
    ▼ Sentinel: 重要ページを特定 → PO に渡す判断
    ▼ Sentinel → tmux send-keys → PO Agent 起動（API 課金はここだけ）
    ▼ PO: Stage 3（重要ページのみ精読）→ API だが対象ページが絞られている
```

ローカル Brain で Stage 2 を実行するため、Doc Triage 仕様のセキュリティ制約（「構造メタデータに限定」）は緩和可能。文書内容を外部に送信しないという要件を自然に満たす。

## Sentinel の起動・停止・再起動ポリシー

### 起動

- 起動は **手動**（開発者が明示的に起動）
- 既存の `scripts/*.sh` は変更しない
- 起動時に `queue/heartbeat/sentinel.yaml` を `status=idle` で作成

### 停止

- 停止は **手動**（メンテナンス時のみ）
- 停止前に `status=idle` へ戻し、`updated_at` を更新
- 強制停止時は次回起動で「前回強制停止」をログに記録

### 再起動

- Sentinel が内部で異常を検知した場合は **自己再起動をしない**
- 再起動は外部からの手動実施（安全優先）
- ただし、**クラッシュ時の自動再起動**は OS の標準機能でのみ許容
  - macOS: `launchd` で `KeepAlive` を使う（設定は別途）

### 例外ポリシー

- CPU/メモリが閾値を超えた場合: **Brain を一時停止**（モデル解放）
- ディスク逼迫時: **監視のみ継続**し、API エージェント起動を抑制

## Implementation Steps

1. **Sentinel Python パッケージのスキャフォールド**
   - `src/sentinel/` with `__init__.py`, `main.py`
   - 最小限の設定ローダー（`config.py`）

2. **Heartbeat スキーマとスキルの定義**
   - `queue/heartbeat/` ディレクトリとファイル形式
   - `skills/heartbeat-update/SKILL.md`（PO/SM/Dev 用）
   - `roles/po.md`, `roles/sm.md`, `roles/dev.md` に Heartbeat 更新ルールを追記

3. **Heartbeat 監視の実装（Sentinel 側）**
   - `heartbeat.py`（fsevents で heartbeat YAML の変更を検知）
   - タイムアウト検知、ステータス変更検知

4. **Brain の実装**
   - `brain.py`（MLX モデルサーバーとの通信）
   - まずはスタブ実装（ローカルモデル未接続でもテスト可能）

5. **Queue Watcher と Router の実装**
   - `queue_watcher.py`（fsevents でキュー変更を検知）
   - `router.py`（どの API エージェントを起こすかの判断ロジック）
   - `tmux.py`（tmux send-keys の実行）

6. **Machine Monitor の実装**
   - `machine.py`（psutil によるプロセス・リソース監視、fsevents によるファイルシステム監視）

7. **Doc Triage の統合**
   - Doc Triage を Sentinel のモジュールとして組み込み
   - Stage 1 (PP-DocLayout) + Stage 2 (Brain) のパイプライン

8. **Sentinel イベントループの統合**
   - `main.py`（fsevents 一元受信 → 各モジュールへのルーティング）
   - `roles/sentinel.md` ロール定義

9. **検証**
   - `scripts/boot.sh` が既存のまま動作すること
   - Sentinel を追加起動しても既存フローが壊れないこと
   - Heartbeat YAML が正しく更新されること（スキル経由）

## Compatibility Notes

- Sentinel は**追加**であり、既存の `scripts/*.sh` はそのまま動作する
- Sentinel なしでも（従来通り API エージェントだけでも）運用可能
- YAML の構造やパスを変更しない
- tmux コマンド文字列は現行スクリプトと同一を維持

## Risks & Mitigations

| リスク | 影響 | 対策 |
|---|---|---|
| ローカル LLM の推論品質が不十分 | Sentinel の判断精度が低下し、不適切なルーティングが発生する | Brain に confidence threshold を設け、低信頼度の判断は API にフォールバック |
| API エージェントが Heartbeat を書き忘れる | Sentinel がエージェントの状態を把握できない | スキルとロール定義の両方で Heartbeat 更新を指示。書き忘れは Sentinel がタイムアウトで検知 |
| fsevents の信頼性 | イベントの取りこぼしが発生する可能性 | 低頻度のバックオフ・ポーリングをフォールバックとして併用 |
| Mac Studio 固有の依存 | 他のマシンで動作しない | Brain のモデルサーバー接続を抽象化し、MLX 以外のバックエンドも差し替え可能にする |

## Deliverables

- `src/sentinel/` Python アプリケーション（Brain, Heartbeat 監視, Machine Monitor, Queue Watcher, Router）
- `roles/sentinel.md` ロール定義
- `skills/heartbeat-update/` Heartbeat 書き込みスキル
- `roles/po.md`, `roles/sm.md`, `roles/dev.md` への Heartbeat 更新ルール追記
- `queue/heartbeat/` ディレクトリとスキーマ
- README への本計画の反映
- 既存シェルスクリプトへの変更なし

## 追加で決めるべき点

- Brain に使用するモデルの最終選定（ベンチマーク実施後）
- Heartbeat のタイムアウト値（フリーズ判定の閾値）
- Sentinel の tmux ペイン配置（既存5ペインに追加 or 別セッション）
- Brain の confidence threshold（API フォールバック閾値）
- Machine Monitor の監視対象パスと閾値（CPU/ディスク等）
- Heartbeat `schema_version` の運用ルール（バージョンアップ時の後方互換性）
