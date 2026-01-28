#!/bin/bash
# Validate PO->SM->Dev/QA->SM flow files (read-only check)

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "[FAIL] $1"
  exit 1
}

pass() {
  echo "[OK] $1"
}

[ -f queue/po_to_sm.yaml ] || fail "queue/po_to_sm.yaml not found"

grep -q "^request_id:" queue/po_to_sm.yaml || fail "request_id missing in po_to_sm"
grep -q "^spec_ref:" queue/po_to_sm.yaml || fail "spec_ref missing in po_to_sm"

grep -q "^acceptance_criteria:" queue/po_to_sm.yaml || fail "acceptance_criteria missing in po_to_sm"
pass "PO -> SM queue file looks present"

TASK_FILES=$(ls queue/tasks/*.yaml 2>/dev/null || true)
[ -n "$TASK_FILES" ] || fail "No task files in queue/tasks"

for f in $TASK_FILES; do
  grep -q "^task_id:" "$f" || fail "task_id missing in $f"
  grep -q "^spec_ref:" "$f" || fail "spec_ref missing in $f"
  grep -q "^assignee:" "$f" || fail "assignee missing in $f"
  grep -q "^type:" "$f" || fail "type missing in $f"
  grep -q "^summary:" "$f" || fail "summary missing in $f"
  grep -q "^definition_of_done:" "$f" || fail "definition_of_done missing in $f"
  grep -q "^request_id:" "$f" || fail "request_id missing in $f"
  pass "Task file OK: $f"
done

REPORT_FILES=$(ls queue/reports/*.yaml 2>/dev/null | grep -v TEMPLATE.yaml || true)
if [ -z "$REPORT_FILES" ]; then
  echo "[WARN] No reports found (queue/reports/*.yaml)."
  echo "       Create a report to complete the flow check."
  exit 0
fi

for f in $REPORT_FILES; do
  grep -q "^task_id:" "$f" || fail "task_id missing in $f"
  grep -q "^status:" "$f" || fail "status missing in $f"
  grep -q "^summary:" "$f" || fail "summary missing in $f"
  pass "Report file OK: $f"
done

pass "Flow check completed"
