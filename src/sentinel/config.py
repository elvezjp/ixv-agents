"""Configuration helpers for Sentinel."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import os


@dataclass(frozen=True)
class SentinelConfig:
    repo_root: Path
    queue_dir: Path
    heartbeat_dir: Path
    logs_dir: Path
    fsevents_enabled: bool
    dry_run: bool


def load_config() -> SentinelConfig:
    repo_root = Path(os.getenv("IXV_REPO_ROOT", Path.cwd())).resolve()
    queue_dir_env = os.getenv("IXV_QUEUE_DIR")
    if queue_dir_env:
        queue_dir = Path(queue_dir_env)
    else:
        repo_queue = repo_root / "queue"
        workspace_queue = repo_root / "workspace" / "queue"
        if repo_queue.exists():
            queue_dir = repo_queue
        elif workspace_queue.exists():
            queue_dir = workspace_queue
        else:
            queue_dir = workspace_queue
    heartbeat_dir = Path(os.getenv("IXV_HEARTBEAT_DIR", queue_dir / "heartbeat"))
    logs_dir = Path(os.getenv("IXV_SENTINEL_LOGS", repo_root / "logs" / "sentinel"))
    fsevents_enabled = os.getenv("IXV_FSEVENTS", "1") == "1"
    dry_run = os.getenv("IXV_DRY_RUN", "0") == "1"

    return SentinelConfig(
        repo_root=repo_root,
        queue_dir=queue_dir,
        heartbeat_dir=heartbeat_dir,
        logs_dir=logs_dir,
        fsevents_enabled=fsevents_enabled,
        dry_run=dry_run,
    )
