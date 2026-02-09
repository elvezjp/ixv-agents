"""Sentinel entrypoint."""

from __future__ import annotations

from datetime import datetime, timezone, timedelta
from pathlib import Path

from .brain import Brain
from .config import load_config
from .heartbeat import HeartbeatReader
from .machine import MachineMonitor
from .queue_watcher import QueueWatcher


_JST = timezone(timedelta(hours=9))

_HEARTBEAT_TEMPLATE = """\
schema_version: "1.0"
agent: "sentinel"
status: "{status}"
task_id: null
progress: null
updated_at: "{updated_at}"
message: null
"""


def _write_sentinel_heartbeat(heartbeat_dir: Path, status: str = "idle") -> None:
    """Write sentinel's own heartbeat YAML."""
    now = datetime.now(_JST).strftime("%Y-%m-%dT%H:%M:%S%z")
    path = heartbeat_dir / "sentinel.yaml"
    path.write_text(
        _HEARTBEAT_TEMPLATE.format(status=status, updated_at=now),
        encoding="utf-8",
    )


def main() -> int:
    config = load_config()
    config.heartbeat_dir.mkdir(parents=True, exist_ok=True)
    config.logs_dir.mkdir(parents=True, exist_ok=True)

    # Write sentinel heartbeat as idle on startup
    _write_sentinel_heartbeat(config.heartbeat_dir)

    _reader = HeartbeatReader(config.heartbeat_dir)
    _monitor = MachineMonitor()
    _watcher = QueueWatcher(config.queue_dir)
    _brain = Brain()

    # TODO: event loop integration (fsevents)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
