#!/usr/bin/env bash
# tests/test_interactive.sh — interactive flow tests using expect

set -euo pipefail

CONVCOMMIT="${CONVCOMMIT:-$(cd "$(dirname "$0")/.." && pwd)/target/debug/convcommit}"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1 (got: '$2')"; FAIL=$((FAIL + 1)); }

echo "--- test_interactive.sh ---"

# Check that expect is available
if ! command -v expect >/dev/null 2>&1; then
  echo "  SKIP: 'expect' not installed — install with: sudo apt install expect"
  exit 0
fi

# Run tests in a temp git repo
TMPDIR=$(mktemp -d)
TMPOUT=$(mktemp)
trap 'rm -rf "$TMPDIR" "$TMPOUT"' EXIT
cd "$TMPDIR"
git init -q
git config user.email "test@example.com"
git config user.name "Test"

# Note on selector flow with default .convcommit:
#   type:  has 16 options → shows menu, reads single keypress via dd
#   scope: only has scope:_ (manual) + scope:~ (empty/default) → no menu,
#          goes directly to "Manually type a scope:" prompt
#   message: same as scope → directly asks "Manually type a message:"

# Test 1: .convcommit is auto-created on first interactive run
expect -c "
  set timeout 5
  log_user 0
  spawn $CONVCOMMIT
  expect \"Choose commit type\"
  send \"A\"
  expect \"Manually type a scope\"
  send \"\r\"
  expect \"Manually type a message\"
  send \"\r\"
  expect eof
" > /dev/null 2>&1 || true

if [ -f ".convcommit" ]; then
  pass ".convcommit auto-created on interactive first run"
else
  fail ".convcommit not created during interactive run" ""
fi

# Test 2: select type F (fix, forced [F]fix), manual scope "auth", manual message "fix null pointer"
# Output goes to TMPOUT so we can inspect it cleanly
true > "$TMPOUT"
expect -c "
  set timeout 5
  log_user 0
  spawn sh -c \"$CONVCOMMIT > $TMPOUT\"
  expect \"Choose commit type\"
  send \"G\"
  expect \"Manually type a scope\"
  send \"auth\r\"
  expect \"Manually type a message\"
  send \"fix null pointer\r\"
  expect eof
" > /dev/null 2>&1 || true

result=$(cat "$TMPOUT")
if [ "$result" = "fix(auth): fix null pointer" ]; then
  pass "interactive: fix → sequential G → fix(auth): fix null pointer"
else
  fail "interactive: expected 'fix(auth): fix null pointer'" "$result"
fi

# Test 3: select type C (chore, the default), empty scope, empty message
true > "$TMPOUT"
expect -c "
  set timeout 5
  log_user 0
  spawn sh -c \"$CONVCOMMIT > $TMPOUT\"
  expect \"Choose commit type\"
  send \"C\"
  expect \"Manually type a scope\"
  send \"\r\"
  expect \"Manually type a message\"
  send \"update deps\r\"
  expect eof
" > /dev/null 2>&1 || true

result=$(cat "$TMPOUT")
if echo "$result" | grep -q "^chore"; then
  pass "interactive: letter C selects 'chore' type"
else
  fail "interactive: expected 'chore:...' output" "$result"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
