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

### 既知の注意事項（2026-03-03 最終レビュー結果）

以下は公開前に対応を推奨する項目です。いずれもセキュリティ上の問題ではなく、品質・見栄えに関するものです。

#### 1. リンク切れ: `docs/` ディレクトリが存在しない

`README.md` / `README_ja.md` の Documentation セクションで参照している2ファイルが存在しません。

```
- docs/20260129implementation-plan.md
- docs/20260201directory-restructure-plan.md
```

**対処案**: リンクを削除するか、該当ファイルを作成する。

#### 2. `OLD/` ディレクトリがリポジトリに含まれている

レガシーコード（旧バックエンド/フロントエンド）21ファイルが git 追跡されています。ビルド済み `dist/` アセットや `package-lock.json` も含まれており、公開リポジトリとしては冗長です。

**対処案**: 不要であれば削除して `.gitignore` に追加する。参照が必要なら別ブランチに退避する。

#### 3. 空ディレクトリ: `src/sentinel/`, `tests/`

いずれも中身が空のため、未完成の印象を与える可能性があります。

**対処案**: 使用予定がなければ削除する。将来用であれば `.gitkeep` を置くか README で説明する。

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
