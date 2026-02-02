# PP-DocLayout活用による重要ページ抽出（スペック）

## 目的
- 開発文書（PDF/画像）から「重要ページ」をページ単位で抽出する。
- 重要ページの候補を人が素早くレビューできるように、レイアウト可視化画像を出力する。

## 対象と前提
- 入力: PDFまたは画像（中〜高品質）
- 粒度: ページ単位の選別
- 既存OCR/検索基盤: なし
- 主要ユースケース: 開発文書内の重要ページの洗い出し
  - アーキテクチャ
  - データベーススキーマ
  - スケジュール

## 用語
- 重要ページ: 図・表・見出し等のレイアウト特徴から「重要」と判断されるページ
- 可視化画像: レイアウト検出結果の枠を元画像に重ねた画像

## 実行環境要件

### Python
- Python: 3.9〜3.11（PaddlePaddle互換）

### PaddlePaddle

```bash
# GPU使用時（CUDA 11.8）
python -m pip install paddlepaddle-gpu==3.0.0 -i https://www.paddlepaddle.org.cn/packages/stable/cu118/

# GPU使用時（CUDA 12.6）
python -m pip install paddlepaddle-gpu==3.0.0 -i https://www.paddlepaddle.org.cn/packages/stable/cu126/

# CPU使用時
python -m pip install paddlepaddle==3.0.0 -i https://www.paddlepaddle.org.cn/packages/stable/cpu/
```

### PaddleOCR
- paddleocr>=2.7.0

```bash
python -m pip install paddleocr
```

### モデルweights
- 初回実行時に自動ダウンロード
- 事前配置する場合は PaddleOCR の既定キャッシュパスに従う（環境差があるため固定パスは指定しない）

### GPU/CPU要件

| 環境 | 要件 | 処理速度目安 |
|------|------|-------------|
| **GPU（推奨）** | CUDA 11.8+ / cuDNN 8.6+ | 〜0.5秒/ページ |
| **CPU** | 動作可能 | 〜2秒/ページ（5〜10倍遅い） |

### 環境確認コマンド

```bash
# PaddlePaddleインストール確認
python -c "import paddle; print(paddle.__version__); paddle.utils.run_check()"

# GPU認識確認
python -c "import paddle; print(paddle.device.get_device())"
```

## 依存ライブラリ

### requirements.txt（共通）

```
# PaddlePaddle（環境に応じてGPU/CPU版を選択）
# paddlepaddle-gpu==3.0.0  # GPU
# paddlepaddle==3.0.0      # CPU

# PaddleOCR
paddleocr>=2.7.0

# PDF→画像変換
PyMuPDF>=1.23.0

# 画像処理
Pillow>=10.0.0

# 設定ファイル
pyyaml>=6.0

# CLI
# argparse（標準ライブラリ）を使用
```

### requirements-http.txt（HTTP API追加）

```
fastapi>=0.100.0
uvicorn>=0.23.0
python-multipart>=0.0.6
```

### インストール手順

```bash
# 1. 仮想環境作成
python -m venv .venv
source .venv/bin/activate

# 2. PaddlePaddleインストール（GPU/CPU選択）
python -m pip install paddlepaddle==3.0.0 -i https://www.paddlepaddle.org.cn/packages/stable/cpu/

# 3. 依存ライブラリインストール
pip install -r requirements.txt

# 4. HTTP API使用時
pip install -r requirements-http.txt
```

## パッケージ構成

```
doc_layout_analyzer/
├── __init__.py
├── __main__.py               # CLI エントリポイント
├── cli.py                    # CLIコマンド定義
├── core/
│   ├── __init__.py
│   ├── detector.py           # PP-DocLayout呼び出し
│   ├── feature.py            # 特徴量計算（calculate_area_ratio等）
│   ├── scorer.py             # ルール適用・スコアリング
│   └── visualizer.py         # 可視化画像生成
├── io/
│   ├── __init__.py
│   ├── pdf_converter.py      # PDF→画像変換
│   ├── json_writer.py        # results.json出力
│   └── csv_writer.py         # important_pages.csv出力
├── config/
│   ├── __init__.py
│   ├── loader.py             # YAML設定読み込み
│   └── defaults.py           # デフォルト設定値
├── api/                      # HTTP API（オプション）
│   ├── __init__.py
│   └── app.py                # FastAPIアプリ
└── utils/
    ├── __init__.py
    └── logging.py            # ロギング設定
```

### モジュール責務

