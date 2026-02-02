from __future__ import annotations

import base64
import io
import json
import os
import tempfile
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

try:
    from fastapi import FastAPI, File, UploadFile, Form, HTTPException
    from fastapi.responses import JSONResponse
except Exception as exc:  # pragma: no cover
    raise RuntimeError("fastapi is required for HTTP API.") from exc

from PIL import Image

from ..config.loader import load_label_mapping, load_pdf_conversion, load_rules, load_visuals
from ..core.detector import LayoutDetector
from ..core.feature import aggregate_features
from ..core.scorer import score_page
from ..core.visualizer import draw_visualization
from ..io.pdf_converter import convert_pdf_to_images

app = FastAPI(title="doc-layout-analyzer")

# Singleton detector to avoid reloading the model on each request
_detector: LayoutDetector | None = None


def _get_detector() -> LayoutDetector:
    global _detector
    if _detector is None:
        _detector = LayoutDetector()
    return _detector


def _analyze_images(
    images: List[Tuple[int, Image.Image]],
    document_id: str,
    rules: Dict[str, Any],
    label_mapping: Dict[str, Any],
    visuals: Dict[str, Any],
    visual_base_url: Optional[str],
    visual_dir: Optional[Path],
) -> List[Dict[str, Any]]:
    detector = _get_detector()
    pages = []

    for page_number, image in images:
        detections = detector.detect(image)
        features = aggregate_features(detections, image.width, image.height, label_mapping)
        score, label, rules_hit = score_page(features, rules)

        visual = draw_visualization(image.copy(), detections, label_mapping, visuals, label)
        buf = io.BytesIO()
        visual.save(buf, format="PNG")
        visual_b64 = base64.b64encode(buf.getvalue()).decode("utf-8")

        visual_url = None
        if visual_base_url and visual_dir:
            visual_dir.mkdir(parents=True, exist_ok=True)
            filename = f"{document_id}_p{page_number:03d}.png"
            visual.save(visual_dir / filename)
            visual_url = f"{visual_base_url.rstrip('/')}/{filename}"

        pages.append(
            {
                "page_number": page_number,
                "label": label,
                "score": score,
                "rules_hit": rules_hit,
                "visual_url": visual_url,
                "visual_base64": visual_b64,
            }
        )

    return pages


@app.post("/analyze")
async def analyze(
    file: UploadFile = File(...),
    mode: str = Form("accuracy"),
    config: Optional[str] = Form(None),
):
    data = await file.read()
    filename = file.filename or "document"
    name = Path(filename).stem

    # Validate file type
    lower_name = filename.lower()
    if not (lower_name.endswith(".pdf") or lower_name.endswith((".png", ".jpg", ".jpeg"))):
        return JSONResponse(
            status_code=400,
            content={"status": "error", "error_code": "INVALID_INPUT", "message": f"Unsupported file type: {filename}"},
        )

    rules = load_rules(None)
    label_mapping = load_label_mapping(None)
    visuals = load_visuals(None)
    pdf_conf = load_pdf_conversion(None)

    if config:
        try:
            config_obj = json.loads(config)
            if isinstance(config_obj, dict):
                rules.update(config_obj)
        except json.JSONDecodeError:
            return JSONResponse(
                status_code=400,
                content={
                    "status": "error",
                    "error_code": "INVALID_CONFIG",
                    "message": "config must be a valid JSON string",
                },
            )

    images: List[Tuple[int, Image.Image]] = []

    try:
        if lower_name.endswith(".pdf"):
            # Use tempfile for automatic cleanup
            with tempfile.NamedTemporaryFile(suffix=".pdf", delete=True) as tmp:
                tmp.write(data)
                tmp.flush()
                if mode == "accuracy":
                    pdf_conf.setdefault("pdf_conversion", {})["dpi"] = 200
                elif mode == "speed":
                    pdf_conf.setdefault("pdf_conversion", {})["dpi"] = 150
                dpi = pdf_conf.get("pdf_conversion", {}).get("dpi", 150)
                images = convert_pdf_to_images(Path(tmp.name), dpi=dpi)
        else:
            image = Image.open(io.BytesIO(data)).convert("RGB")
            images = [(1, image)]

        visual_base_url = os.getenv("DOC_LAYOUT_VISUAL_BASE_URL")
        visual_dir_env = os.getenv("DOC_LAYOUT_VISUAL_DIR")
        visual_dir = Path(visual_dir_env) if visual_dir_env else None

        pages = _analyze_images(
            images, name, rules, label_mapping, visuals, visual_base_url, visual_dir
        )

        return {"document_id": name, "status": "ok", "mode": mode, "pages": pages}

    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"status": "error", "error_code": "DETECTION_FAILED", "message": str(e)},
        )
