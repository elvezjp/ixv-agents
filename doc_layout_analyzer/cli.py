from __future__ import annotations

import argparse
from pathlib import Path
from typing import Any, Dict, List, Tuple

from PIL import Image

from .config.loader import (
    load_label_mapping,
    load_pdf_conversion,
    load_rules,
    load_run_mode,
    load_visuals,
)
from .core.detector import LayoutDetector
from .core.feature import aggregate_features
from .core.scorer import score_page
from .core.visualizer import draw_visualization
from .io.csv_writer import write_important_pages
from .io.json_writer import write_results, write_rules_applied
from .io.pdf_converter import convert_pdf_to_images
from .utils.logging import setup_logger


def _collect_inputs(input_dir: Path) -> Tuple[List[Path], List[Path]]:
    pdfs = sorted(input_dir.glob("*.pdf"))
    images_dir = input_dir / "images"
    images = []
    if images_dir.exists():
        images.extend(sorted(images_dir.glob("*.png")))
        images.extend(sorted(images_dir.glob("*.jpg")))
        images.extend(sorted(images_dir.glob("*.jpeg")))
    return pdfs, images


def _apply_mode(rules: Dict[str, Any], pdf_conf: Dict[str, Any], mode: str) -> None:
    if mode == "accuracy":
        pdf_conf.setdefault("pdf_conversion", {})["dpi"] = 200
        rules.setdefault("confidence", {})["downgrade_on_low_confidence"] = True
    elif mode == "speed":
        pdf_conf.setdefault("pdf_conversion", {})["dpi"] = 150


def main() -> None:
    parser = argparse.ArgumentParser(description="Document layout analyzer")
    parser.add_argument("--input", required=True, help="Input directory")
    parser.add_argument("--output", required=True, help="Output directory")
    parser.add_argument("--config", help="Rules config YAML")
    parser.add_argument("--label-mapping", help="Label mapping YAML")
    parser.add_argument("--pdf-config", help="PDF conversion YAML")
    parser.add_argument("--visuals", help="Visualization YAML")
    parser.add_argument("--run-mode", help="Run mode YAML")
    parser.add_argument("--mode", choices=["accuracy", "speed"], default=None)
    parser.add_argument("--rules-log", action="store_true")
    args = parser.parse_args()

    logger = setup_logger()

    input_dir = Path(args.input)
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    rules = load_rules(args.config)
    label_mapping = load_label_mapping(args.label_mapping)
    pdf_conf = load_pdf_conversion(args.pdf_config)
    visuals = load_visuals(args.visuals)

    if args.mode:
        _apply_mode(rules, pdf_conf, args.mode)
    else:
        run_mode_path = Path(args.run_mode) if args.run_mode else Path("config/run_mode.yaml")
        run_mode = load_run_mode(str(run_mode_path)) if run_mode_path.exists() else load_run_mode(None)
        _apply_mode(rules, pdf_conf, run_mode.get("mode", "accuracy"))

    detector = LayoutDetector()

    pdfs, images = _collect_inputs(input_dir)
    total_inputs = len(pdfs) + len(images)
    document_id = input_dir.name if total_inputs <= 1 else "batch"
    results = {"document_id": document_id, "pages": []}
    rules_applied: Dict[str, List[str]] = {
        "architecture": [],
        "db_schema": [],
        "schedule": [],
        "chapter_start": [],
    }

    dpi = pdf_conf.get("pdf_conversion", {}).get("dpi", 150)
    pages_dir = output_dir / "pages"
    pages_dir.mkdir(parents=True, exist_ok=True)
    visuals_dir = output_dir / "visuals"
    visuals_dir.mkdir(parents=True, exist_ok=True)

    def handle_page(page_number: int, image: Image.Image, doc_id: str) -> None:
        detections = detector.detect(image)
        features = aggregate_features(detections, image.width, image.height, label_mapping)
        score, label, rules_hit = score_page(features, rules)

        page_id = f"{doc_id}_p{page_number:03d}"
        results["pages"].append(
            {
                "document_id": doc_id,
                "page_id": page_id,
                "page_number": page_number,
                "score": score,
                "label": label,
                "features": features,
                "rules_hit": rules_hit,
            }
        )

        for rule in rules_hit:
            if rule in rules_applied:
                rules_applied[rule].append(page_id)

        image.save(pages_dir / f"{page_id}.png")
        visual = draw_visualization(image.copy(), detections, label_mapping, visuals, label)
        visual.save(visuals_dir / f"{page_id}.png")

    for pdf_path in pdfs:
        doc_id = pdf_path.stem
        logger.info("Processing PDF: %s", pdf_path.name)
        for page_number, image in convert_pdf_to_images(pdf_path, dpi=dpi):
            handle_page(page_number, image, doc_id)

    for image_path in images:
        doc_id = image_path.stem
        logger.info("Processing image: %s", image_path.name)
        image = Image.open(image_path).convert("RGB")
        handle_page(1, image, doc_id)

    write_results(output_dir / "results.json", results)

    important_rows = [
        {
            "document_id": p.get("document_id", results["document_id"]),
            "page_number": p["page_number"],
            "label": p["label"],
            "score": p["score"],
        }
        for p in results["pages"]
        if p["label"] == "important"
    ]
    write_important_pages(output_dir / "important_pages.csv", important_rows)

    if args.rules_log:
        write_rules_applied(output_dir / "rules_applied.json", {"document_id": results["document_id"], "rules": rules_applied})

    logger.info("Done. Results saved to %s", output_dir)


if __name__ == "__main__":
    main()
