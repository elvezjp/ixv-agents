---
name: sm-scan-reports
description: |
  queue/reports/ 配下の全報告ファイルをスキャンし、dashboard.md に未反映の報告を特定する。
  通信ロスト対策として、起こされた際に毎回実行する。
  Use when: 「報告確認」「レポートスキャン」「未処理報告」「Devから起こされた」と言われた時。
metadata:
  author: IXV-Agents
  version: 1.0.0
  phase: "5"
---

# SM Scan Reports

`queue/reports/` 配下の全報告ファイルをスキャンし、`queue/dashboard.md` と照合して未処理の報告を特定する。通信ロスト対策として、起こされるたびに毎回全スキャンを行う。

## When to Use

- Devから send-keys で起こされた時（**毎回必須**）
- Phase 5 で作業進捗を確認する時
- コンパクション復帰後
- 理由に関係なく起こされたら毎回実行

## Why Full Scan is Required

- Devが報告ファイルを書いた後、send-keys が届かないことがある
- SMが処理中だと、Enter がパーミッション確認等に消費される
- 報告ファイル自体は正しく書かれているので、スキャンすれば発見できる
- これにより「send-keys が届かなくても報告が漏れない」安全策となる

## Instructions

### Step 1: 全報告ファイルを一覧取得

```bash
ls -la queue/reports/
```

TEMPLATE.yaml を除く全ファイルが対象。

### Step 2: 各報告ファイルを読み取り

各報告ファイルを読み取り、以下のフィールドを確認する：

| フィールド | 確認内容 |
|-----------|---------|
| task_id | タスク識別子 |
| status | `done` / `blocked` / `needs_review` |
| summary | 結果概要 |
| changes | 変更点 |
| artifacts | 成果物ファイルパス |
| issues | 問題点・ブロッカー |

**Report Schema（SPEC.md 2.3.4準拠）**:
```yaml
schema_version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
updated_at: "YYYY-MM-DDTHH:MM:SSZ"
task_id: "TASK-YYYYMMDD-###"
status: "done"
summary: "200文字以内の結果概要"
changes:
  - "変更点の箇条書き"
artifacts:
  - "ファイルパス"
issues:
  - "課題や不具合"
```

### Step 3: dashboard.md と照合

`queue/dashboard.md` の以下のセクションと照合する：

- **Backlog Status**: タスクの進捗状況
- **Agent Status**: 各Devの作業状況
- **Blockers**: ブロッカー一覧

### Step 3.5: Definition of Done 突合検証（status: done レポートのみ）

**SPEC.md §2.4.3 に基づく必須検証**。`status: done` の報告について、対応タスクの `definition_of_done` を読み込み、レポートの `changes` / `artifacts` と突合する。
判定基準の詳細は `../references/dod-verification.md` を参照。

#### 検証手順

`status: done` の各レポートについて：

1. レポートの `task_id` から対応タスクを特定
   - `queue/tasks/dev{N}.yaml` を走査、または既に処理済みなら過去の発行履歴を参照
2. 対応タスクの `definition_of_done` を読み込み
3. 各 DoD 項目について、レポートの `changes` または `artifacts` に対応する記述があるか確認

判定基準（`dod-verification.md` から要約）:

| 基準 | 内容 |
|------|------|
| キーワード一致 | DoD 項目内のキーフレーズが changes/artifacts に現れている |
| ファイルパス類推 | DoD が言及するファイルパスが artifacts に含まれている |
| 明示マッピング | DoD と changes が同数で1対1対応している |

#### 違反時の挙動

未カバー項目が **1件でもある** 場合：

1. **dashboard.md の `## Notes` セクションに記載**（既存セクションを利用、フォーマット変更なし）
   - 例: `- TASK-20260201-010: DoD "ユニットテスト8件作成" が未対応（実装テスト4件のみ確認）`
2. Backlog Status の該当タスクを `done` にせず、**`needs_review` 相当の扱い** とする
3. Dev に追加作業を send-keys で指示
4. PO に状況を send-keys で報告

レポート YAML 自体（`queue/reports/{task_id}.yaml`）は **書き換えない**（Dev が書いたものを尊重し、SM 側の判定は dashboard 側に記録する）。

#### 例

**未カバー検出時の dashboard.md 更新**:

```markdown
## Notes
- TASK-20260201-010: Dev は status: done と報告したが、DoD「ユニットテスト8件作成」が未カバー
  （実装テスト4件のみ）。Dev に残4件の作成を send-keys 済み。Backlog では needs_review 扱い。
```

検証をパスした `done` レポートのみ、Step 4 で「Backlog/Agent Status に done として反映」する。
未カバーがあった `done` レポートは、Step 4 で「`needs_review` 扱い」として処理する。

### Step 4: 未反映報告をステータス別に分類

