"""Heartbeat reader for Sentinel."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass
class HeartbeatState:
    agent: str
    status: str
    updated_at: str
    schema_version: str = "1.0"
    task_id: str | None = None
    progress: float | None = None
    message: str | None = None


class HeartbeatReader:
    def __init__(self, heartbeat_dir: Path) -> None:
        self.heartbeat_dir = heartbeat_dir

    def read(self, agent: str) -> HeartbeatState | None:
        path = self.heartbeat_dir / f"{agent}.yaml"
        if not path.exists():
            return None
        data = _load_yaml(path)
        return HeartbeatState(
            agent=data.get("agent", agent),
            status=str(data.get("status", "unknown")),
            updated_at=str(data.get("updated_at", "")),
            schema_version=str(data.get("schema_version", "1.0")),
            task_id=data.get("task_id"),
            progress=data.get("progress"),
            message=data.get("message"),
        )


def _load_yaml(path: Path) -> dict[str, Any]:
    try:
        import yaml  # type: ignore
    except Exception as exc:  # pragma: no cover
        raise RuntimeError("PyYAML is required to read heartbeat files") from exc
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}
