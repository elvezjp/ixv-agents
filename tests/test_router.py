"""Tests for sentinel.router."""

from __future__ import annotations

from src.sentinel.router import RouteDecision, decide


def test_decide_returns_stub():
    result = decide("queue_change")
    assert isinstance(result, RouteDecision)
    assert result.target == "none"
    assert result.reason == "stub"


def test_decide_with_payload():
    result = decide("heartbeat_timeout", payload={"agent": "dev1"})
    assert isinstance(result, RouteDecision)
