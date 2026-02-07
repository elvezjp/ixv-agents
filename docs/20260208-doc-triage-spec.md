# Doc Triage: PP-DocLayout + LLM による重要ページ特定機能

## 概要

大規模ドキュメント（PDF/画像）から**重要なページを自動特定**し、効率的に情報を抽出する機能。PP-DocLayoutによる高速な構造解析と、LLMによる重要度スコアリングを2段階で組み合わせることで、コストと精度を両立する。

## 背景と動機

IXV-Agentsは仕様駆動のマルチエージェント開発システムであり、`workspace/README.md`をSSoT（Single Source of Truth）として運用する。しかし、企業には既にPDF/画像形式の仕様書・設計書・要件定義書が大量に存在し、これらをIXV-Agentsに取り込むには手動でMarkdown化する必要がある。

人間がドキュメントを読む際、最初に重要なページを特定してから精読する。この自然なアプローチを自動化することで、既存ドキュメントの取り込みを根本的に効率化する。

## なぜこのアプローチが優れているか

### コスト構造の最適化

大規模ドキュメント処理の最大のボトルネックは**全ページをLLMに投入するコストと時間**である。PP-DocLayoutとLLMを2段階に分けることで、これを根本的に解決できる。

```
[100ページのPDF]
    │
    ▼ Stage 1: PP-DocLayout（構造解析）── 高速・低コスト
    │  全ページのレイアウト要素を抽出
    │  （テーブル数、タイトル階層、図の有無、等）
    │
    ▼ Stage 2: LLM（重要度スコアリング）── 軽量な判定
    │  構造メタデータだけをLLMに渡して重要ページを特定
    │  入力トークンが極めて少ない → 安価
    │
    ▼ Stage 3: 重要ページのみ全文処理 ── 集中投資
       OCR + LLMによる詳細解析（10〜20ページに絞込み）
```

### 構造情報が持つ重要度シグナル

PP-DocLayoutが返すレイアウト要素には、LLMに渡さなくても分かるシグナルが豊富にある。Stage 1の構造情報だけで「重要度の手がかり」が十分に得られることが、このアプローチの核心である。

| レイアウト要素 | 重要度シグナル |
|---|---|
| テーブル + テーブルタイトル | 仕様・比較・データ → 高確率で重要 |
| 要約(Abstract) | 文書全体のサマリ → 必ず重要 |
| 目次(Content) | 文書構造の把握 → 重要 |
| 数式 + アルゴリズム | 技術的核心部分 |
| 図 + チャート + タイトル | ビジュアル情報の集中箇所 |
| テキストのみ（長文） | 本文の詳細 → 文脈次第 |
| ページ番号 + ヘッダーのみ | 空白・区切りページ → 低重要度 |

### Stage 2のトークン効率

Stage 2のLLMには、各ページの「要素リスト」だけを渡せばよい。例えば100ページの文書でも数百トークンで済む。全ページのOCR結果をLLMに投入する場合と比較して、桁違いにコストが低い。

### PP-DocLayout-Sの軽量性

PP-DocLayout-Sモデルは以下の性能を持ち、Stage 1のコストはほぼゼロである。

- T4 GPU: 8.1ms/ページ（秒間約123ページ）
- CPU: 14.5ms/ページ
- パラメータ数: 1.21M

開発マシン上で追加インフラなしに動作可能。数値は参考値であり、実測で再検証する。

## PP-DocLayout 技術仕様

### 検出可能な23カテゴリ

段落タイトル、画像、テキスト、ページ番号、要約、目次、図タイトル、数式、テーブル、テーブルタイトル、参考文献、文書タイトル、脚注、ヘッダー、アルゴリズム、フッター、印鑑、チャートタイトル、チャート、数式番号、ヘッダー画像、フッター画像、傍注

### モデルバリアント

| モデル | mAP@0.5 | GPU推論速度 | CPU推論速度 | パラメータ数 |
|--------|---------|------------|------------|------------|
| PP-DocLayout-L | 90.4% | 13.4ms/ページ | 759.76ms/ページ | 30.94M |
| PP-DocLayout-M | 75.2% | 12.7ms/ページ | 59.82ms/ページ | 5.65M |
| PP-DocLayout-S | 70.9% | 8.1ms/ページ | 14.5ms/ページ | 1.21M |

### 対応ドキュメント形式

中国語・英語の学術論文、研究報告書、試験問題、書籍、新聞、雑誌

### 利用方法（Python）

