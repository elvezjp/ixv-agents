# IXV-Agents 公開手順（リポジトリ可視性変更）

## 1. 事前チェック（推奨）

- **main ブランチの同期**
  - `git checkout main`
  - `git pull`
- **機密情報がないことの確認**
  - `README.md` / `README_ja.md` / `docs/` をざっと目視
  - API キーやパスワード、個人情報が含まれていないことを確認
- **不要な試験ブランチ・タグの整理（任意）**
  - 公開したくない一時的なブランチやタグがあれば削除しておく

### 公開前チェックリスト（2026-03-04 レビュー結果）

以下は公開ルール（`rules/rules/githubで公開する時/`）に基づく確認結果です。
対応状況を ✅（対応済み）/ ❌（要対応）/ ⚠️（改善推奨）で示します。

---

### A. ファイル・ディレクトリの問題

#### ❌ A-1. CHANGELOG.md が存在しない

リポジトリルートに `CHANGELOG.md` がありません。`changelog-requirements.md` ルールでは必須です。

**対処**: `CHANGELOG.md` を作成する。Keep a Changelog 形式 + セマンティックバージョニングに準拠すること。

#### ❌ A-2. `.cursor/skills/` が存在しない

`skill-requirements.md` ルールでは、公開リポジトリに `.cursor/skills/<skill-name>/SKILL.md` を配置することが必須です。

**対処**: プロジェクトに適した Cursor Skill を作成し、`.cursor/skills/` に配置する。

#### ❌ A-3. リンク切れ: `docs/` 内のファイルが存在しない

`README.md` / `README_ja.md` の Documentation セクションで参照している2ファイルが存在しません。

```
- docs/20260129implementation-plan.md
- docs/20260201directory-restructure-plan.md
```

**対処**: リンクを削除するか、該当ファイルを作成する。

#### ⚠️ A-4. `OLD/` ディレクトリがリポジトリに含まれている

レガシーコード（旧バックエンド/フロントエンド）21ファイルが git 追跡されています。ビルド済み `dist/` アセットや `package-lock.json` も含まれており、公開リポジトリとしては冗長です（ディスク上 61MB、node_modules 含む）。

**対処案**: 不要であれば削除して `.gitignore` に追加する。参照が必要なら別ブランチに退避する。

#### ✅ A-5. 空ディレクトリ: `src/sentinel/`, `tests/`（解決済み）

前回レビュー時に指摘された `src/sentinel/` と `tests/` は現在存在しません。

---

### B. README の問題（README.md / README_ja.md 共通）

#### ❌ B-1. 「変更履歴」セクションがない

`readme-requirements.md` では「変更履歴」は **必須** セクションです。`CHANGELOG.md` へのリンクを記載する必要があります。

**対処**: A-1 で CHANGELOG.md を作成後、両 README に「変更履歴」/「Changelog」セクションを追加する。

#### ❌ B-2. 「開発の背景」/「Background」セクションが定型文と異なる

`readme-requirements.md` では以下の定型文が必須です：

**日本語版:**
> 本ツールは、日本語の開発文書・仕様書を対象とした開発支援AI **IXV（イクシブ）** の開発過程で生まれた小さな実用品です。
> IXVでは、システム開発における日本語の文書について、理解・構造化・活用という課題に取り組んでおり、本リポジトリでは、その一部を切り出して公開しています。

**英語版:**
> This tool was created as a small utility during the development of **IXV (Ixiv)**, a development support AI for Japanese development documents and specifications.
> IXV addresses the challenges of understanding, structuring, and utilizing Japanese documents in system development. This repository publishes a portion of that work.

現在の README ではプロジェクト固有の説明が記載されていますが、ルール上の定型文とは異なります。

**対処**: 定型文をベースにしつつ、プロジェクトの性質（マルチエージェントオーケストレーション）に合わせた文言に調整する。必要に応じてルール承認者に確認。

#### ⚠️ B-3. 「コントリビューション」セクションに CONTRIBUTING.md へのリンクがない

`readme-requirements.md` では、CONTRIBUTING.md がある場合はそのファイルへのリンクを記載することが求められています。

