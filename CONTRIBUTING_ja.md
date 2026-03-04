[English](./CONTRIBUTING.md) | [日本語](./CONTRIBUTING_ja.md)

# IXV-Agentsへの貢献

IXV-Agentsへの貢献に興味をお持ちいただきありがとうございます。このドキュメントでは、本プロジェクトへの貢献ガイドラインを説明します。

## 貢献の方法

### バグの報告

バグを発見した場合は、以下の情報を含めてGitHub Issueを作成してください：

- 明確で説明的なタイトル
- 問題を再現する手順
- 期待される動作
- 実際の動作
- サンプルファイルやスクリーンショット（該当する場合）
- 使用環境:
  - OS（macOS / Windows）
  - AIエディタ（OpenCode / Claude Code）とバージョン
  - tmuxまたはpsmuxのバージョン

### 機能改善の提案

機能提案を歓迎します。以下の情報を含めてIssueを作成してください：

- 明確で説明的なタイトル
- 提案する機能の詳細な説明
- ユースケースとメリット
- 関連する例やモックアップ（該当する場合）

### プルリクエスト

1. リポジトリを**フォーク**し、`main`からブランチを作成：
   ```bash
   git checkout -b yourname/20260301-add-feature
   ```

2. 既存のコードベースの**コーディングスタイルに準拠**（[コーディングガイドライン](#コーディングガイドライン)を参照）

3. **変更をテスト**：
   ```bash
   # ブートスクリプトの動作確認
   ./scripts/boot.sh
   ./scripts/stop.sh

   # PowerShellスクリプトを変更した場合は、Windowsでもテスト
   .\scripts\boot.ps1
   .\scripts\stop.ps1
   ```

4. 必要に応じて**ドキュメントを更新**：
   - ユーザー向けの変更: `README.md` と `README_ja.md` を更新
   - 仕様の変更: `Spec.md` を更新
   - 新機能: 使用例を追加

5. **明確なメッセージでコミット**（[コミットメッセージ](#コミットメッセージ)を参照）

6. **フォークにプッシュ**してプルリクエストを送信：
   ```bash
   git push origin yourname/20260301-add-feature
   ```

7. **レビューを待つ** — メンテナーがPRをレビューし、変更を依頼する場合があります

## 開発環境のセットアップ

### 前提条件

- macOSまたはWindows
- [tmux](https://github.com/tmux/tmux/wiki)（macOS）または [psmux](https://github.com/marlocarlo/psmux)（Windows）
- AIエディタ: [OpenCode](https://github.com/anomalyco/opencode) または [Claude Code](https://github.com/anthropics/claude-code)

### インストール

```bash
# フォークをクローン
git clone https://github.com/YOUR-USERNAME/ixv-agents.git
cd ixv-agents

# ワークスペースの初期化
./scripts/setup_workspace.sh
```

### 変更のテスト

PRを送信する前に、以下を確認してください：

1. ブートスクリプトが5つのエージェントペインを正しく起動すること
2. 停止スクリプトがすべてのプロセスをクリーンに終了すること
3. ワークスペースセットアップが期待されるディレクトリ構造を作成すること
4. スクリプトがmacOSとWindows の両方で動作すること（該当する場合）

> **注意:** IXV-Agentsには現在、自動テストスイートがありません。上記の手動確認が必要です。

## コーディングガイドライン

### シェルスクリプト (.sh)

- 先頭に `set -euo pipefail` を記載
- 4スペースでインデント
- すべての変数をクォート: `"${variable}"`
- ユーザー入力は使用前に検証

### PowerShellスクリプト (.ps1)

- 先頭に `$ErrorActionPreference = "Stop"` を記載
- 4スペースでインデント
- PowerShellの命名規則（動詞-名詞）に準拠

### Markdown (.md)

- 既存のフォーマット規則に準拠
- 内部参照には相対リンクを使用
- コードブロックには言語を指定（例: ` ```bash `、` ```yaml `）

### YAML (.yaml)

- 2スペースでインデント
- ISO-8601 UTCタイムスタンプ（`YYYY-MM-DDTHH:MM:SSZ`）を使用
- `skills/references/` で定義されたスキーマに準拠

## コミットメッセージ

現在形の命令形を使用してください。1行目は72文字以内に収めてください。

**良い例:**
```
Add Windows support for boot script

- Add boot.ps1 with psmux integration
- Add stop.ps1 with graceful shutdown
- Update README with Windows instructions

Closes #42
```

```
Fix agent startup race condition

Introduce staged startup with delays between agent launches
to avoid token refresh conflicts.
```

**避けるべき例:**
```
# 曖昧すぎる
Fixed stuff

# 過去形
Added new feature

# コンテキストがない
Update boot.sh
```

## ブランチ命名規則

以下の形式を使用してください：

```
{username}/{YYYYMMDD}-{description}
```

- `username`: 小文字のユーザー名（例: `tominaga`）
- `YYYYMMDD`: ブランチ作成日
- `description`: 小文字とハイフンのみの短い説明

**例:**
```
tominaga/20260301-add-windows-support
tanaka/20260215-fix-boot-race-condition
```

## コードレビュープロセス

1. メンテナーがプルリクエストをレビューします
2. 変更や質問が依頼される場合があります
3. 承認後、PRがマージされます
4. 貢献はリリースノートで謝辞が記載されます

## コミュニティガイドライン

- 敬意を持ち、包括的であること
- 建設的なフィードバックを提供すること
- 可能な限り他の人を助けること
- プロジェクトの行動規範に従うこと

## お問い合わせ

貢献に関するご質問：

- `question`ラベルを付けてIssueを作成: [GitHub Issues](https://github.com/elvezjp/ixv-agents/issues)
- 連絡先: info@elvez.co.jp
