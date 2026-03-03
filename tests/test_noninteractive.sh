#!/usr/bin/env bash
# tests/test_noninteractive.sh — test non-interactive pipe and direct flags

set -euo pipefail

CONVCOMMIT="${CONVCOMMIT:-$(cd "$(dirname "$0")/.." && pwd)/target/debug/convcommit}"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1 (got: '$2')"; FAIL=$((FAIL + 1)); }

# Run tests in a temp git repo
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
cd "$TMPDIR"
git init -q
git config user.email "test@example.com"
git config user.name "Test"

echo "--- test_noninteractive.sh ---"

# Test 1: --type --scope --message flags produce correct output
result=$("$CONVCOMMIT" --type feat --scope api --message "add endpoint" 2>/dev/null)
expected="feat(api): add endpoint"
if [ "$result" = "$expected" ]; then
  pass "--type --scope --message produces '$expected'"
else
  fail "--type --scope --message" "$result"
fi

# Test 2: --type --message (no scope) produces correct output
# Scope selector still runs; pipe an empty line so it returns empty scope
result=$(printf "\n" | "$CONVCOMMIT" --type fix --message "fix null pointer" 2>/dev/null)
expected="fix: fix null pointer"
if [ "$result" = "$expected" ]; then
  pass "--type --message (no scope) produces '$expected'"
else
  fail "--type --message no scope" "$result"
fi

# Test 3: pipe mode — select by letter (A = first type = fix)
# The .convcommit already exists from previous tests; type:fix is item A
result=$(printf "A\n\n\n" | "$CONVCOMMIT" 2>/dev/null)
if echo "$result" | grep -q "^fix"; then
  pass "pipe mode: letter A selects first type (fix)"
else
  fail "pipe mode: letter A" "$result"
fi

# Test 4: pipe mode — use "." for manual type input
result=$(printf ".\nfix null pointer in login\n\n\n" | "$CONVCOMMIT" 2>/dev/null)
if echo "$result" | grep -q "fix null pointer in login"; then
  pass "pipe mode: '.' triggers manual type input"
else
  fail "pipe mode: '.' manual type" "$result"
fi

# Test 5: short flags -t -s -m
result=$("$CONVCOMMIT" -t docs -s readme -m "update installation" 2>/dev/null)
expected="docs(readme): update installation"
if [ "$result" = "$expected" ]; then
  pass "-t -s -m short flags produce '$expected'"
else
  fail "-t -s -m short flags" "$result"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
