from __future__ import annotations

from typing import Any, Dict, List, Tuple


def _hit_architecture(features: Dict[str, Any], thresholds: Dict[str, Any]) -> bool:
    return (
        features["figure_area"] >= thresholds["figure_area_min"]
        and features["figure_count"] >= thresholds["figure_count_min"]
        and (
            features["figure_width_ratio"] >= thresholds["figure_width_ratio_min"]
            or features["figure_area"] >= thresholds["figure_area_strict"]
        )
    )


def _hit_db_schema(features: Dict[str, Any], thresholds: Dict[str, Any]) -> bool:
    return (
        features["table_area"] >= thresholds["table_area_min"]
        or features["figure_area"] >= thresholds["figure_area_min"]
    ) and (
        features["table_width_ratio"] >= thresholds["table_width_ratio_min"]
        and features["body_area"] <= thresholds["body_area_max"]
    )


def _hit_schedule(features: Dict[str, Any], thresholds: Dict[str, Any]) -> bool:
    return (
        features["table_area"] >= thresholds["table_area_min"]
        and features["table_width_ratio"] >= thresholds["table_width_ratio_min"]
    ) or (
        features["figure_area"] >= thresholds["figure_area_min"]
        and features["figure_width_ratio"] >= thresholds["figure_width_ratio_min"]
    )


def _hit_chapter_start(features: Dict[str, Any], thresholds: Dict[str, Any]) -> bool:
    return (
        features["title_area"] >= thresholds["title_area_min"]
        and features["body_area"] <= thresholds["body_area_max"]
        and features["title_position_top_ratio"] <= thresholds["title_position_top_ratio_max"]
    )


def _is_excluded(features: Dict[str, Any], thresholds: Dict[str, Any]) -> bool:
    return (
        features["body_area"] >= thresholds["body_area_min"]
        and (features["figure_area"] + features["table_area"])
        < thresholds["figure_table_area_max"]
    )


def score_page(
    features: Dict[str, Any],
    rules: Dict[str, Any],
) -> Tuple[int, str, List[str]]:
    thresholds = rules.get("thresholds", {})
    scoring = rules.get("scoring", {})
    confidence = rules.get("confidence", {})

    rules_hit: List[str] = []
    score = 0

    if _hit_architecture(features, thresholds["architecture"]):
        rules_hit.append("architecture")
        score += scoring.get("architecture", 0)

    if _hit_db_schema(features, thresholds["db_schema"]):
        rules_hit.append("db_schema")
        score += scoring.get("db_schema", 0)

    if _hit_schedule(features, thresholds["schedule"]):
        rules_hit.append("schedule")
        score += scoring.get("schedule", 0)

    if _hit_chapter_start(features, thresholds["chapter_start"]):
        rules_hit.append("chapter_start")
        score += scoring.get("chapter_start", 0)

    if _is_excluded(features, thresholds["exclude"]):
        score = 0
        rules_hit = []

    label = "unimportant"
    if score >= scoring.get("important_min", 4):
        label = "important"
    elif score >= scoring.get("review_min", 2):
        label = "review"

    if confidence.get("downgrade_on_low_confidence", False):
        low_conf = confidence.get("low_confidence_median", 0.0)
        if features.get("confidence_median", 1.0) < low_conf:
            if label == "important":
                label = "review"
            elif label == "review":
                label = "unimportant"

    return score, label, rules_hit
