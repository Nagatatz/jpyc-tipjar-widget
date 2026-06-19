#!/bin/sh
# pztn:260619 内部参照の整合性リンター。
#   HARD (exit 1): CLAUDE.md.template / .claude/**/*.md 内の @import が解決すること
#                  (HTML コメント内の @import と、生成前提の learnings.md は除外)。
#   WARN (exit 0): 本文中の .claude/<type>/<name> 明示パス参照の実在
#                  (examples/ は説明用の架空パスを含むため除外)。
# Usage: scripts/check-references.sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

HARD_ERRORS=0
WARN_COUNT=0

# 生成前提・任意で実在しなくてよい @import 先（basename）
is_allowlisted() {
  case "$1" in
    *learnings.md|*learnings-archive-*.md|*CLAUDE.local.md) return 0 ;;
    *) return 1 ;;
  esac
}

# 走査対象ファイル（examples は説明用パスを含むため除外）
FILES="$(
  { [ -f CLAUDE.md.template ] && echo CLAUDE.md.template; } || true
  find .claude/rules .claude/skills -name '*.md' 2>/dev/null || true
)"

# --- HARD: @import resolvability (HTML コメント内は除外) ---
for file in $FILES; do
  # awk でコメント状態を追跡し、コメント外の @import 行のみ抽出
  imports="$(awk '
    { line=$0 }
    index(line,"<!--") { inc=1 }
    inc==0 && line ~ /^@[^ ]+/ { sub(/^@/,"",line); split(line,a," "); print a[1] }
    index(line,"-->") { inc=0 }
  ' "$file")"
  for imp in $imports; do
    if is_allowlisted "$imp"; then continue; fi
    if [ ! -e "$imp" ]; then
      echo "ERROR  $file: unresolved @import -> $imp"
      HARD_ERRORS=$((HARD_ERRORS + 1))
    fi
  done
done

# --- WARN: explicit .claude/<type>/<name> path mentions ---
for file in $FILES; do
  paths="$(grep -oE '\.claude/(rules|skills|agents|commands|hooks|workflows|output-styles)/[A-Za-z0-9._-]+' "$file" 2>/dev/null | sort -u || true)"
  for p in $paths; do
    base="$(basename "$p")"
    if is_allowlisted "$base"; then continue; fi
    if [ ! -e "$p" ]; then
      echo "WARN   $file: path mention not found -> $p"
      WARN_COUNT=$((WARN_COUNT + 1))
    fi
  done
done

echo ""
echo "Reference check: $HARD_ERRORS hard error(s), $WARN_COUNT warning(s)."
[ "$HARD_ERRORS" -eq 0 ] || exit 1