**対処**: 「詳細は [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。」を追加する。

#### ⚠️ B-4. 「ドキュメント」セクションに CHANGELOG.md、CONTRIBUTING.md、SECURITY.md へのリンクがない

`readme-requirements.md` では、ドキュメントセクションに以下へのリンクを記載することが求められています：
- `CHANGELOG.md` - バージョン履歴
- `CONTRIBUTING.md` - コントリビューション方法
- `SECURITY.md` - セキュリティポリシー
- `.cursor/skills/` - Cursor Skill

**対処**: ドキュメントセクションにこれらのリンクを追加する。

#### ⚠️ B-5. バッジに言語/フレームワークのバッジがない

`readme-requirements.md` の必須バッジとして「言語/フレームワーク」が挙げられていますが、現在のバッジには含まれていません（Elvez、IXV Ecosystem、License、Stars のみ）。

**対処**: 使用している主要な言語・ツール（例: Shell、tmux 等）のバッジを追加する。

---

### C. SECURITY.md の問題

#### ⚠️ C-1. 報告に含めるべき情報が不足

`security-requirements.md` では、脆弱性報告に含めるべき情報（脆弱性の説明、再現手順、影響と重大度、修正案）を明記することが求められています。

**対処**: 「報告に含めるべき情報」セクションを追加する。

#### ⚠️ C-2. 対応スケジュールが不十分

現在は「3営業日以内に受領確認」のみですが、`security-requirements.md` では重大度に応じた解決目安の記載が求められています。

**対処**: 「対応スケジュール」セクションに状況更新・解決目安を追加する。

---

### D. CONTRIBUTING.md の問題

#### ⚠️ D-1. ブランチ命名規則が記載されていない

`contributing-requirements.md` では、ブランチ名の形式と具体例を記載することが求められています。

**対処**: ブランチ命名規則（`{ユーザー名}/{YYYYMMDD-内容}`）を追記する。

#### ⚠️ D-2. 機能改善提案の方法が記載されていない

`contributing-requirements.md` では、機能改善提案時に含めるべき情報を明記することが求められています。

**対処**: 「機能改善の提案」セクションを追加する。

---

### E. リポジトリ設定の問題

#### ❌ E-1. About（Description）が空

`repository-settings-requirements.md` では、リポジトリの目的を1行で記載することが必須です。現在空になっています。

**対処**: GitHub の Settings → General → About に Description を設定する。例: `Specification-driven AI development system with role-based multi-agent team`

#### ❌ E-2. Website が空

`repository-settings-requirements.md` では、WebサイトのURLを設定することが必須です。

**対処**: About の Website に `https://elvez.co.jp/` を設定する。

#### ❌ E-3. ブランチ保護ルールの確認が必要

`repository-settings-requirements.md` では、main ブランチに対して「Restrict deletions」「Block force pushes」のルールセットを設定することが必須です。リポジトリが private のため API で確認できませんでした。

**対処**: GitHub の Settings → Rules → Rulesets から確認・設定する。

---

### F. ドキュメント・コンテンツの追加作業

#### ❌ F-1. ユーザー向け詳細ガイドの作成

README の「エージェントチーム構成」「4つの原則」「7つのプロセス」以降のセクションをより詳しくまとめた資料が `docs/` に存在しません。公開にあたり、初見のユーザーがシステムの全体像を把握できるドキュメントが必要です。

**含めるべき内容**:
- エージェントの役割（PO / SM / Dev）の詳細と責任範囲
- 7工程の流れと各工程で作成・更新されるファイル
- tmux セッション上でのユーザー操作（PO ペインへの指示方法、セッション操作、進捗確認方法）
- queue/ によるエージェント間通信の仕組み
- ワークスペースのライフサイクル（初期化 → 開発 → バックアップ）

**対処**: `docs/` に詳細ガイド（例: `docs/user-guide.md`）を作成する。`Spec.md` および `templates/PROCESS.md` の内容を公開向けに再構成する。

#### ⚠️ F-2. Spec.md と skills/README.md の内容不一致

`Spec.md` のセクション5（エージェントワークフロー）と `skills/README.md`（スキルフローマップ）は同じ7工程を扱っていますが、以下の不一致があります：

- `Spec.md` はワークフローの手順と承認フローを記述し、`skills/README.md` はスキル名と依存関係を記述している。両者で工程の粒度や表現が異なる箇所がある
- `Spec.md` のディレクトリ構成（セクション4）にはまだ `config/` が含まれているが、現在のリポジトリには `config/` はルートに存在しない（`OLD/config/` のみ）
- `skills/README.md` のスキル一覧（13スキル）と `skills/` ディレクトリの実際のスキル数（13ディレクトリ + README.md + references/）は一致しているが、横断スキルの位置付けを明確にすべき

**対処**: `Spec.md` と `skills/README.md` を突き合わせて、ディレクトリ構成・工程記述・スキル一覧の整合性を取る。

#### ⚠️ F-3. `skills/coding-policy-ai-auditor` の扱いの検討

`coding-policy-ai-auditor` は汎用的なコーディングポリシー監査スキルで、`skills/README.md` では横断スキル（工程共通）として位置付けられています。

**現状の課題**:
- 元々は独立リポジトリ（[elvezjp/coding-policy-ai-auditor](https://github.com/elvezjp/coding-policy-ai-auditor)）の成果物であり、IXV-Agents 固有のスキルではない
- IXV-Agents のワークフロー（PO / SM / Dev のロール境界）とは直接連携していない
- 同じく横断スキルの `spec-code-reviewer-skill` は IXV-Agents のワークフローに統合されているが、`coding-policy-ai-auditor` はスタンドアロンで動作する設計
- SKILL.md に YAML frontmatter（name, description）がない（`skill-requirements.md` の要件を満たしていない）

**対処案**:
1. **残す場合**: YAML frontmatter を追加し、IXV-Agents 内での使用シーン（Dev の実装時にポリシー監査を行う等）を SKILL.md に明記する
2. **削除する場合**: `skills/README.md` のスキル一覧から除外し、元の独立リポジトリを参照先として README に記載する
3. **移動する場合**: `skills/` から外して `docs/` や README の「関連プロジェクト」セクションでリンクのみ記載する

---

### 対応優先度まとめ

| 優先度 | ID | 項目 | 種別 |
|--------|----|------|------|
| **高** | A-1 | CHANGELOG.md の作成 | ファイル |
| **高** | A-2 | .cursor/skills/ の作成 | ファイル |
| **高** | A-3 | リンク切れの修正 | README |
| **高** | B-1 | 「変更履歴」セクションの追加 | README |
| **高** | E-1 | リポジトリ Description の設定 | GitHub設定 |
| **高** | E-2 | リポジトリ Website の設定 | GitHub設定 |
| **高** | E-3 | ブランチ保護ルールの確認・設定 | GitHub設定 |
| **中** | B-2 | 「開発の背景」定型文の確認 | README |
| **中** | B-3 | Contributing に CONTRIBUTING.md リンク追加 | README |
| **中** | B-4 | ドキュメントセクションのリンク追加 | README |
| **中** | B-5 | 言語/フレームワークバッジの追加 | README |
| **中** | C-1 | SECURITY.md に報告情報を追加 | SECURITY |
| **中** | C-2 | SECURITY.md に対応スケジュール追加 | SECURITY |
| **中** | D-1 | CONTRIBUTING.md にブランチ命名規則追加 | CONTRIBUTING |
| **中** | D-2 | CONTRIBUTING.md に機能改善提案追加 | CONTRIBUTING |
| **中** | F-1 | ユーザー向け詳細ガイドの作成 | ドキュメント |
| **中** | F-2 | Spec.md と skills/README.md の整合性確認 | ドキュメント |
| **中** | F-3 | coding-policy-ai-auditor の扱いの検討 | スキル |
| **低** | A-4 | OLD/ ディレクトリの整理 | ファイル |

---

## 2. GitHub Web UI から公開する手順

1. ブラウザでリポジトリを開く
   `https://github.com/elvezjp/ixv-agents`
2. 上部メニューから **「Settings」** を開く（リポジトリ単位の設定）
3. 左メニューの **「General」** を選択
4. ページ下部の **「Danger Zone」** セクションまでスクロール
5. **「Change repository visibility」** をクリック
6. 表示されたダイアログで **「Public」** を選択
7. 確認用にリポジトリ名 `elvezjp/ixv-agents` を入力
8. **「I understand, change repository visibility」** をクリックして確定

## 3. CLI（gh）で公開する場合（オプション）

リポジトリのルートディレクトリで、以下を実行する。

```bash
# 可視性を public に変更
gh repo edit --visibility public
```

エラーが出なければ、GitHub 上でリポジトリが Public に変更される。
