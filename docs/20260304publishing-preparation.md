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

### 公開前チェックリスト（2026-03-04 再レビュー結果）

公開ルール（`rules/rules/githubで公開する時/`）に基づく確認結果です。
参考リポジトリ: `REFERENCE_FOR_PUBLISH/spec-code-ai-reviewer`（公開済み）
対応状況を ✅（対応済み）/ ❌（要対応）/ ⚠️（改善推奨）で示します。

> **調査対象外**: repository-settings-requirements.md、skill-requirements.md（把握済み）

---

### A. ファイル・ディレクトリの問題

#### ✅ A-1. CHANGELOG.md（作成済み）

`CHANGELOG.md` を v0.1.0 初回公開リリースとして作成済み。

**残課題**: 参考リポジトリは日本語（「追加」「修正」「変更」）で記載。現在は英語。日本語に統一する場合は書き換えが必要。

#### ❌ A-2. `.cursor/skills/` が存在しない

`skill-requirements.md` ルールでは必須。（調査対象外・把握済み）

#### ❌ A-3. リンク切れ: `docs/` 内の2ファイルが存在しない

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

#### ❌ B-1. 「変更履歴」/「Changelog」セクションがない

`readme-requirements.md` では **必須** セクション。`CHANGELOG.md` へのリンクを記載する必要があります。

**対処**: 両 README に「変更履歴」/「Changelog」セクションを追加し、`CHANGELOG.md` へリンクする。

**参考リポの記載例**: `## Update History` / `詳細は [CHANGELOG.md](CHANGELOG.md) を参照してください。`

#### ❌ B-2. 「開発の背景」/「Background」セクションが定型文と異なる

`readme-requirements.md` では以下の定型文が必須ですが、現在の README ではプロジェクト固有の説明のみ。

**日本語定型文:**
> 本ツールは、日本語の開発文書・仕様書を対象とした開発支援AI **IXV（イクシブ）** の開発過程で生まれた小さな実用品です。
> IXVでは、システム開発における日本語の文書について、理解・構造化・活用という課題に取り組んでおり、本リポジトリでは、その一部を切り出して公開しています。

**対処**: IXV-Agents は「小さな実用品」ではなくエコシステムの中核のため、定型文をそのまま使うか調整するかルール承認者に確認が必要。

#### ⚠️ B-3. 「コントリビューション」セクションに CONTRIBUTING.md へのリンクがない

