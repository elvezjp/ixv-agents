"""Tests for sentinel.brain."""

from __future__ import annotations

from src.sentinel.brain import Brain, BrainResult


def test_brain_stub_returns_noop():
    brain = Brain()
    result = brain.analyze("test prompt")

    assert isinstance(result, BrainResult)
    assert result.decision == "noop"
    assert result.confidence == 0.0
    assert result.summary == "stub"


def test_brain_custom_model_name():
    brain = Brain(model_name="qwen-72b")
    assert brain.model_name == "qwen-72b"


def test_brain_default_model_name():
    brain = Brain()
    assert brain.model_name == "mlx-local"
