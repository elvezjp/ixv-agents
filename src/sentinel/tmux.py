"""Thin tmux adapter for send-keys."""

from __future__ import annotations

import subprocess
from dataclasses import dataclass


@dataclass(frozen=True)
class TmuxCommand:
    pane: str
    command: str


def build_send_keys(cmd: TmuxCommand) -> list[str]:
    return ["tmux", "send-keys", "-t", cmd.pane, cmd.command, "Enter"]


def send_keys(cmd: TmuxCommand, dry_run: bool = False) -> None:
    args = build_send_keys(cmd)
    if dry_run:
        return
    subprocess.run(args, check=False)
