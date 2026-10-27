---
description: Bash で破壊的操作（rm / rmdir / rm -r / git worktree remove などのディレクトリ削除、リダイレクトによるファイル上書き）を実行する直前に必ず参照する。CWD が削除対象内にないか確認する。
allowed-tools: Read, Bash
---

# Bash 安全規約

ディレクトリを削除（`rmdir` / `rm -r` / `git worktree remove` など）する前に、**CWD が削除対象（サブディレクトリを含む）の中にないことを必ず確認する**。

1. 削除対象のパスを確かめる。
2. `pwd` で CWD を確かめる。
3. CWD が削除対象内なら、**先に `cd` で外へ移動してから**削除する。
4. CWD が対象外であることを確認してから削除コマンドを実行する。

CWD が消えると Bash ツールのシェルは復旧できない（`cd` を含む全コマンドが `posix_spawn` で失敗する）。復旧手順は `worktree-safety` skill。

**`git -C <path>` は CWD 移動の代わりにならない。** git の実行ディレクトリを変えるだけでシェルの CWD は動かないので、`git -C` で worktree remove / prune をしても CWD が対象内ならシェルは壊れる。必ず `cd` で移動する。
