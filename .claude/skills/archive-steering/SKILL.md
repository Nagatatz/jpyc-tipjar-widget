---
description: 最終コミットが 30 日以上前の `.steering/` ディレクトリを `.steering/archive/` に移す月次棚卸し（`/archive-steering`）。
disable-model-invocation: true
allowed-tools: Read, Bash
---

# Archive Steering

判定基準は `.claude/rules/steering-workflow.md` の「アーカイブ判定基準」と同じ。判定はディレクトリ名の日付ではなく **最終コミット日** で行う（長期作業を誤って移さないため）。

## 現在の一覧（最終コミット日・名前）

!`for d in .steering/*/; do name=$(basename "$d"); [ "$name" = "archive" ] && continue; last=$(git log -1 --format="%ad" --date=short -- "$d" 2>/dev/null); [ -n "$last" ] && echo "$last  $name"; done | sort 2>/dev/null`

## 手順

1. 候補を抽出する（`archive/` は除外）:
   ```bash
   cutoff=$(date -d "30 days ago" +%Y-%m-%d)   # macOS: date -v-30d +%Y-%m-%d
   for d in .steering/*/; do
     name=$(basename "$d"); [ "$name" = "archive" ] && continue
     last=$(git log -1 --format="%ad" --date=short -- "$d")
     [ -n "$last" ] && [[ "$last" < "$cutoff" ]] && echo "$last  $name"
   done
   ```
2. 候補を AskUserQuestion で提示し、承認を得る。**承認されたものだけ**移す。
3. 移動してコミットする:
   ```bash
   mkdir -p .steering/archive
   git mv ".steering/<ディレクトリ>" ".steering/archive/"
   git commit -m "📝 Archive completed steering: <ディレクトリ>"
   ```
4. CLAUDE.md や `docs/` が移したディレクトリを参照していれば、リンクを `.steering/archive/` に直す。
