#!/usr/bin/env bash
# Claude Code statusLine: <model> | <branch> | ctx <pct>%
# Reads JSON from stdin per Claude Code statusLine spec.
# Requires `jq`; falls back to model-only output if `jq` is missing.

set -euo pipefail

input=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  printf "Claude (jq not installed)"
  exit 0
fi

model=$(printf "%s" "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(printf "%s" "$input" | jq -r '.workspace.current_dir // ""')
context_pct=$(printf "%s" "$input" | jq -r '.cost.context_used_percent // empty')

printf "%s" "$model"

if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null || true)
  if [ -n "$branch" ]; then
    printf " | %s" "$branch"
  fi
fi

if [ -n "$context_pct" ]; then
  printf " | ctx %s%%" "$context_pct"
fi
