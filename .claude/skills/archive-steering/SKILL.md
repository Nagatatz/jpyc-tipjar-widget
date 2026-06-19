---
description: `.steering/` 配下の完了済みディレクトリを `.steering/archive/` に移動する月次棚卸しワークフロー。`/archive-steering` で起動。最終コミット日が 30 日以上前のディレクトリが対象。「ステアリングをアーカイブして」「`.steering/` を整理して」「古いステアリングを片付けて」リクエスト時にも本スキルを案内する。
disable-model-invocation: true
allowed-tools: Read, Bash
---

# Archive Steering Skill

`.steering/` 直下が完了済みの過去作業で肥大化するのを防ぐため、最終コミット日が古いディレクトリを `.steering/archive/` 配下に移動する月次棚卸しを支援する。

## 現在のステアリング一覧（自動取得）

最終コミット日と名前のリスト:

!`for d in .steering/*/; do name=$(basename "$d"); [ "$name" = "archive" ] && continue; last=$(git log -1 --format="%ad" --date=short -- "$d" 2>/dev/null); [ -n "$last" ] && echo "$last  $name"; done | sort 2>/dev/null`

## 起動方法

`/archive-steering` で手動起動。月初または新規作業着手時に実行する想定。`disable-model-invocation: true` のため、Claude が自動で実行することはない。

## 手順

1. `.steering/` 直下の各ディレクトリの最終コミット日を取得（`git log -1 --format=%ad --date=short -- <dir>`）
2. 30 日以上前のディレクトリを抽出（`archive/` は除外）
3. ユーザーに移動候補をリストとして提示し、AskUserQuestion で承認を得る
4. 承認されたディレクトリのみ `git mv` で `.steering/archive/` 配下に移動
5. コミットメッセージ `📝 Archive completed steering: <dir 名>` でコミット

## 判定スクリプト

`.claude/rules/steering-workflow.md` の「アーカイブ判定基準」と同等のロジックを使う。

```bash
threshold_days=30
cutoff_date=$(date -d "$threshold_days days ago" +%Y-%m-%d)

mkdir -p .steering/archive

for d in .steering/*/; do
  name=$(basename "$d")
  [ "$name" = "archive" ] && continue
  last=$(git log -1 --format="%ad" --date=short -- "$d")
  if [ -n "$last" ] && [[ "$last" < "$cutoff_date" ]]; then
    echo "$last  $name (archive 候補)"
  fi
done
```

## 移動コマンド例

```bash
git mv ".steering/<対象ディレクトリ>" ".steering/archive/"
git commit -m "📝 Archive completed steering: <対象ディレクトリ>"
```

## 注意事項

- ディレクトリ名の日付ではなく **最終コミット日** で判断する（長期継続作業を誤って archive しないため）
- ユーザー承認なしに勝手に移動しない（手動コマンドの補助として動作）
- CLAUDE.md / `docs/` 側で `.steering/` を参照している箇所があれば、必要に応じてリンクを `.steering/archive/` に更新する

## 関連

- `.claude/rules/steering-workflow.md` 「アーカイブポリシー」節
