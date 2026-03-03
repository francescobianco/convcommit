#!/usr/bin/env bash
# tests/test_config.sh — verify .convcommit auto-creation and header content

set -euo pipefail

CONVCOMMIT="${CONVCOMMIT:-$(cd "$(dirname "$0")/.." && pwd)/target/debug/convcommit}"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

# Run tests in a temp git repo
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
cd "$TMPDIR"
git init -q
git config user.email "test@example.com"
git config user.name "Test"

echo "--- test_config.sh ---"

# Test 1: .convcommit does not exist initially
if [ ! -f ".convcommit" ]; then
  pass ".convcommit does not exist before first run"
else
  fail ".convcommit should not exist before first run"
fi

# Test 2: convcommit creates .convcommit when run with direct flags (no interaction)
"$CONVCOMMIT" --type fix --scope auth --message "test" > /dev/null 2>&1 || true

if [ -f ".convcommit" ]; then
  pass ".convcommit created automatically on first run"
else
  fail ".convcommit was not created"
fi

# Test 3: .convcommit contains the header comment
if grep -q "# convcommit - Conventional Commit message builder" .convcommit; then
  pass ".convcommit contains header comment"
else
  fail ".convcommit missing header comment"
fi

# Test 4: .convcommit contains FORMAT section
if grep -q "# FORMAT" .convcommit; then
  pass ".convcommit contains FORMAT section"
else
  fail ".convcommit missing FORMAT section"
fi

# Test 5: .convcommit contains AI agent usage instructions
if grep -q "AI agent" .convcommit; then
  pass ".convcommit contains AI agent instructions"
else
  fail ".convcommit missing AI agent instructions"
fi

# Test 6: .convcommit contains type: entries
if grep -q "^type:" .convcommit; then
  pass ".convcommit contains type: entries"
else
  fail ".convcommit missing type: entries"
fi

# Test 7: .convcommit contains scope: entries
if grep -q "^scope:" .convcommit; then
  pass ".convcommit contains scope: entries"
else
  fail ".convcommit missing scope: entries"
fi

# Test 8: .convcommit contains message: entries
if grep -q "^message:" .convcommit; then
  pass ".convcommit contains message: entries"
else
  fail ".convcommit missing message: entries"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