| モジュール | 責務 |
|-----------|------|
| `core/detector.py` | PP-DocLayoutモデルの初期化・推論 |
| `core/feature.py` | bbox→面積比・横長比率の計算 |
| `core/scorer.py` | ルール適用・スコア計算・ラベル付与 |
| `core/visualizer.py` | 検出枠の描画・画像保存 |
| `io/pdf_converter.py` | PDF→PNG変換（PyMuPDF使用） |
| `io/json_writer.py` | results.json生成 |
| `io/csv_writer.py` | important_pages.csv生成 |

### CLI実行例

```bash
# 基本実行
python -m doc_layout_analyzer --input ./input --output ./output

# 設定ファイル指定
python -m doc_layout_analyzer \
    --input ./input \
    --output ./output \
    --config ./config/pp-doclayout-rules.yaml

# モード指定
python -m doc_layout_analyzer \
    --input ./input \
    --output ./output \
    --mode accuracy
```

## 入出力スキーマ（厳密定義）

### results.json

```yaml
# 必須フィールド
document_id: string           # ドキュメント識別子
pages: array                  # ページ配列
  - page_id: string           # ページ識別子（例: doc_001_p001）
    page_number: integer      # ページ番号（1始まり）
    score: integer            # スコア（0〜10）
    label: string             # "important" | "review" | "unimportant"
    features: object          # 特徴量
      figure_area: float      # 図面積比（0.0〜1.0）
      table_area: float       # 表面積比（0.0〜1.0）
      title_area: float       # タイトル面積比（0.0〜1.0）
      body_area: float        # 本文面積比（0.0〜1.0）
      figure_count: integer   # 図の数
      table_count: integer    # 表の数

# 任意フィールド
  - rules_hit: array          # ヒットしたルール名
    confidence_median: float  # 検出信頼度中央値（0.0〜1.0）
    figure_width_ratio: float # 図の最大横幅比
    table_width_ratio: float  # 表の最大横幅比
```

### important_pages.csv

```csv
# 必須カラム
document_id,page_number,label,score

# 任意カラム（拡張時）
rules_hit
```

### rules_applied.json

```yaml
# 必須フィールド
document_id: string
rules: object
  architecture: array         # ページID配列
  db_schema: array
  schedule: array
  chapter_start: array
```

### エラー出力（共通）

```json
{
  "status": "error",
  "error_code": "INVALID_INPUT",
  "message": "Unsupported file type: .docx"
}
```

| error_code | 説明 |
|------------|------|
| `INVALID_INPUT` | 未対応ファイル形式 |
| `INVALID_CONFIG` | config JSONの形式不正 |
| `PDF_CONVERSION_FAILED` | PDF→画像変換失敗 |
| `MODEL_LOAD_FAILED` | PP-DocLayoutモデル読み込み失敗 |
| `DETECTION_FAILED` | レイアウト検出失敗 |

## 運用の境界（責任分担）

### doc-layout-analyzer の責務（スコープ内）

| 責務 | 出力 |
|------|------|
| PDF→画像変換 | `output/pages/*.png` |
| レイアウト検出 | PP-DocLayout実行 |
| 特徴量計算 | 面積比・横長比率等 |
| ルール適用・分類 | スコア・ラベル付与 |
| 結果出力 | `results.json`, `important_pages.csv` |
| 可視化画像生成 | `output/visuals/*.png` |

### doc-layout-analyzer の責務外（スコープ外）

| 責務 | 担当 |
|------|------|
| `README.md` への反映 | PO（人手） |
| `po_to_sm.yaml` の生成 | 別スクリプト or PO |
| 重要ページの内容解釈 | PO（人手） |
| 閾値の最終決定 | PO + SM（検証後） |
| テストデータの正解ラベル付け | Human |

### 連携の境界図

```
┌────────────────────────────────────────────────────────────┐
│ doc-layout-analyzer（本ツールの責務）                       │
│                                                            │
│  PDF → 画像 → 検出 → 特徴量 → ルール → 分類 → 出力        │
│                                                            │
│  出力物:                                                   │
│    - results.json                                          │
│    - important_pages.csv                                   │
│    - visuals/*.png                                         │
└────────────────────────────────────────────────────────────┘
                            ↓
                    ここで責務が終了
                            ↓
┌────────────────────────────────────────────────────────────┐
│ 後続プロセス（本ツールの責務外）                            │
│                                                            │
│  [PO/Human]                                                │
│    - important_pages.csv を確認                            │
│    - 重要ページの内容を README.md に反映                   │
│    - 必要に応じて po_to_sm.yaml を作成                     │
│                                                            │
│  [別スクリプト（オプション）]                               │
│    - important_pages.csv → po_to_sm.yaml 変換              │
│    - results.json → README.md Backlog 変換                 │
└────────────────────────────────────────────────────────────┘
```

### po_to_sm.yaml 生成の選択肢

