"""Machine monitoring helpers for Sentinel."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class ResourceSnapshot:
    cpu_percent: float
    memory_percent: float
    disk_percent: float


class MachineMonitor:
    def __init__(self) -> None:
        pass

    def snapshot(self) -> ResourceSnapshot:
        try:
            import psutil  # type: ignore
        except Exception as exc:  # pragma: no cover
            raise RuntimeError("psutil is required for machine monitoring") from exc
        cpu = psutil.cpu_percent(interval=None)
        mem = psutil.virtual_memory().percent
        disk = psutil.disk_usage("/").percent
        return ResourceSnapshot(cpu_percent=cpu, memory_percent=mem, disk_percent=disk)