**対処**: 「詳細は [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。」を追加する。

**参考リポの記載**: Contributing セクションに `CONTRIBUTING.md` へのリンクあり。

#### ⚠️ B-4. 「ドキュメント」セクションに CHANGELOG / CONTRIBUTING / SECURITY リンクがない

**対処**: ドキュメントセクションに以下を追加する:
- [CHANGELOG.md](CHANGELOG.md) - バージョン履歴
- [CONTRIBUTING.md](CONTRIBUTING.md) - コントリビューション方法
- [SECURITY.md](SECURITY.md) - セキュリティポリシー

**参考リポの記載**: Documentation セクションに全ファイルへのリンクあり。

#### ⚠️ B-5. バッジに言語/フレームワークのバッジがない

**対処**: Shell / PowerShell バッジを追加する。

**参考リポのバッジ**: Elvez、IXV Ecosystem、License、Python、TypeScript、Stars の6種。

---

### C. SECURITY.md の問題

参考リポ（165行）と比較して、現在のファイル（66行）は以下が不足:

#### ❌ C-1. 「報告に含めるべき情報」セクションがない

`security-requirements.md` の必須項目。参考リポでは5項目（脆弱性の説明、再現手順、影響と重大度、修正案、連絡先）を明記。

**対処**: 参考リポに倣い「報告に含める内容」セクションを追加する。

#### ❌ C-2. 「報告例」がない

参考リポでは具体的な報告テンプレート（件名、説明、再現手順、影響、修正案）をコードブロックで掲載。

**対処**: IXV-Agents に適した報告例を追加する。

#### ❌ C-3. 「対応スケジュール」が不十分

現在は「3営業日以内に受領確認」のみ。参考リポでは:
- 初回応答: 48時間以内
- 状況更新: 7日以内
- 解決: 緊急14日 / 高30日 / 中60日 / 低:次回リリース

**対処**: 重大度別の対応スケジュールを追加する。

#### ⚠️ C-4. 「セキュリティのベストプラクティス」が簡素

現在4項目。参考リポでは7項目（番号付き、具体的な推奨事項）。

**対処**: 項目を拡充する（最新版の使用、入力確認、サンドボックス処理、出力検証、権限制限、依存関係監視、認証情報保護）。

#### ⚠️ C-5. 「既知のセキュリティ制限」が独立セクションになっていない

現在は本文中に注記として記載。参考リポでは独立セクションに項目を列挙。

**対処**: 「既知のセキュリティ制限」セクションを追加し、制限事項を列挙する。

#### ⚠️ C-6. 「セキュリティアップデート」セクションがない

参考リポではパッチ/マイナーバージョンでのリリース方針を記載。

**対処**: セキュリティアップデートのリリース方針を追加する。

#### ⚠️ C-7. 「謝辞」セクションがない

参考リポでは脆弱性報告者への謝辞方法を記載。

**対処**: 謝辞セクションを追加する。

#### ⚠️ C-8. 「問い合わせ先」セクション（脆弱性以外）がない

`security-requirements.md` の必須項目。参考リポでは「security」ラベルでIssue作成する方法を記載。

**対処**: セキュリティ関連の一般的な質問方法を追加する。

---

### D. CONTRIBUTING.md の問題

参考リポ（200行）と比較して、現在のファイル（40行）は大幅に不足:

#### ❌ D-1. バグ報告の必須情報が不足

現在は「OS と AI エディタを記載」のみ。`contributing-requirements.md` では以下が必須:
- 明確で説明的なタイトル
- 問題を再現する手順
- 期待される動作
- 実際の動作
- サンプルファイル（可能であれば）
- バージョン情報

**参考リポの記載**: 8項目を箇条書きで明記。

#### ❌ D-2. 機能改善の提案セクションがない

`contributing-requirements.md` の必須項目。参考リポでは以下を記載:
- タイトル、詳細説明、ユースケースとメリット、関連する例やモックアップ

#### ❌ D-3. ブランチ命名規則が記載されていない

`contributing-requirements.md` の必須項目。参考リポでは `user/YYYYMMDD-content` 形式をコマンド例付きで記載。

#### ❌ D-4. 開発環境のセットアップが具体的でない

現在は「See README.md for prerequisites and setup instructions.」のみ。`contributing-requirements.md` では前提条件・インストール手順を具体的なコマンドで記載することが必須。

**参考リポの記載**: 前提条件（Python 3.10+, Node.js 20+, uv）、clone〜依存関係インストールのコマンドを記載。

#### ❌ D-5. テストの実行方法が記載されていない

`contributing-requirements.md` の必須項目。（IXV-Agents にはテストスイートが存在しないため「該当なし」でも明記すべき）

#### ⚠️ D-6. コミットメッセージの例がない

現在はルールのみ。参考リポでは良い例（現在形・命令形・72文字制限）と具体例をコードブロックで記載。

#### ⚠️ D-7. コードレビュープロセスが記載されていない

参考リポでは4ステップ（レビュー → 変更依頼 → 承認 → マージ）で記載。

#### ⚠️ D-8. コミュニティガイドラインが記載されていない

参考リポでは敬意・建設的フィードバック・行動規範への言及を記載。

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

### G. LICENSE（問題なし）

✅ すべてのルール要件を満たしています。

| 項目 | 状況 |
|------|------|
| ライセンス種類（MIT License） | ✅ |
| 著作権表示（Copyright (c) 2026 Elvez, Inc.） | ✅ |
| 標準テンプレート準拠 | ✅ |
| ファイル名・配置（`LICENSE`、ルート） | ✅ |
| README との整合性 | ✅ |

---

### 対応優先度まとめ

| 優先度 | ID | 項目 | 種別 |
|--------|----|------|------|
| **高** | A-3 | リンク切れの修正 | README |
| **高** | B-1 | 「変更履歴」セクションの追加 | README |
| **高** | B-2 | 「開発の背景」定型文の確認 | README |
| **高** | C-1 | SECURITY.md に報告情報セクション追加 | SECURITY |
| **高** | C-2 | SECURITY.md に報告例追加 | SECURITY |
| **高** | C-3 | SECURITY.md に対応スケジュール追加 | SECURITY |
| **高** | D-1 | CONTRIBUTING.md バグ報告の必須情報追加 | CONTRIBUTING |
| **高** | D-2 | CONTRIBUTING.md 機能改善提案セクション追加 | CONTRIBUTING |
| **高** | D-3 | CONTRIBUTING.md ブランチ命名規則追加 | CONTRIBUTING |
| **高** | D-4 | CONTRIBUTING.md 開発環境セットアップ詳細化 | CONTRIBUTING |
| **高** | D-5 | CONTRIBUTING.md テスト実行方法の記載 | CONTRIBUTING |
| **中** | A-1 | CHANGELOG.md の日本語化検討 | CHANGELOG |
| **中** | B-3 | Contributing に CONTRIBUTING.md リンク追加 | README |
| **中** | B-4 | ドキュメントセクションのリンク追加 | README |
| **中** | B-5 | 言語/フレームワークバッジの追加 | README |
| **中** | C-4 | SECURITY.md ベストプラクティス拡充 | SECURITY |
| **中** | C-5 | SECURITY.md 既知の制限を独立セクション化 | SECURITY |
| **中** | C-6 | SECURITY.md セキュリティアップデート方針追加 | SECURITY |
| **中** | C-7 | SECURITY.md 謝辞セクション追加 | SECURITY |
| **中** | C-8 | SECURITY.md 問い合わせ先（脆弱性以外）追加 | SECURITY |
| **中** | D-6 | CONTRIBUTING.md コミットメッセージ例追加 | CONTRIBUTING |
| **中** | D-7 | CONTRIBUTING.md コードレビュープロセス追加 | CONTRIBUTING |
| **中** | D-8 | CONTRIBUTING.md コミュニティガイドライン追加 | CONTRIBUTING |
| **中** | F-1 | ユーザー向け詳細ガイドの作成 | ドキュメント |
| **中** | F-2 | Spec.md と skills/README.md の整合性確認 | ドキュメント |
| **中** | F-3 | coding-policy-ai-auditor の扱いの検討 | スキル |
| **低** | A-4 | OLD/ ディレクトリの整理 | ファイル |
| **対象外** | A-2 | .cursor/skills/ の作成 | ファイル |
| **対象外** | E-1〜3 | リポジトリ設定（Description/Website/ブランチ保護） | GitHub設定 |

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