| 方式 | 説明 | 推奨場面 |
|------|------|---------|
| **手動** | POが `important_pages.csv` を見て手書き | 少量・初回 |
| **半自動** | 変換スクリプトで下書き生成 → POが編集 | 中量 |
| **自動** | スクリプトで完全生成（POは確認のみ） | 大量・定型 |

## ビジョンモデル
- 使用モデルの詳細は `docs/vision-models/pp-doclayout.md` を参照

## PP-DocLayoutラベルマッピング

PP-DocLayout-Lは23カテゴリを検出する。本システムでは以下のようにマッピングする。

### カテゴリマッピング表

| 本システムカテゴリ | PP-DocLayoutラベル | 備考 |
|------------------|-------------------|------|
| **figure** | `figure`, `image` | 図・画像領域 |
| **table** | `table` | 表領域 |
| **title** | `doc_title`, `paragraph_title`, `figure_title`, `table_caption`, `figure_caption` | 見出し・キャプション |
| **body** | `text`, `abstract` | 本文・抄録 |
| **formula** | `formula`, `formula_number`, `algorithm` | 数式・アルゴリズム（将来拡張用） |
| **reference** | `reference`, `footnote` | 参考文献・脚注（将来拡張用） |
| **ignore** | `page_number`, `header`, `footer`, `seal`, `header_image`, `footer_image`, `sidebar_text`, `table_of_contents` | 判定対象外 |

### PP-DocLayout全23カテゴリ一覧

```
doc_title / paragraph_title / text / page_number / abstract /
table_of_contents / reference / footnote / header / footer /
algorithm / formula / formula_number / image / figure_caption /
table / table_caption / seal / figure_title / figure /
header_image / footer_image / sidebar_text
```

### マッピング設定ファイル例（`config/label_mapping.yaml`）

```yaml
version: "1.0"
mapping:
  figure:
    - figure
    - image
  table:
    - table
  title:
    - doc_title
    - paragraph_title
    - figure_title
    - table_caption
    - figure_caption
  body:
    - text
    - abstract
  formula:
    - formula
    - formula_number
    - algorithm
  reference:
    - reference
    - footnote
  ignore:
    - page_number
    - header
    - footer
    - seal
    - header_image
    - footer_image
    - sidebar_text
    - table_of_contents
```

## PDF→画像変換パラメータ

### 推奨設定

| パラメータ | 推奨値 | 備考 |
|-----------|--------|------|
| **ツール** | `PyMuPDF`（現行実装）/ `pdf2image`（将来拡張） | PyMuPDFの方が高速 |
| **DPI** | 150〜200 | 72は不足、300は過剰 |
| **フォーマット** | PNG | JPEGは圧縮アーティファクトの懸念 |
| **カラーモード** | RGB | グレースケールでも可 |

### DPI選定の指針

| DPI | 用途 | 処理速度 | 検出精度 |
|-----|------|---------|---------|
| 72 | × 非推奨 | 高速 | 低（小さい要素を見逃す） |
| 150 | ◎ 標準 | 中速 | 十分 |
| 200 | ○ 高精度 | やや遅い | 高 |
| 300 | △ 過剰 | 遅い | 過剰（処理負荷に見合わない） |

### 変換コード例

```python
# PyMuPDF使用（現行実装）
import fitz  # PyMuPDF

doc = fitz.open(pdf_path)
for page_num, page in enumerate(doc):
    # DPI 150相当: 150/72 ≈ 2.08
    mat = fitz.Matrix(2.0, 2.0)
    pix = page.get_pixmap(matrix=mat)
    pix.save(f"page_{page_num:03d}.png")
```

### 設定ファイル例（`config/pdf_conversion.yaml`）

```yaml
version: "1.0"
pdf_conversion:
  tool: "pymupdf"  # "pdf2image" | "pymupdf"
  dpi: 150
  format: "png"
  color_mode: "rgb"
  thread_count: 4  # pdf2image用
```

## bbox→面積計算ロジック

### PP-DocLayout出力形式

```python
{
    'cls_id': 8,
    'label': 'table',
    'score': 0.9866,
    'coordinate': [x1, y1, x2, y2]  # 左上(x1,y1), 右下(x2,y2)
}
```

### 面積計算

