# フェーズ遷移ガード（Phase Gate）

PROCESS.md の7工程間の遷移条件を一元定義する。
各スキルはフェーズ遷移時にこのドキュメントの条件を参照すること。

## 遷移条件一覧

| 遷移 | 遷移条件 | 確認者 | 確認方法 |
|------|---------|--------|---------|
| 工程1 → 工程2 | CONSTITUTION.md の「存在意義（Purpose）」が記入済み | PO (`po-check-constitution`) | Purpose セクションがテンプレート文言でない |
| 工程2 → 工程3 | README.md に要望が Requirements として反映済み | PO (`po-check-spec`) | Requirements / Backlog に該当エントリが存在 |
| 工程3 → 工程4 | 実行計画が docs/ に作成済み、README.md が詳細化済み | PO + Human | 計画承認済み（Human ★） |
| 工程4 → 工程5 | queue/tasks/dev{N}.yaml が対象 Dev 分発行済み | SM (`sm-write-task-yaml`) | タスクファイルが存在し、Dev に send-keys 済み |
| 工程5 → 工程6 | 全タスクの reports が done（または blocked が解決済み） | SM (`sm-scan-reports`) | dashboard.md の全タスクが done |
| 工程6 → 工程7 | PO が acceptance_criteria を検証し、Human が最終承認 | PO (`po-verify-acceptance`) + Human | Human ★ 最終承認 |
| 工程7 → 工程2 | 仕様更新が必要なフィードバック | SM (`sm-receive-request`) | task_type に基づく振り分け |
| 工程7 → 工程4 | 仕様変更不要（バグ修正、調査等） | SM (`sm-receive-request`) | task_type に基づく振り分け |

## 遷移フロー図

```
工程1 ──[Purpose記入済み]──► 工程2 ──[仕様反映済み]──► 工程3
                                                        │
                                               [計画承認 ★]
                                                        │
                                                        ▼
            ┌──────────────────────────────────────── 工程4
            │                                           │
            │                                  [タスク発行済み]
            │                                           │
            │                                           ▼
            │  [修正指示/次フェーズ]                    工程5
            │◄──────────────────────────────────────────│
            │                                  [全タスク完了]
            │                                           │
            │                                           ▼
            │                                        工程6
            │                               [NG]  ┌────┤
            │◄──────────── 工程3 ◄─────────────────┘    │
            │                                      [OK ★]
            │                                           │
            │                                           ▼
            │                                        工程7
            │  [仕様変更不要]                   [仕様更新必要]
            │◄──────────────────────────┐    ┌──────────┘
                                        │    │
                                        │    ▼
                                        └── 工程2
```

★ = Human の承認が必要

## フェーズゲート違反パターン

以下のパターンは禁止される。

| 違反 | 説明 | 正しい対応 |
|------|------|-----------|
| 憲章未記入で仕様策定 | 工程1を飛ばして工程2に進む | `po-check-constitution` で確認してから進む |
| 仕様未反映で計画策定 | 工程2を飛ばして工程3に進む | `po-check-spec` で確認してから進む |
| 計画未承認で実装開始 | Human 承認なしで工程4,5に進む | Human の計画承認を取得してから進む |
| 検証なしで完了扱い | 工程6を飛ばして Backlog を done にする | `po-verify-acceptance` で検証してから完了 |

## 参照元スキル

このドキュメントを参照すべきスキル:

- `po-check-constitution`（工程1 ゲート）
- `po-check-spec`（工程2 ゲート）
- `po-request-yaml`（フェーズ順序の発行制限）
- `sm-receive-request`（フェーズ判定・ルーティング）
- `sm-scan-reports`（工程5 → 6 の遷移判断）
- `po-verify-acceptance`（工程6 → 7 の遷移判断）
