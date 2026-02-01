# Project Name

## Metadata
- Version: 0.1.0
- Last Updated: {{DATE}}

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

## Backlog
| ID | Priority | Summary | Status |
|----|----------|---------|--------|
| - | - | - | - |

## Icebox
- TBD

---

## Workspace Structure

```
workspace/
├── README.md           # 本ファイル（仕様書）
├── queue/              # エージェント間通信
│   ├── dashboard.md    # プロジェクト状況ボード
│   ├── po_to_sm.yaml   # PO -> SM
│   ├── tasks/          # SM -> Dev
│   └── reports/        # Dev -> SM
└── (成果物)            # 実装コード、テスト等
```

## Roles

- **PO (Product Owner)**: 仕様策定（README.md更新）、バックログ管理
- **SM (Scrum Master)**: タスク分解、割り当て、進捗管理
- **Dev (Developer)**: 実装

## References

- [instructions/](instructions/) - 各ロールへの指示書
