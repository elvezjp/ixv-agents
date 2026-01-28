# IXV-Agents

## 概要

**IXV-Agents** は、仕様主導のAI開発システムです。固定された役割ベースのチームとして複数のAIエージェントを編成し、アジャイルの役割とイベントを仕様主導開発に統合することで、ガバナンス・トレーサビリティ・実運用性を確保します。

`multi-agent-shogun` のアーキテクチャ（tmux + Claude Code CLI + イベント駆動通信）に基づきます。

---

## 参照実装

本プロジェクトは、このワークスペース内の `multi-agent-shogun-main/` を、スクリプト、tmuxレイアウト、指示書テンプレートの参照実装として明示的に参照します。

---

## ステータス

| 項目 | 状態 |
|------|------|
| 仕様（Spec.md） | Draft v0.1.0 |
| 実装計画（Plan.md） | Draft v0.1.0 |
| 実装 | 未着手 |

**次のステップ**: Phase 1 - Environment Setup

---

## Web UI

ダッシュボードとキューの状態を閲覧するローカルWeb UIを提供します。
Markdown/YAMLが単一の真実であり、UIはそれを参照して表示するだけの **読み取り専用** です。
フロントエンドは **React + Tailwind**、バックエンドは **ローカル読み取り専用サービス** を想定します。

---

## コアコンセプト

**固定された役割、進化するスキル。**
人間が意図と仕様を定義し、AIエージェントは構造化されたチームとして協働します。

---

## エージェント構成（固定）

- Product Owner AI（1）
- Scrum Master AI（1）
- Development AI（8）
- QA / Quality AI（2）

---

## 役割

PO AI は目標と優先順位を定義し、SM AI はワークフローを統制し、Dev AI は実装を行い、QA AI は品質と適合性を保証します。

---

## アジャイルイベント

Sprint Planning、Daily Scrum、Sprint Review、Retrospective をシステムの基本イベントとします。

---

## 仕様主導開発

仕様は単一の真実であり、実装は常に仕様に対して検証されます。

---

## スキルシステム

スキルは繰り返しの行動から生まれる再利用可能な判断単位です。

---

## アーキテクチャ

役割ベース、イベント駆動、完全なトレーサビリティを前提とします。

---

## 哲学

仕様は意図を定義し、役割は責任を定義し、スキルは能力を定義し、イベントはリズムを定義します。

---

## 主要ドキュメント

- `Spec.md`: システム構成、役割、ワークフロー、制約
- `Plan.md`: 実装フェーズとタスク

---

## 前提条件

- macOS / Linux
- tmux
- Claude Code CLI (`claude-code`)
- Bash 4.0+

---

## はじめに

1. `Spec.md` を読み、システムアーキテクチャを理解します。
2. `Plan.md` を確認し、実装ロードマップを把握します。
3. （実装後）`scripts/ixv_boot.sh` を実行してエージェントチームを起動します。

---

## ディレクトリ構成（予定）

```
ixv-agents/
├── config/             # プロジェクト設定
├── frontend/           # React + Tailwind UI（ローカル・読み取り専用）
├── backend/            # ローカル読み取り専用サービス
├── instructions/       # 役割指示書（PO, SM, Dev, QA）
├── specs/              # 仕様（単一の真実）
├── queue/              # 通信バッファ
├── dashboard.md        # プロジェクト状況ボード
├── memory/             # MCP Memory
└── scripts/            # 起動スクリプト
```

---

## 運用原則

- **Single Source of Truth**: `specs/current_spec.md` を必ず参照
- **Traceability**: `spec_ref` / `request_id` / `task_id` で追跡
- **Role Boundaries**: 役割外のファイル更新は禁止

---

## ライセンス

TBD