```python
def calculate_area_ratio(bbox, page_width, page_height):
    """
    bboxからページに対する面積比を計算

    Args:
        bbox: [x1, y1, x2, y2]
        page_width: ページ幅（ピクセル）
        page_height: ページ高さ（ピクセル）

    Returns:
        area_ratio: 0.0〜1.0
    """
    x1, y1, x2, y2 = bbox
    area = (x2 - x1) * (y2 - y1)
    page_area = page_width * page_height
    return area / page_area

def calculate_width_ratio(bbox, page_width):
    """
    bboxの横幅比（横長度）を計算

    Args:
        bbox: [x1, y1, x2, y2]
        page_width: ページ幅（ピクセル）

    Returns:
        width_ratio: 0.0〜1.0
    """
    x1, y1, x2, y2 = bbox
    return (x2 - x1) / page_width

def calculate_position_ratio(bbox, page_height):
    """
    bboxの上端位置（ページ上部からの比率）を計算

    Args:
        bbox: [x1, y1, x2, y2]
        page_height: ページ高さ（ピクセル）

    Returns:
        position_ratio: 0.0〜1.0（0.0=最上部、1.0=最下部）
    """
    x1, y1, x2, y2 = bbox
    return y1 / page_height
```

### 特徴量集計例

```python
def aggregate_features(detections, page_width, page_height, label_mapping):
    """
    検出結果から特徴量を集計

    Returns:
        {
            'figure_area': 0.31,
            'figure_count': 2,
            'figure_width_ratio': 0.72,  # 最大値
            'table_area': 0.15,
            'table_count': 1,
            'table_width_ratio': 0.65,
            'title_area': 0.05,
            'body_area': 0.40,
            'confidence_median': 0.86,
            'block_count': 12
        }
    """
    features = {
        'figure_area': 0.0, 'figure_count': 0, 'figure_width_ratio': 0.0,
        'table_area': 0.0, 'table_count': 0, 'table_width_ratio': 0.0,
        'title_area': 0.0, 'body_area': 0.0,
        'confidence_median': 0.0, 'block_count': 0
    }

    confidences = []

    for det in detections:
        label = det['label']
        bbox = det['coordinate']
        score = det['score']

        category = get_category(label, label_mapping)
        if category == 'ignore':
            continue

        area_ratio = calculate_area_ratio(bbox, page_width, page_height)
        width_ratio = calculate_width_ratio(bbox, page_width)

        if category == 'figure':
            features['figure_area'] += area_ratio
            features['figure_count'] += 1
            features['figure_width_ratio'] = max(features['figure_width_ratio'], width_ratio)
        elif category == 'table':
            features['table_area'] += area_ratio
            features['table_count'] += 1
            features['table_width_ratio'] = max(features['table_width_ratio'], width_ratio)
        elif category == 'title':
            features['title_area'] += area_ratio
        elif category == 'body':
            features['body_area'] += area_ratio

        confidences.append(score)
        features['block_count'] += 1

    if confidences:
        features['confidence_median'] = sorted(confidences)[len(confidences) // 2]

    return features
```

## 処理フロー（概念）
1. PDFをページ画像に分割（外部ツール想定）
2. PP-DocLayoutでページ画像のレイアウト検出
3. ページごとのレイアウト特徴量を算出
4. 重要ページスコアを計算
5. 重要/要確認/非重要に分類
6. レイアウト可視化画像を出力

## 重要ページ判定ロジック（精緻化）
### 特徴量（例）
- 図領域面積比: `figure_area / page_area`
- 表領域面積比: `table_area / page_area`
- 見出し領域面積比/個数
- 本文領域面積比
- 図/表の配置（上部・横長の比率など）
- 図/表の横長比率: `bbox_width / page_width`
- ブロック密度: `block_count / page_area`（近似で良い）
- 検出信頼度（平均/中央値）

### 前処理・正規化
- ページサイズ基準は長辺×短辺の実寸比で正規化する。
- 縦長/横長ページ差は横長比率で吸収する。
- 検出信頼度が極端に低いページは「要確認」へ寄せる。

### ルール案（初期値・精緻化）
- アーキテクチャ候補
  - `figure_area >= 0.22` かつ `figure_count >= 1`
  - 追加条件: `figure_width_ratio >= 0.55` または `figure_area >= 0.30`
- DBスキーマ候補
  - `table_area >= 0.22` または `figure_area >= 0.18`
  - 追加条件: `table_width_ratio >= 0.60` かつ `body_area <= 0.65`
- スケジュール候補
  - `table_area >= 0.28` かつ `table_width_ratio >= 0.70`
  - もしくは `figure_area >= 0.24` かつ `figure_width_ratio >= 0.70`
- 章扉/重要章冒頭候補
  - `title_area >= 0.07` かつ `body_area <= 0.60`
  - 追加条件: タイトルが上部1/3に位置
- 非重要寄りの除外
  - `body_area >= 0.78` かつ `figure_area + table_area < 0.04`
  - `block_count` が極端に少ないページは「要確認」扱い

