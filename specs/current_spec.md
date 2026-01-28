# Hello World Web App

## Metadata
- Version: 0.1.0
- Last Updated: 2026-01-28

## Goal
- ローカルで表示できる最小の Hello World Web App を作成し、UI とバックエンドの疎通を確認する

## Scope
- 含める範囲
  - フロントエンドで「Hello World」を表示
  - バックエンドの read-only API に接続できること
- 含めない範囲（Non-Goals）
  - 認証/認可
  - デプロイ
  - データ更新機能

## Requirements
- フロントエンドは React + Tailwind を使用
- バックエンドは read-only で `dashboard.md` と `queue/` を参照
- `spec_ref` と `task_id` が追跡できること

## Acceptance Criteria
- `Hello World` が UI に表示される
- `GET /api/dashboard` が `dashboard.md` を返す
- `GET /api/queue` が JSON を返す
- `spec_ref` と `task_id` がレポートで追跡できる

## Constraints
- ローカルのみで動作
- 外部API/ネットワークアクセスなし

## Dependencies
- Node.js
- npm

## Risks
- 環境差分による起動失敗

## Open Questions
- UI の見た目は最小でよいか
