---
name: stacked-prs
description: 依存する複数の PR を積み重ねて（stacked PR）作成・更新・マージするときに `/stacked-prs` で使う。下の段の修正や squash merge 後の追従も扱う。
allowed-tools: Read, Bash, Grep, Glob
disable-model-invocation: true
---

# Stacked PR

stack は、依存関係が一直線に連なった 2 つ以上の PR。最下段は trunk（通常 `main`）を base にし、上の段は 1 つ下の段のブランチを base にする。

```text
  ┌── feature/billing-ui      → PR C (base: feature/billing-api)
 ┌── feature/billing-api      → PR B (base: feature/billing-schema)
┌── feature/billing-schema    → PR A (base: main)
main
```

各 PR にはその段の差分だけが表示されるので、レビューが小さな単位で進み、下の段のマージを待たずに上の作業を続けられる。

## いつ stack にするか

- 変更が「schema → API → UI」のように段階的に依存し、1 PR では大きすぎてレビューしづらいとき
- 下の段をレビュー待ちにしたまま、その上の作業を進めたいとき

互いに独立した変更は `main` から別々に PR を作るほうが単純で、rebase の連鎖も起きない。stack は枝分かれしない一直線で扱い、全ブランチを同じリポジトリに置く（fork のブランチは base に指定できないため）。

ある段が依存するコードは、同じ段かそれより下の段に置く。段の区切りをコードを書く前に決めておくと、あとで 1 本のブランチを分割する手間がかからない。

## セットアップ

```bash
git --version                        # 2.38 以上（--update-refs に必要）
git config rerere.enabled true       # 一度解決したコンフリクトを以降の rebase で自動再生する
```

下の段の変更は上の全段に再生されるので、同じコンフリクトが段ごとに現れやすい。`rerere` があれば 2 回目以降は自動で解決される。

## stack を作る

ブランチ名は git-workflow skill の命名規則に従い、stack 内で共通の接頭辞をつけて段を見分けやすくする。ファイルは個別に stage する。

```bash
git switch -c feature/billing-schema main
git add db/schema.sql && git commit -m "✨ Add billing schema"

git switch -c feature/billing-api    # 1 つ下の段から分岐する
git add src/api/billing.ts && git commit -m "✨ Add billing API endpoints"
```

push と PR 作成はユーザーの指示を受けてから、下の段から順に行う。上の段は `--base` に 1 つ下のブランチを指定する。

```bash
git push -u origin feature/billing-schema
gh pr create --base main --head feature/billing-schema --title "..." --body "..."
git push -u origin feature/billing-api
gh pr create --base feature/billing-schema --head feature/billing-api --draft --title "..." --body "..."
```

- 上の段を draft にしておくと、下より先にマージされにくい
- PR 本文に stack の一覧（例: `#101 ← #102（この PR）← #103`）を書くと、レビュアーが順序を把握できる
- 現状の確認: `gh pr list --author @me --json number,headRefName,baseRefName`
- 段を足すときは最上段から `git switch -c` で分岐し、最上段のブランチを `--base` にする

## stack を更新する

### 下の段を修正する

レビュー指摘は、その変更が属する段で直して上へ波及させる。上の段で回避すると、下の段の PR が誤ったままマージされるため。

```bash
git switch feature/billing-schema
git add db/schema.sql && git commit -m "🐛 Fix billing amount precision"

git switch feature/billing-ui                        # 最上段へ
git rebase --update-refs feature/billing-schema
git push --force-with-lease origin feature/billing-schema feature/billing-api feature/billing-ui
```

`--update-refs` は rebase 範囲の途中にあるブランチ（ここでは `feature/billing-api`）も書き換え後のコミットへ付け替える。修正を新しいコミットとして積むと、レビュアーは前回からの差分だけを確認できる。どの段がファイルを持つか分からないときは `git log --oneline main..HEAD -- <path>` で探す。

### trunk の更新を取り込む

```bash
git fetch origin
git switch feature/billing-ui
git rebase --update-refs origin/main
git push --force-with-lease origin feature/billing-schema feature/billing-api feature/billing-ui
```

rebase 後の push は `--force-with-lease` を使う。リモートに自分の知らない更新があれば拒否されるので、他者の push を上書きせずに済む（`--force` は validate-bash hook がブロックする）。途中のブランチで拒否されたら原因を直して同じコマンドを再実行する。

## マージする

下の段から順にマージする。上の段を先にマージすると、変更は下の段のブランチに入るだけで `main` に届かないため。

1. 最下段の PR をマージする（`gh pr merge <番号>`、方法はリポジトリの設定に従う）
2. 次の段の base を `main` に付け替える: `gh pr edit <番号> --base main`
   - マージ時にブランチが自動削除された場合、GitHub がそれを base にしていた PR を自動で付け替える。`gh pr view <番号> --json baseRefName` で確認する
3. squash merge / rebase merge なら、次の段を `--onto` で rebase し直す（下記）。merge commit なら元のコミットが `main` に残るので付け替えだけでよい
4. 次の段を `gh pr ready <番号>` で ready にし、最上段まで繰り返す

### squash merge 後の re-rebase

squash すると `main` には新しい 1 コミットが入り、上の段には元のコミットが残る。そのまま rebase すると同じ変更が二重に当たりコンフリクトしやすいので、マージ前の下の段の先端を境界にして、それより上のコミットだけを移す。

```bash
git fetch origin
old_base=$(git rev-parse feature/billing-schema)    # マージ前の先端（ローカルに残っているもの）
git switch feature/billing-ui
git rebase --update-refs --onto origin/main "$old_base"
git push --force-with-lease origin feature/billing-schema feature/billing-api feature/billing-ui
```

ローカルブランチを消した後なら、`gh pr view <下の段の番号> --json headRefOid` でマージ前の先端 SHA を取得できる。

## 関連

- `git-workflow` skill: ブランチ命名、コミット、単一 PR の作成、push の扱い
- `.claude/rules/git-conventions.md`: 絵文字プレフィックス付きコミットメッセージ、1 コミット 1 論理変更
- [references/troubleshooting.md](references/troubleshooting.md): コンフリクト、base ブランチ削除で閉じた PR、段の並べ替え、CI が走らない
- [references/tools.md](references/tools.md): GitHub のネイティブ stack 機能と `gh stack` 拡張（任意）
