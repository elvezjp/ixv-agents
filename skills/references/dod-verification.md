# Definition of Done 突合検証（DoD Verification）

タスクの `definition_of_done` の各項目が、レポートの `changes` または `artifacts` でカバーされているかを判定するための共通基準。
SPEC.md §2.4.3 を実装するためのリファレンスとして、`dev-write-report` と `sm-scan-reports` の両スキルから参照する。

## 適用範囲

| スキル | 利用タイミング |
|--------|--------------|
| `dev-write-report` | `status: done` を選ぶ前のセルフチェック |
| `sm-scan-reports` | `done` レポート受領時の突合検証 |

## 突合の基本ルール

`definition_of_done` の **各項目** に対し、以下のいずれかでカバーされていれば「対応あり」とみなす。

1. **changes に対応する記述がある**: 完了条件と意味的に対応する変更が `changes` に列挙されている
2. **artifacts に対応する成果物がある**: 完了条件で言及されたファイルやドキュメントが `artifacts` に列挙されている
3. **両方ある**: 上記1と2の両方を満たす（推奨）

1〜3 のいずれにも該当しない項目は **未カバー** と判定する。

## 判定基準

### 基準A: キーワード一致

DoD 項目内の **キーフレーズ**（実装対象の機能名、ファイル名、テスト名等）が `changes` または `artifacts` に現れているかを確認する。

| DoD 項目（例） | キーフレーズ | カバー判定の根拠 |
|--------------|-----------|----------------|
| `/auth/login エンドポイントが正しく動作する` | `/auth/login` | changes に「/auth/login エンドポイントを実装」が列挙されている、かつ artifacts に対応する実装ファイルが含まれる |
| `ユニットテスト8件が作成されている` | `ユニットテスト`, `8件` | changes に「ユニットテスト8件を作成」、artifacts に `tests/auth/api.test.ts` 等のテストファイル |
| `README.md に Backlog エントリが追加されている` | `README.md`, `Backlog` | artifacts に `README.md` が含まれ、changes に「Backlog エントリ追加」がある |

### 基準B: ファイルパス類推

DoD 項目が「ファイルが存在する」「セクションが記載されている」等を求めている場合、対応するファイルパスが `artifacts` に含まれているかを確認する。

| DoD 項目（例） | 期待されるファイルパス |
|--------------|--------------------|
| `認証 API が実装されている` | `src/auth/api.ts` 系のパス |
| `比較表が docs/ に作成されている` | `docs/*-comparison.md` 等 |
| `テストが通る` | `tests/*` 配下のテストファイル + テスト結果の言及 |

### 基準C: 明示マッピング

DoD 項目数と `changes` 項目数が一致し、項目が1対1で対応していると明らかな場合は、各 DoD 項目を順番にマッピングしてよい。
ただし、順序のずれや項目の抜け落ちが起きうるため、**基準A・基準B での確認を優先** する。

## 未カバー項目の扱い

### Dev 側（`dev-write-report`）

未カバー項目を発見した場合：

1. `issues` フィールドに **未カバー理由** を記載する
   - 例: `"DoD: ユニットテスト8件作成"が未対応。テスト4件のみ作成、残り4件は次タスクで対応予定`
2. `status` を `done` から **`needs_review`** に格下げする
3. `summary` にも「DoD 一部未対応」である旨を記載する

`status: done` で報告できるのは、**全 DoD 項目がカバーされている場合のみ**。

### SM 側（`sm-scan-reports`）

`done` レポートを受領したら、対応するタスク（`queue/tasks/dev{N}.yaml` または過去の発行履歴）の `definition_of_done` を読み込み、各項目を本基準で突合する。

未カバー項目を発見した場合：

1. `dashboard.md` の `## Notes` に該当 task_id と未カバー項目を記載
   - 例: `- TASK-20260201-010: DoD "ユニットテスト8件作成" が未対応（実装テスト4件のみ）`
2. Dev に追加作業を send-keys で指示
3. Backlog Status の該当タスクを `done` にせず、`needs_review` 相当の扱いにする

`dashboard.md` の構成（セクション）は変更せず、既存の `## Notes` セクションを流用する。

## 例

### 例1: 完全カバー（status: done が妥当）

**タスク**:
```yaml
definition_of_done:
  - "/auth/login エンドポイントが POST リクエストを受け付ける"
  - "正しい認証情報でトークンが返却される"
  - "ユニットテストがすべてパスする"
```

**レポート**:
```yaml
status: done
changes:
  - "/auth/login エンドポイントを実装（POST、JWT返却）"
  - "認証情報検証ロジックを追加（正常系・異常系）"
  - "ユニットテスト6件を作成、全件パス"
artifacts:
  - "src/auth/api.ts"
  - "tests/auth/api.test.ts"
```

**判定**:

| DoD 項目 | カバー根拠 | 判定 |
|---------|---------|------|
| /auth/login が POST を受け付ける | changes 1番目 + artifacts `src/auth/api.ts` | OK |
| 正しい認証情報でトークンが返却される | changes 2番目（認証情報検証）+ JWT返却の言及 | OK |
| ユニットテストがすべてパスする | changes 3番目 + artifacts `tests/auth/api.test.ts` | OK |

→ `status: done` で問題なし。

### 例2: 部分未カバー（needs_review に格下げ）

**タスク**:
```yaml
definition_of_done:
  - "認証 API エンドポイントが実装されている"
  - "ユニットテスト8件作成"
  - "README.md にエンドポイント仕様を追記"
```

**レポート（修正前 — NG）**:
```yaml
status: done
changes:
  - "Implemented basic auth"
artifacts:
  - "src/auth/api.ts"
```

**判定**:

| DoD 項目 | カバー根拠 | 判定 |
|---------|---------|------|
| 認証 API エンドポイントが実装されている | artifacts `src/auth/api.ts` | OK |
| ユニットテスト8件作成 | changes/artifacts に該当なし | **NG** |
| README.md にエンドポイント仕様を追記 | changes/artifacts に該当なし | **NG** |

**レポート（修正後 — OK）**:
```yaml
status: needs_review
summary: "認証 API は実装完了。ただし DoD 一部未対応のため要レビュー。"
changes:
  - "Implemented basic auth"
artifacts:
  - "src/auth/api.ts"
issues:
  - "DoD: ユニットテスト8件作成 が未対応"
  - "DoD: README.md エンドポイント仕様追記 が未対応"
```

→ SM は `dashboard.md` の `## Notes` に未カバー項目を記載し、Dev に追加作業を指示。

## 参照元スキル

このリファレンスを参照すべきスキル:

- `dev-write-report`（Step 2.5: DoD セルフチェック）
- `sm-scan-reports`（Step 3.5: DoD 突合検証）

## 関連仕様

- SPEC.md §2.3.3（タスク `definition_of_done` フィールド定義）
- SPEC.md §2.3.4（レポート `changes` / `artifacts` フィールド定義）
- SPEC.md §2.4.3（Definition of Done 突合ルール）