```python
# PaddleOCR統合（推奨）
from paddleocr import PPStructureV3
pipeline = PPStructureV3(layout_detection_model_name="PP-DocLayout-L")
output = pipeline.predict("./document.pdf")
for res in output:
    res.save_to_markdown(save_path="output")

# レイアウト検出のみ
from paddleocr import LayoutDetection
model = LayoutDetection(model_name="PP-DocLayout-S")
output = model.predict("image.jpeg", batch_size=1)
for res in output:
    res.print()

# PaddleX経由
from paddlex import create_model
model = create_model(model_name="PP-DocLayout_plus-L")
output = model.predict("layout.jpg", batch_size=1, layout_nms=True)
for res in output:
    res.save_to_json(save_path="./output/res.json")
```

## IXV-Agentsとの統合設計

### 配置構成

この「重要ページ特定」は汎用的な前処理ユーティリティとして切り出す。POのリサーチにも、Devのタスク入力にも、Verifyの品質検証にも使える共通基盤となる。

```
workspace/
├── tools/
│   └── doc_triage/        # ドキュメントトリアージツール
│       ├── analyze.py     # PP-DocLayout → 構造メタデータ
│       ├── score.py       # LLM → 重要度スコアリング
│       └── extract.py     # 重要ページの全文抽出・Markdown化
```

### 主要I/O仕様（案）

ツール自体は汎用的に設計し、IXV-Agentsのrequest_idとの紐付けは統合層で行う。

```
# tools/doc_triage/analyze.py
input:
  - path: "docs/existing_spec.pdf"
  - output_dir: ".triage/existing_spec/"    # 任意。省略時はパスから自動生成
output: ".triage/existing_spec/layout.json"

# layout.json（1ページ=1エントリ）
{
  "source": "docs/existing_spec.pdf",
  "model": "PP-DocLayout-S",
  "total_pages": 100,
  "pages": [
    {
      "page": 1,
      "elements": [
        {"type": "document_title", "bbox": [x1, y1, x2, y2], "confidence": 0.97},
        {"type": "table", "bbox": [x1, y1, x2, y2], "confidence": 0.93},
        {"type": "table_title", "bbox": [x1, y1, x2, y2], "confidence": 0.88}
      ],
      "stats": {
        "num_tables": 1,
        "num_figures": 0,
        "num_formulas": 0,
        "num_text_blocks": 3,
        "num_titles": 2
      }
    }
  ]
}

# tools/doc_triage/score.py
input:
  - layout: ".triage/existing_spec/layout.json"
  - top_k: 12                    # 上位K件を選定（top_kかmin_scoreのいずれかを指定）
  - min_score: null              # 最低スコア閾値（nullの場合top_kを使用）
  - focus: ["table", "abstract"]  # 注目する要素タイプ（該当要素に加点）
output: ".triage/existing_spec/score.json"

# score.json
{
  "source": "docs/existing_spec.pdf",
  "params": {"top_k": 12, "min_score": null, "focus": ["table", "abstract"]},
  "total_pages": 100,
  "pages": [
    {
      "page": 1,
      "score": 0.91,
      "rule_score": 0.85,         # ルールベース部分のスコア
      "llm_score": 0.95,          # LLM判定部分のスコア
      "signals": ["table_with_title", "document_title"],
      "rule_applied": "high"      # "high" | "low" | "none"（ルールで確定した場合）
    }
  ],
  "selected_pages": [1, 2, 5, 10],
  "selection_method": "top_k",
  "total_selected": 4,
  "reduction_ratio": 0.96         # 1 - (total_selected / total_pages) = 削減率
}

# tools/doc_triage/extract.py
input:
  - path: "docs/existing_spec.pdf"
  - selected_pages: [1, 2, 5, 10]
output: ".triage/existing_spec/extracted.md"
```

#### IXV-Agentsとの紐付け

IXV-Agentsから利用する場合、統合層がrequest_idとoutput_dirを対応付ける。

```
.triage/
├── existing_spec/           # ツール側のディレクトリ（ソースファイル名ベース）
│   ├── layout.json
│   ├── score.json
│   └── extracted.md
└── manifest.yaml            # IXV-Agents統合層が管理
    # - request_id: REQ-20260208-001
    #   source: docs/existing_spec.pdf
    #   triage_dir: .triage/existing_spec/
```

### 利用フロー例: POが仕様書PDFを取り込む場合

```yaml
# queue/po_to_sm.yaml
spec_ref: README.md
request_id: "REQ-20260208-001"
summary: "既存設計書から要件を抽出"
inputs:
  - path: "docs/existing_spec.pdf"
    triage: true           # 重要ページ特定を実行
    focus: ["table", "abstract", "chart"]  # 注目する要素タイプ
```

### 活用シナリオ

#### シナリオ1: 既存仕様書の自動取り込み（POフェーズ）

PP-DocLayoutで文書構造を解析し、自動的にIXV-Agentsの`workspace/README.md`形式に変換する。

