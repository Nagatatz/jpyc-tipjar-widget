---
description: git worktree を作成・削除・整理する際、または "ENOENT: no such file or directory" / posix_spawn エラーで CWD が壊れた状態の復旧時に参照する。worktree 削除順序の必須規約と Agent ツール経由の復旧手順。
allowed-tools: Read, Bash, Agent
---

# Git Worktree クリーンアップ安全ルール

詳細な worktree マージ・クリーンアップ手順は `.claude/rules/steering-workflow.md` の「worktree マージ・クリーンアップ手順」節を参照。本スキルは**破壊的操作の禁止事項**に特化する。

## 問題

worktree ディレクトリ内で `git worktree remove` や `git branch -D` を実行すると、シェルの cwd が無効になり Claude Code が続行不能になる（`ENOENT: no such file or directory, posix_spawn '/bin/sh'` エラー）。

## 必須手順

worktree を削除する際は、**必ず以下の順序**で実行すること:

1. メインリポジトリのルートに `cd` で戻る
2. `git worktree remove <worktree-path>` で worktree を削除（または `git worktree prune`）
3. `git branch -d <ブランチ名>` で不要なブランチを削除

## Agent tool の `isolation: "worktree"` 使用時

Agent tool で `isolation: "worktree"` を指定した場合、エージェント完了後のクリーンアップ時も本ルールが適用される。worktree 内に cwd がある状態で削除コマンドを実行しないこと。

## 禁止事項

- worktree ディレクトリ内での `git worktree remove` 実行
- worktree ディレクトリ内での `git branch -D` / `git branch -d` 実行
- メインリポジトリに `cd` せずに worktree を削除すること

## CWD が既に壊れている場合

シェルの cwd が削除済みディレクトリを指してしまい、通常の Bash コマンドが一切実行できなくなった場合は、**Agent tool（subagent_type=general-purpose）** を使用して別プロセスからクリーンアップを実行すること。
