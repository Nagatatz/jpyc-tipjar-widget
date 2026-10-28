# GitHub のネイティブ stack 機能と `gh stack` 拡張（任意）

SKILL.md の手順は plain git + gh だけで完結する。ここでは、リポジトリが GitHub の stacked PR 機能を採用している場合や、`gh stack` 拡張を使いたい場合の差分をまとめる。どちらも public preview の機能（2026-09 時点の記述）なので、挙動は `gh stack <command> --help` と GitHub のドキュメントで確認する。

## GitHub のネイティブ stack

親子関係にある PR を GitHub 上で「stack」としてまとめる機能。Web では 2 つ目の PR を開くときに **Create stack** を選ぶか、正しく鎖になった PR に表示されるバナーから stack 化する。

plain な親子 PR との違い:

- マージは下から連続した範囲をまとめて行い、中段だけを単独でマージできない。マージ後は次の PR が自動で rebase され、trunk を base に付け替わる
- branch protection（必須レビュー・必須チェック・CODEOWNERS）は各段が stack の base（通常 `main`）を対象にしているものとして評価される。上の段でも `main` 向けの `pull_request` ワークフローが走る
- 履歴が線形であることがマージ条件になる。下の段へ push したり trunk が進んだりしたら rebase して push し直す（マージボックスの **Rebase stack** でも可。ただしサーバー側 rebase のコミットは署名されないので、署名必須のリポジトリではローカルで rebase する）
- stack 内の PR では auto-merge が使えない。`gh pr merge` や同期マージ API では stack をマージできないので、`gh stack merge` か Web のマージボタンを使う
- 同一リポジトリ・一直線の stack のみ対応

### CI で stack の位置を判定する

stack に属する PR では `github.event.pull_request.stack` にメタデータが入り、それ以外では `null` になる。通常の PR を壊さないよう、読む前に `!= null` でガードする。

| 式 | 内容 |
| --- | --- |
| `...stack.size` / `...stack.position` | stack 内の PR 数 / この PR の位置（1 が最下段） |
| `...stack.base.ref` | stack 全体が最終的に対象とするブランチ |

段の数だけ CI が走るので、重いジョブは位置で絞ると節約できる。

```yaml
# 現在の最下段（stack の base を直接対象にしている PR）だけ
if: github.event.pull_request.stack != null && github.event.pull_request.stack.base.ref == github.event.pull_request.base.ref
# 最上段（変更全体を含む PR）だけ
if: github.event.pull_request.stack != null && github.event.pull_request.stack.position == github.event.pull_request.stack.size
```

`stack.position == 1` は当初の最下段を指し、その PR がマージされると一致しなくなる。「そのときの最下段」には `base.ref` の比較を使う。

## `gh stack` 拡張

```bash
gh extension install github/gh-stack    # GitHub CLI 2.90.0 以上
```

plain git の操作との対応:

| やりたいこと | plain git + gh | gh stack |
| --- | --- | --- |
| stack を始める / 取り込む | `git switch -c` | `gh stack init <branch>...` |
| 段を追加する | 最上段から `git switch -c` | 最上段で `gh stack add <branch>` |
| push と PR 作成 | `git push -u` + `gh pr create --base` | `gh stack submit --auto` |
| 下の段の修正を波及 | `git rebase --update-refs` | `gh stack rebase --upstack` |
| 複数ブランチの push | `git push --force-with-lease ...` | `gh stack push`（内部で `--force-with-lease`） |
| マージ後の同期 | fetch + `--onto` rebase + 付け替え | `gh stack sync --prune` |
| 状態の確認 | `gh pr list --json ...` | `gh stack view --json` |

エージェントから使うときの注意:

- TTY を前提にした画面を避けるため、引数とフラグを明示する: `view --json`、`submit --auto`、`init <branch>`、`add <branch>`、`merge <target> --yes`。`gh stack modify` と `gh stack switch` は TTY 専用なので使わない
- `gh stack add -Am` はすべての変更を stage する（`git add -A` 相当）。コミットは `git add <file>` と `git commit` で作り、`gh stack add <branch>` はブランチ作成だけに使う
- `submit --auto` は新規 PR を draft で作る。ready にするには `--open` を付ける。既存 PR のタイトル・本文は `gh pr edit` で直す
- `submit` と `push` はブランチ単位で順に push するので途中で止まることがある。原因を直して同じコマンドを再実行すれば、済んだ分は飛ばされる
- 非インタラクティブな `gh stack sync` は、ローカルとリモートの stack が乖離していると何も変更せずに終了コード 0 で終わる。成功と判断する前に `gh stack view --json` で確認する
- 主な終了コード: `2` stack 外、`3` rebase コンフリクト（解決して `gh stack rebase --continue`）、`5` 引数不正、`7` rebase 進行中、`9` リポジトリで stacked PR が無効

Jujutsu や git-town などでブランチを管理している場合は、`gh stack link <branch>...`（下から上の順）でローカルの追跡情報なしに GitHub 上の stack だけを作れる。
