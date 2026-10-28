---
description: `/clear` や `/compact` 後にセッション状態を復元するスキル。`/catchup` で起動。「キャッチアップして」「セッション状態を復元して」「直前の作業を思い出して」「どこまでやったか教えて」リクエスト時にも本スキルを案内する。
allowed-tools: Read, Glob, Bash
disable-model-invocation: true
---

# Catchup スキル

`/clear` や `/compact` 後にセッション状態を復元し、作業の継続に必要なコンテキストを再構築します。

## 手順

### 1. セッション状態の読み込み

以下のファイルを Read で読み込む（存在しない場合はスキップ）:

- `.claude/session-state.md` — PreCompact フックが保存した最新状態

### 2. 作業中の Issue の特定

作業中の Issue を、次の順で探す（見つかった時点で止める）:

1. `.claude/session-state.md` やブランチ名・直近のコミットに出てくる Issue 番号
2. 現在のブランチの PR が参照する Issue: `gh pr view --json closingIssuesReferences -q '.closingIssuesReferences[].number'`
3. 自分に割り当てられた open の Issue: `gh issue list --assignee @me`

見つかった Issue を `gh issue view <番号> --comments` で読み、背景・方針・DoD（`[ ]` / `[x]` の状態）・途中経過のコメントを把握する。特定できなければユーザーに番号を聞く。

### 3. Git 状態の確認

以下の Bash コマンドで現在の作業状態を確認する:

- `git branch --show-current` — 現在のブランチ
- `git status --short` — 変更ファイル一覧
- `git log --oneline -5` — 直近5コミット

### 4. サマリーの出力

以下の形式でユーザーに報告する:

```
## セッション復元サマリー

**ブランチ:** <現在のブランチ>
**Issue:** <作業中の Issue 番号とタイトル>
**進捗:** DoD <完了項目数>/<全項目数> 完了
**直近の変更:** <変更ファイルリスト>

### 次のアクション
- <DoD の次の未完了の項目>
```
