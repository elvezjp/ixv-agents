from __future__ import annotations

from typing import Any, Dict, List, TYPE_CHECKING

import numpy as np

if TYPE_CHECKING:
    from PIL import Image


class LayoutDetector:
    """Wrapper for PP-DocLayout detection.

    This is a thin adapter; it raises a clear error if PaddleOCR isn't available.
    """

    def __init__(self) -> None:
        try:
            from paddleocr import PPStructure  # type: ignore
        except Exception as exc:  # pragma: no cover
            raise RuntimeError(
                "PaddleOCR is required for detection. Install paddleocr and paddlepaddle."
            ) from exc

        # PPStructure with layout=True runs layout detection
        self._engine = PPStructure(layout=True, ocr=False, show_log=False)

    def detect(self, image: "Image.Image") -> List[Dict[str, Any]]:
        """Run layout detection on a PIL image.

        Args:
            image: PIL Image (RGB)

        Returns:
            List of dicts: {label, score, coordinate}
        """
        # PPStructure expects numpy array (BGR format)
        img_array = np.array(image)
        if img_array.ndim == 3 and img_array.shape[2] == 3:
            # Convert RGB to BGR for PaddleOCR
            img_array = img_array[:, :, ::-1]

        result = self._engine(img_array)
        detections: List[Dict[str, Any]] = []

        # PPStructure returns list of dicts with 'type', 'bbox', 'score'
        for item in result:
            label = item.get("type") or item.get("label")
            bbox = item.get("bbox") or item.get("coordinate")
            score = item.get("score", 1.0)
            if not label or not bbox:
                continue
            detections.append(
                {
                    "label": str(label),
                    "score": float(score),
                    "coordinate": [int(v) for v in bbox],
                }
            )
        return detections
