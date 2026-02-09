"""Tests for sentinel.heartbeat."""

from __future__ import annotations

from pathlib import Path

from src.sentinel.heartbeat import HeartbeatReader, HeartbeatState


_SAMPLE_YAML = """\
schema_version: "1.0"
agent: "dev1"
status: "working"
task_id: "TASK-20260209-001"
progress: 0.3
updated_at: "2026-02-09T14:30:00+0900"
message: "implementing auth module"
"""

_MINIMAL_YAML = """\
agent: "po"
status: "idle"
updated_at: "2026-02-09T10:00:00+0900"
"""


def test_read_full_heartbeat(tmp_path: Path):
    hb_dir = tmp_path / "heartbeat"
    hb_dir.mkdir()
    (hb_dir / "dev1.yaml").write_text(_SAMPLE_YAML, encoding="utf-8")

    reader = HeartbeatReader(hb_dir)
    state = reader.read("dev1")

    assert state is not None
    assert state.agent == "dev1"
    assert state.status == "working"
    assert state.schema_version == "1.0"
    assert state.task_id == "TASK-20260209-001"
    assert state.progress == 0.3
    assert state.message == "implementing auth module"
    assert "2026-02-09" in state.updated_at


def test_read_minimal_heartbeat(tmp_path: Path):
    hb_dir = tmp_path / "heartbeat"
    hb_dir.mkdir()
    (hb_dir / "po.yaml").write_text(_MINIMAL_YAML, encoding="utf-8")

    reader = HeartbeatReader(hb_dir)
    state = reader.read("po")

    assert state is not None
    assert state.agent == "po"
    assert state.status == "idle"
    assert state.schema_version == "1.0"  # default
    assert state.task_id is None
    assert state.progress is None
    assert state.message is None


def test_read_missing_agent(tmp_path: Path):
    hb_dir = tmp_path / "heartbeat"
    hb_dir.mkdir()

    reader = HeartbeatReader(hb_dir)
    state = reader.read("dev2")

    assert state is None
