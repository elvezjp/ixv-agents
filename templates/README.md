# Project Name

この`README.md`は、このプロジェクトにおける **プロダクト仕様の唯一の情報源（Single Source of Truth）** です。
迷ったら必ずここに戻り、必要であれば更新してください。  
プロジェクト全体の存在意義・基本原則・ガバナンスは `CONSTITUTION.md` に、開発工程（人間とAIエージェントを含む）の進め方やイベントの流れは `PROCESS.md` に、エージェントの行動規範や責任分担・承認フローは `AGENTS.md` に定義されています。

## 仕様の扱い
- **優先順位**: `CONSTITUTION.md`（プロジェクト憲章） → `README.md`（プロダクト仕様） → `PROCESS.md`（工程） → `AGENTS.md`（行動規範） → `roles/*`（各ロールの詳細）
- **補助ドキュメント**（設計メモなど）を作ってもよいが、**プロダクト仕様として有効なのは README の記載のみ**。
  - 補助ドキュメントに重要な決定がある場合、READMEの該当セクション（制約/スコープ/受入基準など）へ**要点を反映**する。

## プロダクト仕様

### プロダクト目標（Goal）
- 目的 / 達成したい価値

### 対象範囲（Scope）
- 含める範囲
- 含めない範囲（Non-Goals）

### 要件（Requirements）
- 機能要件

### 受入条件（Acceptance Criteria）
- 受入条件（テスト観点）

### 制約条件（Constraints）
- 技術 / 運用 / セキュリティ制約


---

## Workspace Structure

### プロダクトに属するもの（仕様・成果物）

プロダクトの仕様と、その実装・テストなどの成果物です。この `README.md` から見える世界の中心になります。

```
workspace/
├── README.md           # 本ファイル（プロダクト仕様）
├── CONSTITUTION.md     # プロジェクト憲章（前提となる原則）
├── PROCESS.md          # 工程と運用フロー（開発プロセスの説明）
├── AGENTS.md           # AI行動規範（仕様の扱いに関するルールも含む）
└── (成果物)            # 実装コード、テスト等
```

### 実装過程で参照されるもの（エージェント用・メタ情報）

PO/SM/Dev などのロールや、エージェント間通信のためのキューです。  
プロダクト仕様そのものではなく、**仕様をもとに実装・運用するための補助的な仕組み**です。

```
workspace/
├── roles/              # 各エージェントの役割規定（PO/SM/Dev など）
└── queue/              # エージェント間通信
    ├── dashboard.md    # プロジェクト状況ボード
    ├── po_to_sm.yaml   # PO -> SM
    ├── tasks/          # SM -> Dev
    └── reports/        # Dev -> SM
```


## References

- [CONSTITUTION.md](CONSTITUTION.md) - プロジェクト憲章（存在意義・基本原則・変更禁止の範囲など）
- [PROCESS.md](PROCESS.md) - 工程と運用フロー（Constitution / Specify / Plan / Tasks / Implement / Verify/Accept / Migration/Op）
- [AGENTS.md](AGENTS.md) - AI行動規範（ガバナンスと責任、合意形成と承認、エージェントの振る舞い）
- [roles/](roles/) - 各ロールの役割規定（PO/SM/Dev など）
