#!/bin/sh
# PreToolUse hook for Bash tool.
# Blocks dangerous commands: git add ., git add -A, git push --force, rm -rf (all flag forms).
# Reads JSON from stdin, extracts tool_input.command, and checks against block patterns.
# Exit 0 = allow, Exit 2 = block.

# Read stdin
INPUT=$(cat)

# Extract command field (fail-open if jq is unavailable or parse fails)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null) || exit 0

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Check for blocked patterns
# git add . (exact match at end of command or with trailing options)
if echo "$COMMAND" | grep -qE '(^|&&\s*|;\s*)git\s+add\s+\.$'; then
  echo "BLOCKED: 'git add .' is not allowed. Stage specific files instead." >&2
  exit 2
fi

# git add -A
if echo "$COMMAND" | grep -qE '(^|&&\s*|;\s*)git\s+add\s+(-\S*A|-A)'; then
  echo "BLOCKED: 'git add -A' is not allowed. Stage specific files instead." >&2
  exit 2
fi

# git push --force or git push -f
if echo "$COMMAND" | grep -qE '(^|&&\s*|;\s*)git\s+push\s+.*(-f|--force)'; then
  echo "BLOCKED: 'git push --force' is not allowed. Use regular push." >&2
  exit 2
fi

# rm with recursive+force flags in any combination:
#   -rf, -fr, -r -f, -f -r, --recursive --force, --force --recursive,
#   combined short flags like -Irf, sudo rm -rf, etc.
# Strategy: detect rm with both a recursive flag AND a force flag present anywhere in its arguments.
if echo "$COMMAND" | grep -qE '(^|&&\s*|;\s*)(sudo\s+)?rm\b'; then
  # Extract the rm invocation and check if it has both recursive and force indicators
  RM_ARGS=$(echo "$COMMAND" | grep -oE '(sudo\s+)?rm(\s+-\S+|\s+--[a-z-]+)*' | head -1)
  HAS_RECURSIVE=$(echo "$RM_ARGS" | grep -qE '(\s-[a-zA-Z]*r[a-zA-Z]*|\s--recursive)' && echo 1 || echo 0)
  HAS_FORCE=$(echo "$RM_ARGS" | grep -qE '(\s-[a-zA-Z]*f[a-zA-Z]*|\s--force)' && echo 1 || echo 0)
  if [ "$HAS_RECURSIVE" = "1" ] && [ "$HAS_FORCE" = "1" ]; then
    echo "BLOCKED: 'rm -rf' (or equivalent) is not allowed. Remove files individually." >&2
    exit 2
  fi
fi

exit 0
