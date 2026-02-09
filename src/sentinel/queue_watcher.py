"""Queue watcher placeholder for Sentinel."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass
class QueueEvent:
    path: Path
    kind: str


class QueueWatcher:
    def __init__(self, queue_dir: Path) -> None:
        self.queue_dir = queue_dir

    def next_event(self) -> QueueEvent | None:
        # TODO: integrate fsevents for event-driven watching.
        return None
