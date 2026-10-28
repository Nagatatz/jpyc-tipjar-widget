#!/bin/sh
# pztn:260619 内部参照の整合性リンター。
#   HARD (exit 1): AGENTS.md(.template) / .claude/**/*.md 内の @import が解決すること
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

# エントリファイル: downstream では AGENTS.md（旧構成は CLAUDE.md）、テンプレートでは AGENTS.md.template
if [ -f install.sh ] && [ -f AGENTS.md.template ]; then
  ENTRY_FILE=AGENTS.md.template
elif [ -f CLAUDE.md ]; then
  ENTRY_FILE=CLAUDE.md
elif [ -f AGENTS.md ]; then
  ENTRY_FILE=AGENTS.md
elif [ -f AGENTS.md.template ]; then
  ENTRY_FILE=AGENTS.md.template
else
  ENTRY_FILE=""
fi

# 走査対象ファイル（examples は説明用パスを含むため除外）
FILES="$(
  { [ -n "$ENTRY_FILE" ] && echo "$ENTRY_FILE"; } || true
  find .claude/rules .claude/skills .claude/commands -name '*.md' 2>/dev/null || true
)"

# subagent_type= が参照してよいビルトインエージェント（.claude/agents/ に .md を持たない）
is_builtin_agent() {
  case "$1" in
    general-purpose|Explore|Plan|claude|claude-code-guide|statusline-setup|output-style-setup) return 0 ;;
    *) return 1 ;;
  esac
}

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

# --- HARD: subagent_type="<name>" が実在エージェント or ビルトインを指すこと ---
for file in $FILES; do
  # subagent_type= の後ろの（任意の引用符付き）エージェント名を抽出
  agents="$(grep -oE "subagent_type[[:space:]]*=[[:space:]]*['\"]?[A-Za-z0-9_-]+" "$file" 2>/dev/null \
    | sed -E "s/^subagent_type[[:space:]]*=[[:space:]]*['\"]?//" | sort -u || true)"
  for ag in $agents; do
    if is_builtin_agent "$ag"; then continue; fi
    if [ ! -e ".claude/agents/$ag.md" ]; then
      echo "ERROR  $file: subagent_type refers to unknown agent -> $ag"
      HARD_ERRORS=$((HARD_ERRORS + 1))
    fi
  done
done

echo ""
echo "Reference check: $HARD_ERRORS hard error(s), $WARN_COUNT warning(s)."
[ "$HARD_ERRORS" -eq 0 ] || exit 1
