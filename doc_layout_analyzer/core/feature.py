from __future__ import annotations

from typing import Any, Dict, List


def calculate_area_ratio(bbox, page_width: int, page_height: int) -> float:
    x1, y1, x2, y2 = bbox
    area = max(0, x2 - x1) * max(0, y2 - y1)
    page_area = max(1, page_width * page_height)
    return area / page_area


def calculate_width_ratio(bbox, page_width: int) -> float:
    x1, _, x2, _ = bbox
    width = max(0, x2 - x1)
    return width / max(1, page_width)


def calculate_position_ratio(bbox, page_height: int) -> float:
    _, y1, _, _ = bbox
    return y1 / max(1, page_height)


def get_category(label: str, label_mapping: Dict[str, Any]) -> str:
    mapping = label_mapping.get("mapping", {})
    for category, labels in mapping.items():
        if label in labels:
            return category
    return "other"


def aggregate_features(
    detections: List[Dict[str, Any]],
    page_width: int,
    page_height: int,
    label_mapping: Dict[str, Any],
) -> Dict[str, Any]:
    features = {
        "figure_area": 0.0,
        "figure_count": 0,
        "figure_width_ratio": 0.0,
        "table_area": 0.0,
        "table_count": 0,
        "table_width_ratio": 0.0,
        "title_area": 0.0,
        "body_area": 0.0,
        "confidence_median": 0.0,
        "block_count": 0,
        "title_position_top_ratio": 1.0,
    }

    confidences: List[float] = []

    for det in detections:
        label = det.get("label", "")
        bbox = det.get("coordinate", [])
        score = float(det.get("score", 0.0))
        if not bbox:
            continue

        category = get_category(label, label_mapping)
        if category == "ignore":
            continue

        area_ratio = calculate_area_ratio(bbox, page_width, page_height)
        width_ratio = calculate_width_ratio(bbox, page_width)
        position_ratio = calculate_position_ratio(bbox, page_height)

        if category == "figure":
            features["figure_area"] += area_ratio
            features["figure_count"] += 1
            features["figure_width_ratio"] = max(
                features["figure_width_ratio"], width_ratio
            )
        elif category == "table":
            features["table_area"] += area_ratio
            features["table_count"] += 1
            features["table_width_ratio"] = max(
                features["table_width_ratio"], width_ratio
            )
        elif category == "title":
            features["title_area"] += area_ratio
            features["title_position_top_ratio"] = min(
                features["title_position_top_ratio"], position_ratio
            )
        elif category == "body":
            features["body_area"] += area_ratio

        confidences.append(score)
        features["block_count"] += 1

    if confidences:
        confidences.sort()
        features["confidence_median"] = confidences[len(confidences) // 2]

    return features
