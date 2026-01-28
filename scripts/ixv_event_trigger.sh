#!/bin/bash
# Append an event marker to dashboard.md (SM operation)
# Usage: ./scripts/ixv_event_trigger.sh planning|daily|review

set -e

EVENT="$1"
if [ -z "$EVENT" ]; then
  echo "Usage: ./scripts/ixv_event_trigger.sh planning|daily|review"
  exit 1
fi

case "$EVENT" in
  planning|daily|review) ;;
  *)
    echo "Invalid event: $EVENT"
    exit 1
    ;;
esac

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

python3 - "$EVENT" <<'PY'
import datetime
import sys
from pathlib import Path

root = Path(".")
dashboard = root / "dashboard.md"
if not dashboard.exists():
    print("dashboard.md not found")
    sys.exit(1)

event = sys.argv[1]
now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
line = f"- [{now}] EVENT: {event}"

text = dashboard.read_text()
if "## Notes" not in text:
    text = text.rstrip() + "\n\n## Notes\n"

parts = text.split("## Notes", 1)
head = parts[0] + "## Notes"
rest = parts[1]

if rest.strip().startswith("-"):
    new_rest = "\n" + line + "\n" + rest.lstrip("\n")
else:
    new_rest = "\n" + line + "\n" + rest

new_text = head + new_rest

dashboard.write_text(new_text)
print(f"[OK] appended event '{event}' to dashboard.md")
PY
