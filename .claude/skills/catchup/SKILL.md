---
description: `/clear` や `/compact` の後にセッション状態を復元し、次のアクションを示す（`/catchup`）。
allowed-tools: Read, Glob, Bash
disable-model-invocation: true
---

# Catchup

1. `.claude/session-state.md`（PreCompact フック `.claude/hooks/pre-compact-save.sh` が保存）があれば読む。
2. 最新のステアリングを特定し、`tasklist.md`（進捗）・`requirements.md`・`design.md` を読む:
   ```bash
   ls -d .steering/2*/ 2>/dev/null | sort | tail -1
   ```
3. `git branch --show-current` / `git status --short` / `git log --oneline -5` を確認する。
4. 報告:
   ```markdown
   ## セッション復元サマリー
   **ブランチ:** … / **ステアリング:** … / **進捗:** <完了>/<全> タスク / **直近の変更:** …
   ### 次のアクション
   - <tasklist.md の次の未完了タスク>
   ```
