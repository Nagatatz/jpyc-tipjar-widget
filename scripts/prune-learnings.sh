#!/bin/sh
# pztn:260619 learnings.md の成長制御。上限超過時、現在月より古い月の
#   エントリを .claude/learnings-archive/YYYY-MM.md へ退避する。
#   .claude/rules/ の外に置くため、退避したエントリは常時ロードされない。
#   旧版が .claude/rules/learnings-archive-YYYY-MM.md に置いた archive は、実行時に移す。
#
# Usage: scripts/prune-learnings.sh [--dry-run] [--threshold=N]
#   --dry-run      退避対象を表示するのみ（変更しない）
#   --threshold=N  行数上限（既定 400、環境変数 LEARNINGS_MAX でも指定可）
set -eu

RULES_DIR=".claude/rules"
ARCHIVE_DIR=".claude/learnings-archive"
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

# 旧版の archive（.claude/rules/ 内にあり毎セッションロードされていた）を移す
for legacy in "$RULES_DIR"/learnings-archive-*.md; do
  [ -f "$legacy" ] || continue
  m=$(basename "$legacy" .md)
  m=${m#learnings-archive-}
  if [ "$DRY_RUN" = true ]; then
    echo "[dry-run] would move $legacy -> $ARCHIVE_DIR/$m.md"
    continue
  fi
  mkdir -p "$ARCHIVE_DIR"
  if [ -f "$ARCHIVE_DIR/$m.md" ]; then
    # 先頭の見出し（"# ..." とその後の空行）がある場合だけ落として追記する
    awk 'NR == 1 && /^# / { h = 1; next } h && NR == 2 && /^$/ { next } { print }' "$legacy" >> "$ARCHIVE_DIR/$m.md" && rm "$legacy"
  else
    mv "$legacy" "$ARCHIVE_DIR/$m.md"
  fi
  echo "moved legacy archive $legacy -> $ARCHIVE_DIR/$m.md"
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
  archive="$ARCHIVE_DIR/$m.md"
  matches="$(grep -E "^- \[$m" "$FILE" || true)"
  count="$(printf '%s\n' "$matches" | grep -c . || true)"
  if [ "$DRY_RUN" = true ]; then
    echo "[dry-run] would move $count entries ($m) -> $archive"
    continue
  fi
  mkdir -p "$ARCHIVE_DIR"
  if [ ! -f "$archive" ]; then
    printf '# Learnings archive %s\n\n' "$m" > "$archive"
  fi
  printf '%s\n' "$matches" >> "$archive"
  grep -vE "^- \[$m" "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
  echo "moved $count entries ($m) -> $archive"
done
