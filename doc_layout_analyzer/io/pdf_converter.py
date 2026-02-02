from __future__ import annotations

from pathlib import Path
from typing import List, Tuple

try:
    import fitz  # PyMuPDF
except Exception as exc:  # pragma: no cover
    fitz = None

try:
    from PIL import Image
except Exception as exc:  # pragma: no cover
    raise RuntimeError("Pillow is required for PDF conversion.") from exc


def convert_pdf_to_images(pdf_path: Path, dpi: int = 150) -> List[Tuple[int, Image.Image]]:
    if fitz is None:
        raise RuntimeError("PyMuPDF is required for PDF conversion.")

    doc = fitz.open(pdf_path)
    images: List[Tuple[int, Image.Image]] = []
    scale = dpi / 72.0
    mat = fitz.Matrix(scale, scale)

    try:
        for page_num, page in enumerate(doc, start=1):
            pix = page.get_pixmap(matrix=mat, alpha=False)
            mode = "RGB" if pix.n < 5 else "CMYK"
            img = Image.frombytes(mode, [pix.width, pix.height], pix.samples)
            images.append((page_num, img))
    finally:
        doc.close()

    return images
