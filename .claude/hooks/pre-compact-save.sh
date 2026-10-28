#!/bin/sh
# PreCompact hook: saves session state before context compaction.
# Allows the agent to recover context after compaction.
# Informational only (exit 0 always).

STATE_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/session-state.md"

# Print stdin, or "none" when it is empty (`cmd | head || echo none` never prints none).
or_none() { out=$(cat); if [ -n "$out" ]; then printf '%s' "$out"; else printf 'none'; fi; }

BRANCH=$(git branch --show-current 2>/dev/null)

# The DoD lives in the GitHub Issue, so record only where to look; calling gh here
# would make compaction wait on the network. Issue numbers come from the branch
# name and recent commit subjects (e.g. feature/123-x, "Fix y (#123)").
ISSUE_HINTS=$( {
    printf '%s\n' "$BRANCH" | grep -oE '(^|/)[0-9]+(-|$)'
    git log -10 --format=%s 2>/dev/null | grep -oE '#[0-9]+'
  } | grep -oE '[0-9]+' | sort -un | head -5 | tr '\n' ' ' | sed 's/ $//')

cat > "$STATE_FILE" << STATE
# Session State (auto-saved before compaction)

- **Branch:** ${BRANCH:-unknown}
- **Worktrees:** $(git worktree list 2>/dev/null | grep -v "^$" | or_none)
- **Modified files:** $(git diff --name-only 2>/dev/null | head -20 | or_none)
- **Staged files:** $(git diff --cached --name-only 2>/dev/null | head -20 | or_none)
- **Issue number candidates:** $(printf '%s' "$ISSUE_HINTS" | or_none)
- **Timestamp:** $(date '+%Y-%m-%d %H:%M:%S')

The DoD is in the GitHub Issue: check it with \`gh issue view <number>\`.
STATE

exit 0
