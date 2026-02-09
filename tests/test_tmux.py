"""Tests for sentinel.tmux."""

from __future__ import annotations

from src.sentinel.tmux import TmuxCommand, build_send_keys, send_keys


def test_build_send_keys():
    cmd = TmuxCommand(pane="ixv-agents:0.1", command="/ask start task")
    args = build_send_keys(cmd)

    assert args == ["tmux", "send-keys", "-t", "ixv-agents:0.1", "/ask start task", "Enter"]


def test_send_keys_dry_run():
    cmd = TmuxCommand(pane="ixv-agents:0.0", command="hello")
    # dry_run=True should not raise even without tmux
    send_keys(cmd, dry_run=True)


def test_tmux_command_is_frozen():
    cmd = TmuxCommand(pane="x", command="y")
    try:
        cmd.pane = "z"  # type: ignore[misc]
        assert False, "TmuxCommand should be frozen"
    except AttributeError:
        pass