### スコアリングと分類
- ルールごとに加点（例: アーキテクチャ+3、DBスキーマ+3、スケジュール+2、章扉+2）
- 合計スコアで分類
  - 重要: 4点以上
  - 要確認: 2〜3点
  - 非重要: 0〜1点
- 同点時は図・表面積が大きい方を優先
- 例外: 検出信頼度が低い場合は1段階下げる

### チューニング指針
- 初期は「図/表の面積比」を最優先にし、誤検出が多い場合のみ見出し寄りに調整する。
- 横長比率はスケジュール検出に寄与するため、スケジュールの見逃しが多ければ閾値を0.05下げる。
- データベース系ページが抜ける場合は `table_area` の閾値を0.02下げる。

## 出力仕様
### 1) ページ分類結果
- ページID/ページ番号
- スコア
- 判定ラベル: `important | review | unimportant`
- 主要レイアウト特徴量（面積比、個数）

### 2) レイアウト可視化画像
- 画像上に検出枠をオーバーレイ
- 重要ページは外枠の強調表示

## 可視化画像の体裁（初期案）
- 色分け
  - 図: オレンジ
  - 表: 青
  - 見出し: 緑
  - 本文: グレー
  - その他: 薄紫
- 強調
  - 重要: 太い赤枠または薄い赤の透過背景
  - 要確認: 黄色枠
- 表示情報
  - 右上: ページスコアと判定ラベル
  - 右下: 凡例（色とカテゴリ対応）
- 出力パターン
  - 単ページ強調（重要のみ）
  - サムネ一覧（重要/要確認のみ）
  - 比較ビュー（重要/要確認/非重要の3列）

## 運用形態（概念）
### CLI
- バッチで大量PDFを処理
- 重要ページを抽出して可視化画像を生成

### HTTP
- 1ファイル単位で即時処理
- 可視化画像と分類結果を返却

### 選択可能な実行方式
- 実装は **CLI / HTTP の両方** を選択可能な構成とする。
- 運用側は案件ごとに「CLIのみ / HTTPのみ / 両方」を選択できる。

## CLI入出力フォーマット案
### 入力
- PDF: `input/*.pdf`
- 画像: `input/images/*.png` または `input/images/*.jpg`
- 設定ファイル（任意）: `config/pp-doclayout-rules.yaml`
- 実行モード（任意）: `config/run_mode.yaml`

### 出力
- 分類結果: `output/results.json`
- 可視化画像: `output/visuals/{page_id}.png`
- 重要ページ一覧（任意）: `output/important_pages.csv`
- ルール適用ログ（任意）: `output/rules_applied.json`

### ルール設定ファイル例（`config/pp-doclayout-rules.yaml`）
```yaml
version: "1.0"
thresholds:
  architecture:
    figure_area_min: 0.22
    figure_count_min: 1
    figure_width_ratio_min: 0.55
    figure_area_strict: 0.30
  db_schema:
    table_area_min: 0.22
    figure_area_min: 0.18
    table_width_ratio_min: 0.60
    body_area_max: 0.65
  schedule:
    table_area_min: 0.28
    table_width_ratio_min: 0.70
    figure_area_min: 0.24
    figure_width_ratio_min: 0.70
  chapter_start:
    title_area_min: 0.07
    body_area_max: 0.60
    title_position_top_ratio_max: 0.33
  exclude:
    body_area_min: 0.78
    figure_table_area_max: 0.04
scoring:
  architecture: 3
  db_schema: 3
  schedule: 2
  chapter_start: 2
  important_min: 4
  review_min: 2
confidence:
  low_confidence_median: 0.40
  downgrade_on_low_confidence: true
```

### 実行モード設定例（`config/run_mode.yaml`）
```yaml
version: "1.0"
mode: "accuracy"  # "accuracy" | "speed"
```

### `results.json` 例（概略）
```json
{
  "document_id": "doc_001",
  "pages": [
    {
      "page_id": "doc_001_p001",
      "page_number": 1,
      "score": 5,
      "label": "important",
      "features": {
        "figure_area": 0.31,
        "table_area": 0.02,
        "title_area": 0.03,
        "body_area": 0.42,
        "figure_count": 1,
        "table_count": 0,
        "figure_width_ratio": 0.72,
        "confidence_median": 0.86
      },
      "rules_hit": ["architecture"]
    }
  ]
}
```

### `important_pages.csv` 例（概略）
```csv
document_id,page_number,label,score
doc_001,1,important,5
doc_001,4,important,4
```

### `rules_applied.json` 例（概略）
```json
{
  "document_id": "doc_001",
  "rules": {
    "architecture": ["doc_001_p001"],
    "db_schema": [],
    "schedule": ["doc_001_p004"],
    "chapter_start": []
  }
}
```

