# Project Name

この`README.md`は、このプロジェクトにおける **唯一の仕様（Single Source of Truth）** です。
迷ったら必ずここに戻り、必要であれば更新してください。

## 仕様の扱い
- **優先順位**: `CONSTITUTION.md` → `README.md` → `PROCESS.md` → `AGENTS.md` → `roles/*`
- **補助ドキュメント**（設計メモなど）を作ってもよいが、**仕様として有効なのはREADMEの記載のみ**。
  - 補助ドキュメントに重要な決定がある場合、READMEの該当セクション（制約/スコープ/受入基準など）へ**要点を反映**する。

## Goal
- 目的/達成したい価値

## Scope
- 含める範囲
- 含めない範囲（Non-Goals）

## Requirements
- 機能要件

## Acceptance Criteria
- 受入条件（テスト観点）

## Constraints
- 技術/運用/セキュリティ制約


---

## Workspace Structure

```
workspace/
├── README.md           # 本ファイル（仕様書）
├── CONSTITUTION.md     # プロジェクト憲章
├── PROCESS.md          # 工程と運用フロー
├── AGENTS.md           # AI行動規範
├── roles/              # 各エージェントの役割規定
├── queue/              # エージェント間通信
│   ├── dashboard.md    # プロジェクト状況ボード
│   ├── po_to_sm.yaml   # PO -> SM
│   ├── tasks/          # SM -> Dev
│   └── reports/        # Dev -> SM
└── (成果物)            # 実装コード、テスト等
```


## References

- [CONSTITUTION.md](CONSTITUTION.md) - プロジェクト憲章
- [PROCESS.md](PROCESS.md) - 工程と運用フロー
- [AGENTS.md](AGENTS.md) - AI行動規範
- [roles/](roles/) - 各ロールの役割規定
