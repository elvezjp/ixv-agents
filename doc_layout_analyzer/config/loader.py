from __future__ import annotations

from pathlib import Path
from typing import Any, Dict

try:
    import yaml
except ImportError:  # pragma: no cover
    yaml = None

from .defaults import (
    DEFAULT_LABEL_MAPPING,
    DEFAULT_PDF_CONVERSION,
    DEFAULT_RULES,
    DEFAULT_RUN_MODE,
    DEFAULT_VISUALS,
)


def _load_yaml(path: Path) -> Dict[str, Any]:
    if yaml is None:
        raise RuntimeError("pyyaml is required to load YAML config files.")
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}


def load_rules(path: str | None) -> Dict[str, Any]:
    if not path:
        return DEFAULT_RULES.copy()
    return _load_yaml(Path(path))


def load_label_mapping(path: str | None) -> Dict[str, Any]:
    if not path:
        return DEFAULT_LABEL_MAPPING.copy()
    return _load_yaml(Path(path))


def load_pdf_conversion(path: str | None) -> Dict[str, Any]:
    if not path:
        return DEFAULT_PDF_CONVERSION.copy()
    return _load_yaml(Path(path))


def load_run_mode(path: str | None) -> Dict[str, Any]:
    if not path:
        return DEFAULT_RUN_MODE.copy()
    return _load_yaml(Path(path))


def load_visuals(path: str | None) -> Dict[str, Any]:
    if not path:
        return DEFAULT_VISUALS.copy()
    return _load_yaml(Path(path))