- テーブル → 受入基準やConstraintsセクションへ
- 数式 → 技術仕様セクションへ
- 図・チャート → 参照リンク付きで配置
- 段落タイトル＋テキスト → Why/What/Scopeセクションへマッピング

#### シナリオ2: Dev向け図面読み取りスキル

PP-DocLayoutをMCPサーバーまたはスキルとして統合し、Devが画像/PDFドキュメントの構造を理解可能にする。

```yaml
# queue/tasks/dev1.yaml に追加できるinput type
inputs:
  - type: "document"
    path: "docs/ui_wireframe.pdf"
    layout_analysis: true  # PP-DocLayoutで前処理
```

#### シナリオ3: 納品物の品質検証（Verifyフェーズ）

PP-DocLayoutで生成ドキュメントのレイアウトを解析し、以下を自動チェック:

- ヘッダー/フッターの一貫性
- テーブルの崩れ検出
- 図の欠落（図タイトルに対応する画像がない等）
- ページ番号の連続性

#### シナリオ4: 競合・参考文献の構造化リサーチ

PP-DocLayoutで学術論文・技術レポートを構造化し、POエージェントが自動的に要約抽出、参考文献の構造化、テーブル・チャートのデータ抽出、競合比較表の生成を行う。

#### シナリオ5: ドキュメント変更差分の構造的追跡

PP-DocLayoutで新旧ドキュメントの両方を構造解析し、構造レベルでの差分検出を行う。差分を`queue/po_to_sm.yaml`の形式で自動生成し、SMに変更指示として送信する。

## 重要度スコアリング設計（Stage 2）

### ルール + LLMのハイブリッドアーキテクチャ

スコアリングは3段階で行う。ルールで確定できるものを先に処理し、LLMの呼び出しを最小化する。

```
[layout.json]
    │
    ▼ Step 2a: ルールベース判定（確定）
    │  高重要度 / 低重要度をルールで確定
    │  → rule_applied: "high" or "low"
    │
    ▼ Step 2b: LLMスコアリング（残りのページのみ）
    │  ルールで確定しなかったページだけをLLMに投入
    │  → llm_score
    │
    ▼ Step 2c: 統合スコア算出 + ページ選定
       rule_score と llm_score を加重平均 → 最終score
       top_k または min_score で選定
```

### Step 2a: ルールベース判定

「構造情報が持つ重要度シグナル」セクションのシグナル表を判定ルールとして使用する。

**高重要度ルール（score = 1.0 で確定）:**

| 条件 | 根拠 |
|---|---|
| 要約(abstract)を含む | 文書全体のサマリ → 必ず重要 |
| 目次(content)を含む | 文書構造の全体把握 |
| 文書タイトル(document_title)を含む | 文書の入口ページ |

**低重要度ルール（score = 0.0 で確定）:**

| 条件 | 根拠 |
|---|---|
| ページ番号 + ヘッダー/フッターのみ | 空白・区切りページ |
| ヘッダー画像 or フッター画像のみ | 装飾ページ |
| 要素数が0 | 空ページ |

**加点シグナル（ルールで確定せず、rule_scoreとして渡す）:**

| 要素 | 加点 | 根拠 |
|---|---|---|
| テーブル + テーブルタイトル | +0.3 | 仕様・比較・データ |
| 数式 + アルゴリズム | +0.2 | 技術的核心部分 |
| 図 + チャート + タイトル | +0.2 | ビジュアル情報の集中箇所 |
| 参考文献 | +0.1 | 関連資料の把握 |
| 段落タイトルが2個以上 | +0.1 | セクション開始ページ |

rule_scoreは加点の合計を0.0〜1.0にクリップする。`rule_applied="high"/"low"` の場合は `rule_score=1.0/0.0` とし、`llm_score` は `null` とする。

### Step 2b: LLMスコアリング

ルールで確定しなかったページのみLLMに投入する。

**入力フォーマット（LLMプロンプト）:**
- 文書全体のページ数と各ページの要素タイプ一覧 + 要素数 + 見出し階層
- OCR本文は渡さない（Stage 2では不要）
- `focus`パラメータがある場合は「注目すべき要素タイプ」としてプロンプトに含める
- `focus`の値はPP-DocLayoutのカテゴリ名に合わせる（例: `table`, `abstract`, `content`, `chart`, `figure_title`）

**出力:** 各ページの重要度を0.0〜1.0のスコアで返す

### Step 2c: 統合スコアと選定

```
最終score = rule_score × 0.4 + llm_score × 0.6
（ルール確定ページは最終score = 1.0 or 0.0 のまま）
```

