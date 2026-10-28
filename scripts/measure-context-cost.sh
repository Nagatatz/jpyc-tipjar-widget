#!/bin/sh
# pztn:260807 常時ロードされる規約のトークンコスト計測。
#   対象は (1) エントリファイル(CLAUDE.md があればそれ、無ければ AGENTS.md → AGENTS.md.template) とその @import チェーン(1段、HTMLコメント内は除外)、
#   (2) .claude/rules/*.md。rules は frontmatter の `paths:` の有無で
#   無条件ロードと条件ロード(該当ソースファイルを読んだときだけ)に分類する。
#   閾値判定は無条件ロード分のみを対象にする。
# Usage: scripts/measure-context-cost.sh [--threshold=N] [--strict]
#   --threshold=N  推定トークンの警告閾値(既定 8000)
#   --strict       閾値超過時に exit 1(CI ゲート用)。既定は警告のみ exit 0
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# テンプレートリポジトリ自身（install.sh と AGENTS.md.template が並ぶ）では配布物を測る。
# それ以外では、CLAUDE.md があると Claude Code は AGENTS.md を読まないため CLAUDE.md を測る
if [ -f "install.sh" ] && [ -f "AGENTS.md.template" ]; then
  ENTRY="AGENTS.md.template"
elif [ -f "CLAUDE.md" ]; then
  ENTRY="CLAUDE.md"
elif [ -f "AGENTS.md" ]; then
  ENTRY="AGENTS.md"
else
  ENTRY="AGENTS.md.template"
fi
RULES_DIR=".claude/rules"
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
echo "Entry: $ENTRY"

# コメント外の @import 先を列挙
imports_of() {
  awk '
    { line=$0 }
    index(line,"<!--") { inc=1 }
    inc==0 && line ~ /^@[^ ]+/ { sub(/^@/,"",line); split(line,a," "); print a[1] }
    index(line,"-->") { inc=0 }
  ' "$1"
}

# frontmatter(先頭 --- ブロック)に paths: があれば 0 を返す。
# awk の exit は END ブロックを実行するため、判定はフラグに持たせて END で返す。
has_paths() {
  awk '
    BEGIN { found = 0 }
    NR==1 && $0 != "---" { exit }
    NR>1  && $0 == "---" { exit }
    NR>1  && /^paths:/   { found = 1; exit }
    END { exit (found ? 0 : 1) }
  ' "$1"
}

OUT_DIR="docs/audits"
DATE="$(date +%Y-%m-%d)"
REPORT="$OUT_DIR/$DATE-context-cost.md"
mkdir -p "$OUT_DIR"

uncond_lines=0; uncond_bytes=0; uncond_rows=""
cond_lines=0;   cond_bytes=0;   cond_rows=""

measure() {  # measure <file> <uncond|cond>
  f="$1"; kind="$2"
  if [ ! -f "$f" ]; then
    uncond_rows="$uncond_rows| \`$f\` | (missing) | - | - |\n"
    return 0
  fi
  l="$(wc -l < "$f" | tr -d ' ')"
  b="$(wc -c < "$f" | tr -d ' ')"
  t=$((b / 4))
  if [ "$kind" = uncond ]; then
    uncond_lines=$((uncond_lines + l)); uncond_bytes=$((uncond_bytes + b))
    uncond_rows="$uncond_rows| \`$f\` | $l | $b | ~$t |\n"
  else
    cond_lines=$((cond_lines + l)); cond_bytes=$((cond_bytes + b))
    cond_rows="$cond_rows| \`$f\` | $l | $b | ~$t |\n"
  fi
}

measure "$ENTRY" uncond
for imp in $(imports_of "$ENTRY"); do
  measure "$imp" uncond
done

if [ -d "$RULES_DIR" ]; then
  for rule in "$RULES_DIR"/*.md; do
    [ -f "$rule" ] || continue
    if has_paths "$rule"; then
      measure "$rule" cond
    else
      measure "$rule" uncond
    fi
  done
fi

uncond_tokens=$((uncond_bytes / 4))
cond_tokens=$((cond_bytes / 4))

{
  echo "# 常時ロード規約のトークンコスト ($DATE)"
  echo ""
  echo "対象: \`$ENTRY\` + その @import チェーン(1段、コメント内除外) と \`$RULES_DIR/*.md\`。"
  echo "\`$RULES_DIR/*.md\` は \`@import\` 無しで自動ロードされるため、frontmatter の \`paths:\` の"
  echo "有無で無条件 / 条件ロードに分類する。推定トークンは bytes/4 の概算。"
  echo ""
  echo "## 無条件ロード（毎セッション）"
  echo ""
  echo "| ファイル | 行 | bytes | 推定tokens |"
  echo "|---------|----|-------|-----------|"
  printf '%b' "$uncond_rows"
  echo "| **合計** | **$uncond_lines** | **$uncond_bytes** | **~$uncond_tokens** |"
  echo ""
  echo "## 条件ロード（\`paths:\` 一致時のみ）"
  echo ""
  if [ -z "$cond_rows" ]; then
    echo "(なし)"
  else
    echo "| ファイル | 行 | bytes | 推定tokens |"
    echo "|---------|----|-------|-----------|"
    printf '%b' "$cond_rows"
    echo "| **合計** | **$cond_lines** | **$cond_bytes** | **~$cond_tokens** |"
  fi
  echo ""
  if [ "$uncond_tokens" -gt "$THRESHOLD" ]; then
    echo "> ⚠️ 無条件ロード推定 $uncond_tokens tokens は閾値 $THRESHOLD を超過。"
    echo "> 特定状況でしか使わない規約は \`paths:\` の付与か \`.claude/skills/\` への降格を検討(claude-md-hygiene)。"
  else
    echo "> ✅ 無条件ロード推定 $uncond_tokens tokens / 閾値 $THRESHOLD 以内。"
  fi
} > "$REPORT"

echo "Unconditional: $uncond_lines lines, $uncond_bytes bytes, ~$uncond_tokens tokens (threshold $THRESHOLD)."
echo "Path-scoped:   $cond_lines lines, $cond_bytes bytes, ~$cond_tokens tokens (loaded on match only)."
echo "Report: $REPORT"

if [ "$uncond_tokens" -gt "$THRESHOLD" ]; then
  echo "⚠️  Over threshold." >&2
  [ "$STRICT" = true ] && exit 1
fi
exit 0
