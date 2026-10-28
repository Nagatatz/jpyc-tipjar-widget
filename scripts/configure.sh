#!/bin/sh
# pztn:260619 対話式セットアップウィザード。
#   AGENTS.md と sphinx-docs の {{PLACEHOLDER}} を対話入力で一括置換し、
#   任意で sphinx html_baseurl を設定、任意機能を有効化する。
#   install.sh --configure からも起動される。
#   pztn:260619 sphinx-docs プレースホルダ対応を追加（従来はエントリファイルのみ）。
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

# sed 置換用に値をエスケープ（区切り / 用に & / \ を保護）
esc_repl() { printf '%s' "$1" | sed -e 's/[&/\\]/\\&/g'; }

# ファイル内の {{KEY}} を値で置換
replace_in_file() {  # replace_in_file <file> <key> <value>
  _r="$(esc_repl "$3")"
  sed "s/{{$2}}/$_r/g" "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

# プレースホルダ置換の対象ファイル集合（存在するもののみ）。
# AGENTS.md / AGENTS.md.template と sphinx-docs の *.py/*.toml/*.md
# （_build / .venv / locale は除外）。
collect_target_files() {
  if [ -f AGENTS.md ]; then echo AGENTS.md; fi
  if [ -f AGENTS.md.template ]; then echo AGENTS.md.template; fi
  if [ -d sphinx-docs ]; then
    find sphinx-docs \( -path '*/_build' -o -path '*/.venv' -o -path '*/locale' \) -prune -o \
      \( -name '*.py' -o -name '*.toml' -o -name '*.md' \) -type f -print
  fi
  return 0
}

echo "=== Claude Project Template Configure ==="

# --- 1. プロジェクト全体のプレースホルダ置換（AGENTS.md + sphinx-docs） ---
TARGET_FILES="$(collect_target_files)"
if [ -n "$TARGET_FILES" ]; then
  # ファイル名に空白を含まない前提で word-split して走査する
  # shellcheck disable=SC2086
  PLACEHOLDERS="$(grep -hoE '\{\{[A-Z_]+\}\}' $TARGET_FILES 2>/dev/null | sort -u || true)"
  if [ -n "$PLACEHOLDERS" ]; then
    echo ""
    echo "プレースホルダを設定します（空入力でスキップ。AGENTS.md と sphinx-docs に共通反映）:"
    for ph in $PLACEHOLDERS; do
      key="$(printf '%s' "$ph" | sed -e 's/^{{//' -e 's/}}$//')"
      val="$(ask "  $key =")"
      if [ -n "$val" ]; then
        for f in $TARGET_FILES; do
          if grep -q "{{$key}}" "$f" 2>/dev/null; then replace_in_file "$f" "$key" "$val"; fi
        done
        echo "    set $key"
      fi
    done
  else
    echo "未設定のプレースホルダはありません。"
  fi
else
  echo "AGENTS.md / sphinx-docs が見つかりません（プレースホルダ置換をスキップ）。"
fi

# --- 2. sphinx html_baseurl（任意。GitHub Pages 公開時のみ設定） ---
if [ -f sphinx-docs/conf.py ]; then
  baseurl="$(ask "  sphinx html_baseurl（GitHub Pages 公開 URL 例 https://user.github.io/repo/en/、空でローカル）=")"
  if [ -n "$baseurl" ]; then
    bre="$(printf '%s' "$baseurl" | sed -e 's/[&|\\]/\\&/g')"
    sed "s|^html_baseurl = \"\"|html_baseurl = \"$bre\"|" sphinx-docs/conf.py > sphinx-docs/conf.py.tmp \
      && mv sphinx-docs/conf.py.tmp sphinx-docs/conf.py
    echo "    set html_baseurl"
  fi
fi

# --- 3. 任意機能の有効化 ---
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