| Report status | Step 3.5 判定 | Dashboard 状態 | Action |
|--------------|-------------|---------------|--------|
| `done` | DoD 全カバー | Backlog/Agent Status に未反映 | Dashboard 更新（成果セクション）→ PO通知 |
| `done` | DoD 未カバーあり | Backlog/Agent Status に未反映 | `## Notes` に未カバー項目記載、Backlog は `needs_review` 扱い → Dev に追加作業 send-keys、PO通知 |
| `blocked` | ― | Blockers に未記載 | Blockers セクション追加 → 対応検討 |
| `needs_review` | ― | 未反映 | Dashboard 更新 → PO通知 |
| `done` | DoD 全カバー | 既に成果に記載済み | Skip（既処理） |

### Step 5: 結果サマリを報告

スキャン結果をまとめ、次のアクションを決定する。

**全タスク完了の場合**:
```
レポートスキャン完了: 全タスク完了

処理済み報告:
- TASK-YYYYMMDD-001: done（成果物: src/auth/api.ts）
- TASK-YYYYMMDD-002: done（成果物: src/auth/middleware.ts）

→ 次のアクション:
  1. dashboard.md を更新（Backlog Status, Agent Status）
  2. PO に完了通知（send-keys）
```

**ブロッカーありの場合**:
```
レポートスキャン完了: ブロッカーあり

処理済み報告:
- TASK-YYYYMMDD-001: done
- TASK-YYYYMMDD-002: blocked（理由: API認証情報が不足）

→ 次のアクション:
  1. dashboard.md を更新（Blockers セクションに追加）
  2. 解決策を検討（タスク再割当て / PO相談）
  3. PO に状況報告（send-keys）
```

**未処理報告なしの場合**:
```
レポートスキャン完了: 未処理の報告はありません

→ 次のアクション:
  1. 全報告が dashboard に反映済み
  2. 追加の対応は不要
```

## Examples

### Example: 3件のレポートスキャン

**queue/reports/ の内容**:
```
TEMPLATE.yaml          (テンプレート - スキップ)
TASK-20260201-010.yaml (Dev1の報告)
TASK-20260201-011.yaml (Dev2の報告)
TASK-20260201-012.yaml (Dev3の報告)
```

**各報告の内容**:

TASK-20260201-010.yaml:
```yaml
task_id: "TASK-20260201-010"
status: "done"
summary: "認証APIエンドポイントの実装完了"
artifacts:
  - "src/auth/api.ts"
  - "tests/auth/api.test.ts"
```

TASK-20260201-011.yaml:
```yaml
task_id: "TASK-20260201-011"
status: "blocked"
summary: "セッション管理でRedis接続エラー"
issues:
  - "Redis接続情報が環境変数に設定されていない"
```

TASK-20260201-012.yaml:
```yaml
task_id: "TASK-20260201-012"
status: "done"
summary: "認証UIコンポーネントの実装完了"
artifacts:
  - "src/components/LoginForm.tsx"
```

**dashboard.md 照合結果**:
- TASK-20260201-010: dashboard に未反映 → **要処理**
- TASK-20260201-011: dashboard に未反映 → **要処理（ブロッカー）**
- TASK-20260201-012: 既に成果に記載済み → **Skip**

**スキャン結果**:
```
レポートスキャン完了: 2件の未処理報告を検出

未処理報告:
- TASK-20260201-010: done（認証APIエンドポイントの実装完了）
- TASK-20260201-011: blocked（Redis接続エラー）

既処理:
- TASK-20260201-012: done（既にdashboardに反映済み）

→ 次のアクション:
  1. dashboard.md 更新:
     - TASK-20260201-010 を成果セクションに追加
     - TASK-20260201-011 を Blockers セクションに追加
  2. ブロッカー対応を検討
  3. PO に状況報告（send-keys）
```

## Error Recovery

| 異常パターン | 検知方法 | 対応 |
|-------------|---------|------|
| queue/reports/ ディレクトリが存在しない | `ls` 失敗 | ディレクトリを作成。未報告タスクがないか dashboard.md で確認 |
| 報告 YAML の構文エラー | パース失敗 | 該当ファイル名を記録し、担当 Dev に再作成を依頼（send-keys） |
| task_id が dashboard.md に存在しない | 照合失敗 | 新規タスクの可能性。dashboard.md に追加して処理続行 |
| dashboard.md が存在しない | ファイル読み取り失敗 | テンプレートから再作成し、全報告ファイルから状態を復元 |
| Dev がタイムアウト（長時間 idle なし） | 報告なし + Agent Status が working のまま | dashboard.md の Blockers に記録し、PO に報告。タスク再割当てを検討 |

## References

詳細な処理フローは `references/report-processing-guide.md` を参照。
フェーズ遷移条件は `../references/phase-gate.md` を参照。

## Notes

- このスキルはSMロールのみが使用する
- **毎回全スキャン必須**: 起こされた理由に関係なく、全報告ファイルをスキャンする
- dashboard.md と YAML の内容が矛盾する場合、**YAMLが正**
- TEMPLATE.yaml はスキャン対象から除外する
