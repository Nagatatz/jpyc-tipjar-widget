#!/bin/sh
# PreCompact hook: saves session state before context compaction.
# Allows the agent to recover context after compaction.
# Informational only (exit 0 always).

STATE_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/session-state.md"
STEERING_DIR="${CLAUDE_PROJECT_DIR:-.}/.steering"

# Collect incomplete tasks from all active tasklists (excluding archive/)
INCOMPLETE_TASKS=$(
  find "$STEERING_DIR" -name "tasklist.md" -type f 2>/dev/null \
    | grep -v '/archive/' \
    | sort \
    | while IFS= read -r f; do
        items=$(grep '^\- \[ \]' "$f" 2>/dev/null)
        if [ -n "$items" ]; then
          echo ""
          echo "#### $(echo "$f" | sed "s|${CLAUDE_PROJECT_DIR:-.}/||")"
          echo "$items"
        fi
      done
)

cat > "$STATE_FILE" << EOF
# Session State (auto-saved before compaction)

- **Branch:** $(git branch --show-current 2>/dev/null || echo "unknown")
- **Worktrees:** $(git worktree list 2>/dev/null | grep -v "^$" || echo "none")
- **Modified files:** $(git diff --name-only 2>/dev/null | head -20 || echo "none")
- **Staged files:** $(git diff --cached --name-only 2>/dev/null | head -20 || echo "none")
- **Active steering:** $(ls -d "$STEERING_DIR"/2* 2>/dev/null | tail -1 || echo "none")
- **Timestamp:** $(date '+%Y-%m-%d %H:%M:%S')

## Incomplete Tasks
${INCOMPLETE_TASKS:-"(none)"}
EOF

exit 0
