"""Routing decisions for Sentinel."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class RouteDecision:
    target: str
    reason: str


def decide(event_type: str, payload: dict | None = None) -> RouteDecision:
    # TODO: replace with Brain-based routing.
    return RouteDecision(target="none", reason="stub")
