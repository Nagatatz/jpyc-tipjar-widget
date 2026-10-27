---
description: git worktree を作成・削除・整理するとき、または "ENOENT: no such file or directory" / posix_spawn エラーで CWD が壊れたときの復旧に使用。worktree 削除順序の必須規約と、Agent ツールでの復旧手順。
allowed-tools: Read, Bash, Agent
---

# Git Worktree クリーンアップ安全ルール

マージからクリーンアップまでの全手順と完了検証は `.claude/rules/steering-workflow.md` の「worktree マージ・クリーンアップ手順」節にある。本 skill は**破壊的操作の禁止事項**に絞る。

worktree 内を CWD にしたまま `git worktree remove` / `git branch -d|-D` を実行すると、シェルの CWD が消えて Bash が `ENOENT ... posix_spawn '/bin/sh'` で失敗し、続行できなくなる。

## 必須の順序

1. メインリポジトリのルートへ `cd` する（単独の Bash 呼び出しで。`git -C` は CWD を動かさないので代用にならない）
2. `git worktree remove <worktree のパス>`（または `git worktree prune`）
3. `git branch -d <ブランチ名>`

Agent ツールの `isolation: "worktree"` で作った worktree を、エージェント完了後に片付けるときも同じ順序を守る。

## 禁止

- worktree 内での `git worktree remove`
- worktree 内での `git branch -d` / `git branch -D`
- メインリポジトリへ `cd` せずに worktree を削除すること

## CWD が既に壊れている場合

通常の Bash は何も実行できない。**Agent tool（`subagent_type=general-purpose`）** で別プロセスからクリーンアップする。
