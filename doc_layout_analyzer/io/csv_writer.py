from __future__ import annotations

import csv
from pathlib import Path
from typing import Iterable, Dict, Any


def write_important_pages(path: Path, rows: Iterable[Dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    rows = list(rows)
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["document_id", "page_number", "label", "score"])
        writer.writeheader()
        for row in rows:
            writer.writerow(
                {
                    "document_id": row.get("document_id"),
                    "page_number": row.get("page_number"),
                    "label": row.get("label"),
                    "score": row.get("score"),
                }
            )
