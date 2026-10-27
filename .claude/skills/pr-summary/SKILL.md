---
description: 現在のブランチまたは指定 PR の差分を 300 字以内の tl;dr に要約する。「PR を要約して」「差分を要約」で使用。
context: fork
agent: Explore
allowed-tools: Bash(gh *), Bash(git diff*), Bash(git log*)
---

# PR Summary

- ブランチ: !`git branch --show-current 2>/dev/null`
- 直近 5 コミット: !`git log --oneline -5 2>/dev/null`
- master との差分ファイル: !`git diff master --name-only 2>/dev/null | head -20`
- 差分サイズ: !`git diff master --stat 2>/dev/null | tail -1`
- PR 番号: !`gh pr view --json number -q .number 2>/dev/null || echo "(no PR yet)"`

上の情報から、300 字以内で次を書く。変更行数・ファイル数は冒頭に置き、推測は「〜と思われる」と明示する。

1. 変更の目的（PR タイトル / コミットから推定）
2. 主要な変更点（3〜5 個）
3. 影響範囲（触ったモジュール・ファイルの傾向）
4. テスト状況（テストを含むか、既存テストへの影響）
5. レビューの注意点（大きい diff / セキュリティ / マイグレーション / breaking change）