## HTTP入出力フォーマット案
### 入力（multipart/form-data）
- `file`: PDFまたは画像
- `config`（任意）: ルール設定JSON（文字列、`pp-doclayout-rules.yaml`相当）
- `mode`（任意）: `"accuracy"` または `"speed"`

### 出力（application/json）
```json
{
  "document_id": "doc_001",
  "status": "ok",
  "mode": "accuracy",
  "pages": [
    {
      "page_number": 1,
      "label": "important",
      "score": 5,
      "visual_url": "https://example.local/visuals/doc_001_p001.png",
      "visual_base64": "iVBORw0KGgoAAAANSUhEUgAA..."
    }
  ]
}
```

### エラー例
```json
{
  "status": "error",
  "message": "unsupported file type"
}
```

### visual_url 出力条件
- `DOC_LAYOUT_VISUAL_BASE_URL` と `DOC_LAYOUT_VISUAL_DIR` を設定した場合のみ `visual_url` を返す
- 未設定時は `visual_url` は `null` となる

### モード別の設定切替（例）
- accuracy
  - `pdf_conversion.yaml`: `dpi=200`
  - `pp-doclayout-rules.yaml`: 閾値を厳しめに設定
  - 低信頼ページは必ず `review` へ
- speed
  - `pdf_conversion.yaml`: `dpi=150`
  - `pp-doclayout-rules.yaml`: 閾値は標準
  - 低信頼ページの再判定は最小限

## 運用手順（重要/要確認/非重要の導線）
1. `results.json` の `label` を基準に「重要/要確認/非重要」を分類する。
2. 重要ページは可視化画像をレビュー対象に固定し、必要なら注釈を追加する。
3. 要確認ページは人手レビュー後に「重要/非重要」に再分類し、しきい値調整にフィードバックする。
4. 非重要ページは保管のみ行い、再検出対象からは除外する。
5. 重要ページは `important_pages.csv` に集約し、後続のドキュメント整理タスクへ渡す。

## 受入基準（案）
- 重要ページの抽出結果にアーキテクチャ/DBスキーマ/スケジュールが含まれる
- 重要ページの可視化画像が判定ラベルと一致する見た目である
- ページ単位で分類結果が取得できる

## 能力獲得の条件（最小セット）
エージェントが「重要ページをピックアップできる」と言えるための最低条件は以下。

### 1) 最小パイプラインの実装
- PDF→画像変換 → レイアウト検出 → 特徴量集計 → ルール適用 → 分類結果/可視化出力
- `results.json` と可視化画像が一貫したページ単位で生成されること

### 2) ラベル整合性の確認
- 実出力ラベルとマッピング表が一致していること（不一致は `ignore`/誤分類の原因）
- 代表サンプルで `label_mapping.yaml` の妥当性を確認する

### 3) 検証と運用の成立
- テストデータで Precision/Recall の基準を満たすこと
- 低信頼ページを「要確認」に寄せる運用ができること
- 閾値調整のフィードバックループが回せること

## ixv-agents連携方針

### 連携パターン

| パターン | 説明 | 適用場面 |
|---------|------|---------|
| **A. 前処理パイプライン** | `boot.sh`実行前にPDF解析を完了させる | レガシードキュメント移行 |
| **B. スキル統合** | `skills/doc-layout-analyzer/` として統合 | 開発フロー中のドキュメント解析 |
| **C. 外部サービス** | HTTP APIとして独立稼働 | 複数プロジェクトで共用 |

### 推奨: パターンA + B の併用

#### A. 前処理パイプライン（レガシー移行用）

```
legacy_docs/*.pdf
    ↓ scripts/analyze_docs.sh
structured_data/
├── results.json
├── important_pages.csv
└── visuals/*.png
    ↓ scripts/setup_workspace.sh
workspace/
├── README.md  ← important_pages.csvから自動生成
└── queue/
    └── po_to_sm.yaml  ← 移行タスクとして生成
```

**起動スクリプト例（`scripts/analyze_docs.sh`）:**

```bash
#!/bin/bash
INPUT_DIR="${1:-./input}"
OUTPUT_DIR="${2:-./structured_data}"

python -m doc_layout_analyzer \
    --input "$INPUT_DIR" \
    --output "$OUTPUT_DIR" \
    --config config/pp-doclayout-rules.yaml
```

#### B. スキル統合（開発フロー用）

**スキルディレクトリ構成:**

```
skills/
└── doc-layout-analyzer/
    ├── SKILL.md          # スキル定義
    ├── config/
    │   ├── label_mapping.yaml
    │   ├── pp-doclayout-rules.yaml
    │   └── pdf_conversion.yaml
    └── examples/
        └── sample_output.json
```

