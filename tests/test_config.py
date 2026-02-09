"""Tests for sentinel.config."""

from __future__ import annotations

import os
from pathlib import Path

from src.sentinel.config import SentinelConfig, load_config


def test_load_config_defaults(tmp_path: Path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    monkeypatch.delenv("IXV_REPO_ROOT", raising=False)
    monkeypatch.delenv("IXV_QUEUE_DIR", raising=False)
    monkeypatch.delenv("IXV_HEARTBEAT_DIR", raising=False)
    monkeypatch.delenv("IXV_SENTINEL_LOGS", raising=False)
    monkeypatch.delenv("IXV_FSEVENTS", raising=False)
    monkeypatch.delenv("IXV_DRY_RUN", raising=False)

    cfg = load_config()

    assert cfg.repo_root == tmp_path
    assert cfg.queue_dir == tmp_path / "workspace" / "queue"
    assert cfg.heartbeat_dir == tmp_path / "workspace" / "queue" / "heartbeat"
    assert cfg.logs_dir == tmp_path / "logs" / "sentinel"
    assert cfg.fsevents_enabled is True
    assert cfg.dry_run is False


def test_load_config_custom_env(tmp_path: Path, monkeypatch):
    custom_root = tmp_path / "custom"
    custom_root.mkdir()
    monkeypatch.setenv("IXV_REPO_ROOT", str(custom_root))
    monkeypatch.setenv("IXV_FSEVENTS", "0")
    monkeypatch.setenv("IXV_DRY_RUN", "1")

    cfg = load_config()

    assert cfg.repo_root == custom_root
    assert cfg.fsevents_enabled is False
    assert cfg.dry_run is True


def test_load_config_prefers_repo_queue(tmp_path: Path, monkeypatch):
    repo_queue = tmp_path / "queue"
    repo_queue.mkdir(parents=True)
    monkeypatch.chdir(tmp_path)
    monkeypatch.delenv("IXV_QUEUE_DIR", raising=False)
    monkeypatch.delenv("IXV_HEARTBEAT_DIR", raising=False)

    cfg = load_config()

    assert cfg.queue_dir == repo_queue
    assert cfg.heartbeat_dir == repo_queue / "heartbeat"


def test_config_is_frozen(tmp_path: Path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    cfg = load_config()

    try:
        cfg.dry_run = True  # type: ignore[misc]
        assert False, "SentinelConfig should be frozen"
    except AttributeError:
        pass
