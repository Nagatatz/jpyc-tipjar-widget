#!/bin/sh
# pztn:260619 常時ロードされる規約のトークンコスト計測。
#   CLAUDE.md.template の @import チェーン(1段、HTMLコメント内は除外)を展開し、
#   各ファイルの行数・バイト・推定トークン(bytes/4)を集計する。
#   claude-md-hygiene.md の肥大化警告に従い、閾値超過を警告する。
# Usage: scripts/measure-context-cost.sh [--threshold=N] [--strict]
#   --threshold=N  推定トークンの警告閾値(既定 8000)
#   --strict       閾値超過時に exit 1(CI ゲート用)。既定は警告のみ exit 0
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ENTRY="CLAUDE.md.template"
THRESHOLD=8000
STRICT=false
for arg in "$@"; do
  case "$arg" in
    --threshold=*) THRESHOLD="${arg#*=}" ;;
    --strict) STRICT=true ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

[ -f "$ENTRY" ] || { echo "No $ENTRY found." >&2; exit 1; }

# コメント外の @import 先を列挙
imports_of() {
  awk '
    { line=$0 }
    index(line,"<!--") { inc=1 }
    inc==0 && line ~ /^@[^ ]+/ { sub(/^@/,"",line); split(line,a," "); print a[1] }
    index(line,"-->") { inc=0 }
  ' "$1"
}

OUT_DIR="docs/audits"
DATE="$(date +%Y-%m-%d)"
REPORT="$OUT_DIR/$DATE-context-cost.md"
mkdir -p "$OUT_DIR"

total_lines=0
total_bytes=0
rows=""

measure() {  # measure <file>
  f="$1"
  [ -f "$f" ] || { rows="$rows| \`$f\` | (missing) | - | - |\n"; return 0; }
  l="$(wc -l < "$f" | tr -d ' ')"
  b="$(wc -c < "$f" | tr -d ' ')"
  t=$((b / 4))
  total_lines=$((total_lines + l))
  total_bytes=$((total_bytes + b))
  rows="$rows| \`$f\` | $l | $b | ~$t |\n"
}

measure "$ENTRY"
for imp in $(imports_of "$ENTRY"); do
  measure "$imp"
done

total_tokens=$((total_bytes / 4))

{
  echo "# 常時ロード規約のトークンコスト ($DATE)"
  echo ""
  echo "起点: \`$ENTRY\` + その @import チェーン(1段、コメント内除外)。"
  echo "推定トークンは bytes/4 の概算。"
  echo ""
  echo "| ファイル | 行 | bytes | 推定tokens |"
  echo "|---------|----|-------|-----------|"
  printf '%b' "$rows"
  echo "| **合計** | **$total_lines** | **$total_bytes** | **~$total_tokens** |"
  echo ""
  if [ "$total_tokens" -gt "$THRESHOLD" ]; then
    echo "> ⚠️ 推定 $total_tokens tokens は閾値 $THRESHOLD を超過。"
    echo "> 状況発火で済む規約は \`.claude/skills/\` への降格を検討(claude-md-hygiene.md)。"
  else
    echo "> ✅ 推定 $total_tokens tokens / 閾値 $THRESHOLD 以内。"
  fi
} > "$REPORT"

echo "Always-loaded context: $total_lines lines, $total_bytes bytes, ~$total_tokens tokens (threshold $THRESHOLD)."
echo "Report: $REPORT"

if [ "$total_tokens" -gt "$THRESHOLD" ]; then
  echo "⚠️  Over threshold." >&2
  [ "$STRICT" = true ] && exit 1
fi
exit 0