**SKILL.md 概要:**

```markdown
# doc-layout-analyzer

## 概要
PDF/画像ドキュメントからレイアウト解析を行い、重要ページを抽出する。

## 呼び出し方
/doc-layout-analyzer <pdf_path> [--output <output_dir>]

## 入力
- PDF または 画像ファイル

## 出力
- results.json: ページ分類結果
- important_pages.csv: 重要ページ一覧
- visuals/: 可視化画像

## POとの連携
抽出した重要ページ情報は以下の形式でPOに渡す:
- アーキテクチャページ → README.md の Requirements に反映候補として提示
- DBスキーマページ → README.md の Constraints に反映候補として提示
```

### ixv-agents形式への変換

#### important_pages.csv → po_to_sm.yaml 変換

```python
import csv
import yaml
from datetime import datetime

def convert_to_po_request(csv_path, output_path):
    """
    important_pages.csv を po_to_sm.yaml に変換
    """
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        pages = list(reader)

    # 重要ページをサマリ化
    important_pages = [p for p in pages if p['label'] == 'important']

    request = {
        'schema_version': '1.0',
        'created_at': datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ'),
        'spec_ref': 'README.md',
        'request_id': f"REQ-{datetime.now().strftime('%Y%m%d')}-001",
        'priority': 'P1',
        'summary': f"レガシードキュメントから{len(important_pages)}件の重要ページを移行",
        'acceptance_criteria': [
            f"ページ{p['page_number']}の内容がREADME.mdに反映されている"
            for p in important_pages[:5]  # 上位5件
        ],
        'constraints': [
            "既存の仕様との整合性を確認すること"
        ],
        'notes': f"対象ドキュメント: {important_pages[0]['document_id'] if important_pages else 'N/A'}"
    }

    with open(output_path, 'w') as f:
        yaml.dump(request, f, allow_unicode=True, default_flow_style=False)

    return request
```

#### results.json → README.md Backlog 変換

```python
def generate_backlog_entries(results_json_path):
    """
    results.json から README.md の Backlog エントリを生成
    """
    with open(results_json_path, 'r') as f:
        results = json.load(f)

    backlog_entries = []
    for page in results['pages']:
        if page['label'] != 'important':
            continue

        # ルールヒットから種別を判定
        rules = page.get('rules_hit', [])
        if 'architecture' in rules:
            summary = f"アーキテクチャ図（ページ{page['page_number']}）の仕様反映"
        elif 'db_schema' in rules:
            summary = f"DBスキーマ（ページ{page['page_number']}）の仕様反映"
        elif 'schedule' in rules:
            summary = f"スケジュール（ページ{page['page_number']}）の仕様反映"
        else:
            summary = f"重要ページ（ページ{page['page_number']}）の仕様反映"

        backlog_entries.append({
            'id': f"REQ-{datetime.now().strftime('%Y%m%d')}-{page['page_number']:03d}",
            'priority': 'P1',
            'summary': summary,
            'status': 'ready'
        })

    return backlog_entries
```

### ワークフロー統合図

```
┌─────────────────────────────────────────────────────────────────────┐
│ レガシードキュメント移行フロー                                        │
└─────────────────────────────────────────────────────────────────────┘

[Human] レガシーPDFを提供
    ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 前処理: doc-layout-analyzer                                         │
│                                                                     │
│   legacy.pdf → PP-DocLayout → results.json → important_pages.csv   │
│                                                   ↓                 │
│                                           po_to_sm.yaml (自動生成) │
└─────────────────────────────────────────────────────────────────────┘
    ↓
[PO] 自動生成された po_to_sm.yaml を確認・調整
    ↓
[PO] README.md に重要ページの内容を反映
    ↓
[Human] ★ 仕様承認
    ↓
（通常の ixv-agents フロー）
```

### 設定ファイル例（`config/ixv-integration.yaml`）

```yaml
version: "1.0"
integration:
  mode: "preprocessing"  # "preprocessing" | "skill" | "service"

  preprocessing:
    input_dir: "./legacy_docs"
    output_dir: "./structured_data"
    auto_generate_yaml: true

  skill:
    skill_name: "doc-layout-analyzer"
    trigger: "manual"  # "manual" | "on_pdf_upload"

  output_mapping:
    architecture_pages: "README.md#Requirements"
    db_schema_pages: "README.md#Constraints"
    schedule_pages: "docs/schedule.md"

  po_request:
    default_priority: "P1"
    max_acceptance_criteria: 5
```

## 検証方法

### テストデータセット