- `focus`が指定された場合、該当要素を含むページに +0.15 の加点
- `top_k` か `min_score` のどちらかを指定（既定値: `top_k=12`）
- 両方指定した場合は `min_score` でフィルタ後に `top_k` で切り詰め
- `top_k` で同点が発生する場合は `page` の昇順で安定化させる

## 品質評価と受け入れ基準

### 正解データの定義

「重要ページ」の正解ラベルは以下の手順で作成する。

1. **ベンチマーク文書を5〜10件選定する**
   - 日本語の技術仕様書（2件以上）
   - 英語の学術論文（2件以上）
   - 混合形式（報告書・提案書等、1件以上）
   - 各50ページ以上のものを選ぶ
2. **人間が各ページに重要度ラベルを付与する**
   - `essential`: この文書を理解するために必ず読むべきページ
   - `useful`: 読むと有益だが、なくても文書の骨子は把握できるページ
   - `skip`: 読み飛ばしても問題ないページ
3. **Recall@Kの正解 = `essential` ラベルのページ集合**
   - `useful`はPrecision計算時の許容範囲として扱う（選ばれても誤検知としない）

### 評価指標

- **Recall@K**: `essential`ページの取りこぼし率（最優先）
- **Precision@K**: 選定ページ中の`essential` + `useful`の割合（`skip`の混入を測る）
- **Cost reduction**: 1 - (selected_pages / total_pages)
- **Latency**: 100ページ当たりのStage 1+2合計処理時間

### MVP受け入れ基準（暫定）

- `essential`ページのRecall@Kが80%以上（ベンチマーク全文書の平均）
- Precision@K（`skip`の混入率）が30%以下
- 100ページあたりのLLM投入ページ数が20ページ以下
- Stage 1+2合計処理が60秒以内（CPU実行）

## 実装方針

1. **段階的に実装する** — まずStage 1+2（ページ特定）だけ作り、Stage 3は後から拡張可能
2. **PP-DocLayout-Sから始める** — CPUで十分動作し、精度70.9%でも構造解析には十分
3. **日本語精度の早期検証** — MVP前にベンチマーク文書で日本語レイアウト検出精度を実測する（後述「リスクと対策」参照）
4. **コスト削減効果が明確** — 100ページ中10ページだけ処理すれば、LLM呼び出しコストが1/10

## 運用・セキュリティ

- `.triage/` 配下に中間成果物を保存し、破棄ポリシーを明確化
- 外部LLM利用時は文書パス/内容が送信されないよう、Stage 2の入力を構造メタデータに限定
- 監査目的で `score.json` と `selected_pages` をログに残す

## リスクと対策

| 優先度 | リスク | 影響 | 対策 |
|---|---|---|---|
| **高** | 日本語ドキュメントの精度低下 | PP-DocLayoutの学習データは中国語・英語が中心。日本語レイアウトは類似するが未検証であり、Stage 1の信頼性に直結する | MVP前にベンチマーク文書3件以上で日本語レイアウト検出精度を実測。mAP@0.5が60%未満の場合、(a) PP-DocLayout-M/Lへの切替、(b) 日本語データでのファインチューニング、(c) 代替モデル（DocLayout-YOLO等）の検討を行う |
| 中 | 図・表が多い資料で過検知 | テーブルや図が全ページにある資料では、ほぼ全ページが「重要」と判定される | ルール側でページ当たりの要素密度を正規化し、文書全体の分布に対する相対評価にする |
| 中 | Scan品質の悪さ | 低解像度・斜めスキャンではPP-DocLayoutの検出精度が低下する | 前処理パイプライン（回転補正・2値化）を検討。PaddleOCRのPPStructureV3は文書方向分類・歪み補正機能を内蔵しており、これを活用する |
| 低 | 分割PDF/ページ順の欠落 | 複数ファイルに分割されたPDFではページ番号の連続性が失われる | ページ番号の連続性チェックを入れ、欠損がある場合は警告を出す |

## 追加で決めるべき点

- ベンチマーク文書の選定（5〜10件）
- LLMモデルと温度（推論の再現性優先）
- `focus` のデフォルト値と重み付け
- `top_k` と `min_score` の初期設定

## 参考資料

- [PP-DocLayout 論文 (arXiv)](https://arxiv.org/html/2503.17213v1)
- [PP-DocLayout-L (Hugging Face)](https://huggingface.co/PaddlePaddle/PP-DocLayout-L)
- [PaddleOCR GitHub](https://github.com/PaddlePaddle/PaddleOCR)
- [PaddleX Layout Detection ドキュメント](https://paddlepaddle.github.io/PaddleX/3.3/en/module_usage/tutorials/ocr_modules/layout_detection.html)
- [PPStructureV3 使い方](https://paddlepaddle.github.io/PaddleOCR/main/en/version3.x/pipeline_usage/PP-StructureV3.html)
