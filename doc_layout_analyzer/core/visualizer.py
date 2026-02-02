from __future__ import annotations

from typing import Any, Dict, List

try:
    from PIL import Image, ImageDraw, ImageFont
except Exception as exc:  # pragma: no cover
    raise RuntimeError("Pillow is required for visualization.") from exc

from .feature import get_category


def draw_visualization(
    image: Image.Image,
    detections: List[Dict[str, Any]],
    label_mapping: Dict[str, Any],
    visuals: Dict[str, Any],
    label: str,
) -> Image.Image:
    colors = visuals.get("colors", {})
    highlight = visuals.get("highlight", {})
    line_width = visuals.get("line_width", 2)

    draw = ImageDraw.Draw(image)
    font = None
    try:
        font = ImageFont.load_default()
    except Exception:
        font = None

    for det in detections:
        bbox = det.get("coordinate", [])
        if not bbox:
            continue
        category = get_category(det.get("label", ""), label_mapping)
        color = colors.get(category, colors.get("other", "#B39DDB"))
        x1, y1, x2, y2 = bbox
        draw.rectangle([x1, y1, x2, y2], outline=color, width=line_width)
        if font:
            draw.text((x1 + 2, y1 + 2), category, fill=color, font=font)

    if label in highlight:
        draw.rectangle(
            [0, 0, image.size[0] - 1, image.size[1] - 1],
            outline=highlight[label],
            width=max(2, line_width + 1),
        )

    return image