| カテゴリ | ドキュメント例 | 期待される判定 | 検証ポイント |
|---------|--------------|---------------|-------------|
| **アーキテクチャ** | システム構成図を含むPDF | important | figure_area >= 0.22 |
| **DBスキーマ** | ER図/テーブル定義を含むPDF | important | table_area >= 0.22 |
| **スケジュール** | ガントチャート/WBSを含むPDF | important | table_width_ratio >= 0.70 |
| **章扉** | 大きなタイトルのみのページ | important/review | title_area >= 0.07 |
| **本文のみ** | テキスト主体のページ | unimportant | body_area >= 0.78 |
| **混在** | 図と表が混在するページ | important | 複数ルールヒット |

### テストPDF構成案

```
test_data/
├── architecture/
│   ├── system_overview.pdf      # システム構成図
│   ├── sequence_diagram.pdf     # シーケンス図
│   └── class_diagram.pdf        # クラス図
├── database/
│   ├── er_diagram.pdf           # ER図
│   └── table_definition.pdf     # テーブル定義書
├── schedule/
│   ├── gantt_chart.pdf          # ガントチャート
│   └── wbs.pdf                  # WBS
├── mixed/
│   └── technical_spec.pdf       # 複合ドキュメント
└── text_only/
    └── requirements_text.pdf    # 本文のみ
```

### 成功基準

| 指標 | 基準値 | 測定方法 |
|------|--------|---------|
| **Precision（適合率）** | >= 0.80 | important判定のうち、実際に重要なページの割合 |
| **Recall（再現率）** | >= 0.90 | 実際に重要なページのうち、important判定された割合 |
| **処理速度** | <= 2秒/ページ | 150 DPI、CPU環境での平均処理時間 |
| **可視化品質** | 目視確認 | 検出枠が実際の領域と一致しているか |

### 検証スクリプト例

```python
def evaluate_accuracy(results_json_path, ground_truth_path):
    """
    判定精度を評価

    ground_truth.json:
    {
        "pages": [
            {"page_number": 1, "actual_label": "important"},
            {"page_number": 2, "actual_label": "unimportant"},
            ...
        ]
    }
    """
    with open(results_json_path, 'r') as f:
        results = json.load(f)
    with open(ground_truth_path, 'r') as f:
        ground_truth = json.load(f)

    # ページ番号でマッチング
    gt_map = {p['page_number']: p['actual_label'] for p in ground_truth['pages']}

    tp = fp = fn = tn = 0
    for page in results['pages']:
        predicted = page['label']
        actual = gt_map.get(page['page_number'], 'unknown')

        if predicted == 'important' and actual == 'important':
            tp += 1
        elif predicted == 'important' and actual != 'important':
            fp += 1
        elif predicted != 'important' and actual == 'important':
            fn += 1
        else:
            tn += 1

    precision = tp / (tp + fp) if (tp + fp) > 0 else 0
    recall = tp / (tp + fn) if (tp + fn) > 0 else 0
    f1 = 2 * precision * recall / (precision + recall) if (precision + recall) > 0 else 0

    return {
        'precision': precision,
        'recall': recall,
        'f1_score': f1,
        'confusion_matrix': {'tp': tp, 'fp': fp, 'fn': fn, 'tn': tn}
    }
```

### チューニングフィードバックループ

```
1. テストデータで評価実行
    ↓
2. Precision/Recall を確認
    ↓
3. 問題パターンを特定
   - FP多い（誤検出）→ 閾値を上げる
   - FN多い（見逃し）→ 閾値を下げる
    ↓
4. pp-doclayout-rules.yaml を調整
    ↓
5. 再評価
    ↓
（基準値達成まで繰り返し）
```

## 今後の拡張候補
- スコアリングしきい値のチューニング
- 人手レビューのフィードバックを反映するルール更新
- OCR連携による見出し/章タイトルの精度向上

## 運用優先度の選択
### 優先モード
- **精度優先**: DPI 200、閾値は厳しめ、低信頼ページは要確認に寄せる
- **速度優先**: DPI 150、閾値は標準、低信頼ページの再確認は最小限

### モードの適用先
- CLI: `config/pdf_conversion.yaml` のDPIと、`pp-doclayout-rules.yaml` の閾値で切替
- HTTP: リクエストパラメータ `mode=accuracy|speed` により切替

## 役割分担（スキル化の責任範囲）
- PO: 目的・受入基準の定義、レビュー運用方針の決定、SMへのスキル化依頼
- SM: タスク分解とDevへの割り当て、検証計画の調整、進捗集約
- Dev: スキル作成（SKILL.md、参照・設定ファイルの作成）、評価用データ/実行結果の整理
