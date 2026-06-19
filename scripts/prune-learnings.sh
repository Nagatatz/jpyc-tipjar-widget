#!/bin/sh
# pztn:260619 learnings.md の成長制御。上限超過時、現在月より古い月の
#   エントリを .claude/rules/learnings-archive-YYYY-MM.md へ退避する。
#   archive は CLAUDE.md から @import されないため、常時ロードから外れる。
#
# Usage: scripts/prune-learnings.sh [--dry-run] [--threshold=N]
#   --dry-run      退避対象を表示するのみ（変更しない）
#   --threshold=N  行数上限（既定 400、環境変数 LEARNINGS_MAX でも指定可）
set -eu

RULES_DIR=".claude/rules"
FILE="$RULES_DIR/learnings.md"
THRESHOLD="${LEARNINGS_MAX:-400}"
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --threshold=*) THRESHOLD="${arg#*=}" ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

[ -f "$FILE" ] || { echo "No $FILE; nothing to prune."; exit 0; }

CURRENT_MONTH="$(date +%Y-%m)"
LINES="$(wc -l < "$FILE" | tr -d ' ')"

# 現在月より古い [YYYY-MM-DD] エントリの月一覧（昇順・重複排除）
OLD_MONTHS="$(grep -oE '^- \[[0-9]{4}-[0-9]{2}' "$FILE" 2>/dev/null \
  | sed -E 's/^- \[//' | sort -u | awk -v cur="$CURRENT_MONTH" '$0 < cur' || true)"

if [ -z "$OLD_MONTHS" ]; then
  echo "No entries older than $CURRENT_MONTH (lines=$LINES, threshold=$THRESHOLD)."
  exit 0
fi

if [ "$LINES" -le "$THRESHOLD" ] && [ "$DRY_RUN" = false ]; then
  echo "learnings.md is $LINES lines (<= $THRESHOLD); no pruning needed."
  echo "Archivable months: $(echo "$OLD_MONTHS" | tr '\n' ' ')(run --dry-run for detail)"
  exit 0
fi

for m in $OLD_MONTHS; do
  archive="$RULES_DIR/learnings-archive-$m.md"
  matches="$(grep -E "^- \[$m" "$FILE" || true)"
  count="$(printf '%s\n' "$matches" | grep -c . || true)"
  if [ "$DRY_RUN" = true ]; then
    echo "[dry-run] would move $count entries ($m) -> $archive"
    continue
  fi
  if [ ! -f "$archive" ]; then
    printf '# Learnings archive %s\n\n' "$m" > "$archive"
  fi
  printf '%s\n' "$matches" >> "$archive"
  grep -vE "^- \[$m" "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
  echo "moved $count entries ($m) -> $archive"
done
