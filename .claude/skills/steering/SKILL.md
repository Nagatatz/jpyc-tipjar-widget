---
description: ステアリングワークフロー（requirements / design / tasklist の作成、worktree 隔離実装、振り返り）。コード変更を伴う指示を受けたとき、または `.steering/` を参照する作業で必ず使用。`/steering plan|implement|review` で明示起動も可。
allowed-tools: Read, Write, Edit, Glob, Bash
---

# Steering

いつ使うか・承認の取り方は `.claude/rules/steering-workflow.md`、完了条件は `.claude/rules/definition-of-done.md`。本 skill は手順を持つ。

## 動的コンテキスト

- ブランチ: !`git branch --show-current 2>/dev/null`
- 最新ステアリング: !`ls -d .steering/2*/ 2>/dev/null | sort | tail -1`
- 変更ファイル: !`git status --short 2>/dev/null | head -10`
- 直近コミット: !`git log --oneline -3 2>/dev/null`

## 使い方

```text
/steering [plan] [<機能名>]          # モード1（引数なしもこれ）
/steering implement [<ディレクトリ>]  # モード2。省略時は最新の .steering/*/
/steering review [<ディレクトリ>]     # モード3
```

## モード1: 計画

1. `.steering/<YYYYMMDD>-<NNN>-<機能名>/` を作る。NNN はその日付の既存ディレクトリ（`archive/` 内を含む）の最大連番 + 1、無ければ `001`。機能名が無ければユーザーに聞く。
2. 方針を読む（存在するものだけ）: `CLAUDE.md`、`sphinx-docs/dev/architecture.md`・`sphinx-docs/dev/project-structure.md`、`docs/` の設計書（あれば）。
3. `templates/requirements.md`・`design.md`・`tasklist.md` を読み、`{{機能名}}`・`{{日付}}`（YYYY-MM-DD）と各節を具体的に埋めて同名で保存する。
4. tasklist.md をフェーズごとの具体タスク・サブタスク・実装順・依存注記まで詳細化する。

## モード2: 実装

開始時に tasklist.md・requirements.md・design.md を読む。全タスクが `[x]` になるまで繰り返す:

1. tasklist.md を読み、次の `[ ]` を選ぶ
2. 着手時にそのタスクだけ Edit で `[x]` にする（まとめて更新しない）
3. 実装する。必要ならメモを追記
4. 追加タスクが判明したら、該当フェーズに理由付きで追記

**完遂**: 「時間の都合」「別タスクで実施」などでスキップしない。`[ ]` を残して終えない。

全タスク完了後のコミット:

```bash
pnpm build                  # 型チェックを兼ねる。通ることを確認してから
git add <ファイル>...         # 個別指定。`git add .` / `git add -A` は使わない
```

粒度と絵文字は `.claude/rules/git-conventions.md`。**push はユーザーの明示指示があるまでしない。**

## モード3: 振り返り

1. tasklist.md に `[ ]` が残っていれば報告し、モード2に戻るかユーザーに確認する。
2. 末尾の「振り返り」節に記録: 工夫した点 / 発生した問題と解決策 / 設計変更の理由 / 次回への改善点。
3. 設計が変わったら、永続ドキュメント（`.claude/rules/documentation.md` の対応表。日英両方）の更新をユーザーに提案する。

## worktree（単一機能）

1. デフォルトブランチ（`master`）上でステアリングを作成・承認する。
2. `EnterWorktree`（または `claude --worktree <機能名>`）で `.claude/worktrees/<機能名>/`・ブランチ `worktree-<機能名>` を作る。
   - ブランチは HEAD から作られる（`.claude/rules/steering-workflow.md`）。手動の `git worktree add` は使わない。
3. worktree 内で実装・ビルド確認・コミットする。
4. マージ（`--no-ff`）とクリーンアップは `.claude/rules/steering-workflow.md` の「worktree マージ・クリーンアップ手順」に、削除の順序は `worktree-safety` skill に従う。

## 参照

- 複数機能を並列実装する → [references/parallel.md](references/parallel.md)
