# Stacked PR のトラブルシューティング

例のブランチ名は SKILL.md と同じ（`feature/billing-schema` ← `feature/billing-api` ← `feature/billing-ui`）。

## rebase がコンフリクトで止まった

`git status` でコンフリクトしたファイルを確認し、マーカー（`<<<<<<<` / `=======` / `>>>>>>>`）を解消してから、ファイルを個別に stage して続行する。

```bash
git add src/api/billing.ts
git rebase --continue
```

やり直したいときは `git rebase --abort` で rebase 前の状態に戻る。`--update-refs` による途中ブランチの付け替えは rebase の最後にまとめて行われるので、abort すれば途中ブランチも元のままになる。

`rerere.enabled` を有効にしていれば、ここで行った解決は次に同じコンフリクトが出たとき自動で再生される。自動再生された内容は `git diff` で確認してから stage する。

## `--force-with-lease` の push が拒否された

`stale info` などで拒否されるのは、最後に fetch してから誰かがそのブランチへ push したため。上書きせずに取り込む。

```bash
git fetch origin
git log --oneline feature/billing-api..origin/feature/billing-api   # 相手の追加コミットを確認
```

相手のコミットを自分のブランチに取り込み（cherry-pick や rebase）、上の段へ `git rebase --update-refs` で波及させてから、同じ push を再実行する。

## 途中の段のブランチが更新されない

原因は次のいずれか。

- `--update-refs` を付け忘れた、または Git が 2.38 未満。`git config rebase.updateRefs true` にしておくと付け忘れを防げる
- そのブランチが別の worktree で checkout されている。Git は他の worktree で checkout 中のブランチを書き換えないので、rebase の前にその worktree で別ブランチへ切り替える

付け忘れた後で直すには、最上段で `git log --oneline main..HEAD` を見て途中の段の最後のコミットを特定し、`git branch -f feature/billing-api <そのコミット>` で付け替える（そのブランチを checkout していない状態で実行する）。

## base ブランチが削除されて子の PR が閉じた

GitHub の「マージ後にブランチを自動削除」で消えた場合は、子の PR の base が自動で付け替わる。それ以外の方法（`git push origin --delete` や、マージせずに削除など）で base ブランチを消すと、それを base にしていた PR はクローズされ、base が存在しない間は reopen できない。

base ブランチを一時的に復元し、PR を開き直してから付け替える。

```bash
sha=$(gh pr view <下の段の番号> --json headRefOid --jq .headRefOid)
git push origin "$sha":refs/heads/feature/billing-schema
gh pr reopen <子の番号>
gh pr edit <子の番号> --base main
git push origin --delete feature/billing-schema     # 付け替え後に改めて削除する
```

下の段が squash merge 済みなら、続けて SKILL.md の「squash merge 後の re-rebase」を行う。予防策として、base ブランチを手で消す前に子の PR を `gh pr edit --base` で付け替えておく。

## 上の段の PR に下の段の差分まで表示される

付け替えや re-rebase が済んでいないときに起きる。

- base がまだマージ済みの下の段を指している → `gh pr edit <番号> --base main`
- base は `main` だが squash 前の元コミットが残っている → `--onto` で re-rebase する

## squash merge 後に通常の rebase をしてしまった

コンフリクトの途中なら `git rebase --abort` で戻り、`--onto` でやり直す。rebase を完了してしまった場合は、`git reflog feature/billing-ui` で rebase 前の位置を探して `git reset --keep <その位置>` で戻してから `--onto` で rebase する。push 前ならリモートには影響しない。

## 上の段を先にマージしてしまった

上の段の変更は下の段のブランチに入っただけで、`main` には届いていない。下の段の PR には両方の変更が含まれるようになるので、そのまま下の段をレビューしてマージすれば `main` に入る。分けたい場合は、下の段のブランチで取り込みを取り消し（マージコミットなら `git revert -m 1 <マージコミット>`、squash merge で入ったなら通常の `git revert <コミット>`）、上の段の変更を新しい PR として出し直す。

## 段を並べ替える

stack の構造を変えるには、コミットの祖先関係そのものを書き換える。`main ← models ← migration ← ui` を `main ← migration ← models ← ui` にする例:

```bash
old_models=$(git rev-parse models)
old_migration=$(git rev-parse migration)
git rebase --onto main "$old_models" migration     # migration だけのコミットを main の上へ
git rebase --onto migration main models            # models のコミットをその上へ
git rebase --onto models "$old_migration" ui       # ui だけのコミットを models の上へ
git push --force-with-lease origin migration models ui
gh pr edit <migration の PR> --base main
gh pr edit <models の PR> --base migration
gh pr edit <ui の PR> --base models
```

各段のコミットがどこから始まっていたかの記録は古い SHA しかないので、ブランチを動かす前に控えておく。別の並べ替えでは、`git log <旧親>..<ブランチ>` で各段の範囲を確認し、下から順に再生する。

## 上の段の PR で CI が走らない

`pull_request` ワークフローに `branches: [main]` のようなフィルタがあると、`main` 以外を base にする上の段の PR では実行されない。付け替え後に `main` を base にした時点で走るので、それで足りるならそのままでよい。早い段階で検証したい場合は、フィルタに stack 用ブランチのパターン（例: `feature/**`）を加える。branch protection も PR の直接の base ブランチに対して評価されるため、上の段は `main` に付け替わってから必須チェックの対象になる。GitHub のネイティブ stack 機能では扱いが異なる（[tools.md](tools.md) 参照）。
