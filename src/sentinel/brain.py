"""Local LLM interface for Sentinel."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class BrainResult:
    decision: str
    confidence: float
    summary: str | None = None


class Brain:
    def __init__(self, model_name: str | None = None) -> None:
        self.model_name = model_name or "mlx-local"

    def analyze(self, prompt: str) -> BrainResult:
        # TODO: integrate MLX model server.
        return BrainResult(decision="noop", confidence=0.0, summary="stub")
