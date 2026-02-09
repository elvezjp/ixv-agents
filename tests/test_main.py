"""Tests for sentinel.main."""

from __future__ import annotations

from pathlib import Path

import yaml

from src.sentinel.main import _write_sentinel_heartbeat


def test_write_sentinel_heartbeat_creates_file(tmp_path: Path):
    hb_dir = tmp_path / "heartbeat"
    hb_dir.mkdir()

    _write_sentinel_heartbeat(hb_dir)

    path = hb_dir / "sentinel.yaml"
    assert path.exists()

    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    assert data["agent"] == "sentinel"
    assert data["status"] == "idle"
    assert data["schema_version"] == "1.0"
    assert data["updated_at"] is not None


def test_write_sentinel_heartbeat_with_status(tmp_path: Path):
    hb_dir = tmp_path / "heartbeat"
    hb_dir.mkdir()

    _write_sentinel_heartbeat(hb_dir, status="working")

    data = yaml.safe_load((hb_dir / "sentinel.yaml").read_text(encoding="utf-8"))
    assert data["status"] == "working"
