#!/bin/sh
# pztn:260619 対話式セットアップウィザード。
#   CLAUDE.md の {{PLACEHOLDER}} を対話入力で置換し、任意機能を有効化する。
#   install.sh --configure からも起動される。
#   TTY 非接続(CI 等)では何も変更せず安全に終了する。
# Usage: scripts/configure.sh [TARGET_DIR]   (既定: カレントディレクトリ)
set -eu

TARGET="${1:-.}"
cd "$TARGET"

if [ ! -t 0 ]; then
  echo "configure.sh: 非対話(no TTY)のため設定をスキップしました。"
  echo "  対話的に実行: bash scripts/configure.sh"
  exit 0
fi

ask() {  # ask "<質問>" -> 回答を stdout（空入力可）
  printf '%s ' "$1" >&2
  read -r REPLY || REPLY=""
  printf '%s' "$REPLY"
}

ask_yn() {  # ask_yn "<質問>" -> 0(yes)/1(no)。既定 No
  printf '%s [y/N] ' "$1" >&2
  read -r ans || ans=""
  case "$ans" in [yY]*) return 0 ;; *) return 1 ;; esac
}

# sed 置換用に値をエスケープ（& / \ を保護）
esc_repl() { printf '%s' "$1" | sed -e 's/[&/\\]/\\&/g'; }

echo "=== Claude Project Template Configure ==="

# --- 1. CLAUDE.md のプレースホルダ置換 ---
CLAUDE_FILE=""
if [ -f CLAUDE.md ]; then CLAUDE_FILE="CLAUDE.md"
elif [ -f CLAUDE.md.template ]; then CLAUDE_FILE="CLAUDE.md.template"
fi

if [ -n "$CLAUDE_FILE" ]; then
  PLACEHOLDERS="$(grep -oE '\{\{[A-Z_]+\}\}' "$CLAUDE_FILE" 2>/dev/null | sort -u || true)"
  if [ -n "$PLACEHOLDERS" ]; then
    echo ""
    echo "$CLAUDE_FILE のプレースホルダを設定します（空入力でスキップ）:"
    for ph in $PLACEHOLDERS; do
      key="$(printf '%s' "$ph" | sed -e 's/^{{//' -e 's/}}$//')"
      val="$(ask "  $key =")"
      if [ -n "$val" ]; then
        repl="$(esc_repl "$val")"
        sed "s/{{$key}}/$repl/g" "$CLAUDE_FILE" > "$CLAUDE_FILE.tmp" && mv "$CLAUDE_FILE.tmp" "$CLAUDE_FILE"
        echo "    set $key"
      fi
    done
  else
    echo "$CLAUDE_FILE に未設定のプレースホルダはありません。"
  fi
else
  echo "CLAUDE.md / CLAUDE.md.template が見つかりません（スキップ）。"
fi

# --- 2. 任意機能の有効化 ---
echo ""
echo "任意機能の有効化:"

if [ -f .claude/settings.json.template ] && [ ! -f .claude/settings.json ]; then
  if ask_yn "  hooks/permissions を有効化（settings.json.template を settings.json にコピー）?"; then
    cp .claude/settings.json.template .claude/settings.json
    echo "    + .claude/settings.json"
  fi
fi

if [ -f .mcp.json.template ] && [ ! -f .mcp.json ]; then
  if ask_yn "  MCP サーバー設定を生成（.mcp.json.template を .mcp.json にコピー）?"; then
    cp .mcp.json.template .mcp.json
    echo "    + .mcp.json（編集して使用してください）"
  fi
fi

for tpl in .github/workflows/*.yml.template; do
  [ -f "$tpl" ] || continue
  active="${tpl%.template}"
  [ -f "$active" ] && continue
  base="$(basename "$active")"
  if ask_yn "  GitHub Actions '$base' を有効化?"; then
    cp "$tpl" "$active"
    echo "    + $active"
  fi
done

echo ""
echo "Done. 設定内容を確認し、必要に応じて手動で調整してください。"
