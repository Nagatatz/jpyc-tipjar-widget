#!/bin/sh
# Stop hook: checks all active tasklist.md files for incomplete tasks.
# Skips archived steering (.steering/archive/).
# Warns if any have unchecked items. Never blocks (exit 0 always).

STEERING_DIR="$CLAUDE_PROJECT_DIR/.steering"

# Find all tasklist.md files, excluding archive/
FOUND=$(find "$STEERING_DIR" -name "tasklist.md" -type f 2>/dev/null \
  | grep -v '/archive/' \
  | sort)

if [ -z "$FOUND" ]; then
  exit 0
fi

echo "$FOUND" | while IFS= read -r tasklist; do
  # pztn:260619 grep -c は 0 件でも "0" を出力し exit 1 になる。旧 `|| echo "0"`
  #   は grep の "0" に echo の "0" が連結して "0\n0" となり -gt が壊れていた。
  INCOMPLETE=$(grep -c '^\- \[ \]' "$tasklist" 2>/dev/null || true)
  INCOMPLETE=${INCOMPLETE:-0}
  if [ "$INCOMPLETE" -gt 0 ]; then
    echo "Warning: $tasklist has $INCOMPLETE incomplete task(s)" >&2
  fi
done

exit 0
