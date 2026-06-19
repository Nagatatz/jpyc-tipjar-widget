# ステアリングワークフロー

> **Permission Mode との住み分け**: 軽微な変更（差分を 1 文で説明できる範囲）は Plan Mode で十分。中規模以上で本ワークフローを使う。判断フローの詳細は `.claude/rules/permission-modes.md` を参照。

コードの変更を伴う指示を受けた場合、**コードを1行も書く前に**以下を実行すること:

1. `.steering/[YYYYMMDD]-[NNN]-[開発タイトル]/` ディレクトリを作成する
2. `requirements.md` を作成し、ユーザーの承認を得る
3. `design.md` を作成し、ユーザーの承認を得る
4. `tasklist.md` を作成し、ユーザーの承認を得る
5. 承認された `tasklist.md` に従って実装を進める
6. 実装完了後、ビルドが通ることを確認し、適切な粒度でコミットする
7. 実装完了後、**完了定義** (`definition-of-done.md`) の全項目を満たしていることを確認する
8. コミット完了後、ユーザーに main へのマージ可否を確認し、承認後はマージからクリーンアップまで一括で実行する

## 実装完了後のマージ確認

worktree での実装が完了しコミットした後、以下のフローを実行すること:

1. **マージ確認**: `AskUserQuestion` でユーザーに main へのマージ可否を確認する。選択肢の 1 つ目に「main にマージ (Recommended)」を配置する
2. **マージ承認時**: ユーザーが承認したら、後述の「worktree マージ・クリーンアップ手順」に従い、マージからブランチ削除まで一括で実行する。途中で停止せず、すべてのクリーンアップステップを完了させること
3. **マージ拒否時**: ユーザーの指示に従う（追加修正、レビュー待ち等）

## tasklist.md 更新ルール

tasklist.md の更新タイミングとルールは `definition-of-done.md` の Phase 2・Phase 3・Phase 4 を参照すること。

## 必ず守ること

- コード変更前にステアリングファイルを作成すること
- 新しい作業には新しい `.steering/` ディレクトリを作成すること（既存ドキュメントの使い回しではなく）

**例外:** タイポ修正、1行の設定変更など明らかに軽微な修正はステアリングを省略してよい。

## 調査・リサーチタスク

コード変更を伴わない調査でもステアリングドキュメントを作成しコミットすること。`main` に直接コミット可。コミットメッセージは `📝 Add <調査内容>` とする。

## git worktree 運用

ステアリングを伴うコード実装は **Claude Code のビルトイン worktree 機能**で隔離して行うこと。メインリポジトリではステアリングドキュメントの作成・承認のみ行う。

- **単一機能:** `EnterWorktree` ツール（または `claude --worktree <機能名>`）を使用する。worktree は `.claude/worktrees/<機能名>/` に作成され、ブランチ `worktree-<機能名>` が HEAD から自動生成される。セッション終了時に自動クリーンアップされる（変更ありの場合は確認プロンプト）。
- **並列実装:** 各ウィンドウで `claude --worktree <機能名>` を使用する。バッチブランチ戦略の詳細手順は `/steering` スキルを参照。
- **手動 worktree は使わない:** `git worktree add ../<project>-wt-*` による手動作成は非推奨。ビルトイン機能を使うこと。

### セッション開始時の worktree 健全性チェック

新しいセッションを開始した際、worktree を使用する前に以下の健全性チェックを実行すること:

```bash
# 1. 孤立した worktree 参照を検出・削除
git worktree list
git worktree prune

# 2. 残存する worktree ブランチを確認
git branch --list 'worktree-*'

# 3. .claude/worktrees/ 内の孤立ディレクトリを確認
ls .claude/worktrees/ 2>/dev/null
```

**異常が検出された場合（以下のいずれか）:**
- `git worktree list` に存在しないパスが表示される
- `git worktree prune` で参照が削除される
- `.claude/worktrees/` に `git worktree list` に登録されていないディレクトリがある
- `worktree-*` ブランチが存在するが対応する worktree が無い

**復旧手順:**
1. `git worktree prune` で孤立参照を削除
2. `.claude/worktrees/` 内の孤立ディレクトリを `rm -rf` で削除
3. 対応する worktree が無い `worktree-*` ブランチを `git branch -D` で削除
4. `git worktree list` で main のみ表示されることを確認

**CWD が壊れている場合（Bash コマンドがすべて失敗する場合）:**
`worktree-safety` skill の「CWD が既に壊れている場合」を参照（Agent ツール経由でのクリーンアップ手順）。

### worktree マージ・クリーンアップ手順

worktree での実装完了後、マージとクリーンアップは**必ず以下の順序**で行うこと。順序を守らないとシェルの CWD が存在しないディレクトリを指し、以降のすべての Bash コマンドが実行不能になる。

#### 手順

**最重要: CWD の移動が最優先。`git -C` での代用は禁止。**

worktree ディレクトリを削除すると、そのディレクトリを CWD としているシェルは**復旧不能**になる（`cd` を含む全コマンドが `posix_spawn` レベルで失敗する）。そのため、**worktree を削除・prune する前に必ず CWD をメインリポジトリに移動すること**。

1. **CWD をメインリポジトリに変更する**（単独の Bash 呼び出しで `cd` を実行）
2. **ステアリングファイルの競合を事前に解消する**: メインリポジトリに未追跡の `.steering/` ファイルが残っている場合、マージ前に削除する
3. **マージする**（CWD 変更後の別の Bash 呼び出しとして実行）
4. **worktree を削除する**: `git worktree remove <パス>` または `git worktree prune`
5. **ブランチを削除する**: `git branch -d <ブランチ名>`（リモート未 push の場合は `-D`）

```bash
# Step 1: CWD をメインリポジトリに変更（必ず最初に実行）
# ⚠️ git -C で代用してはならない。CWD 自体を移動すること。
cd /path/to/main-repo

# Step 2: 未追跡ステアリングファイルの削除（存在する場合）
rm -rf .steering/<作業ディレクトリ>/

# Step 3: マージ（CWD 変更後の別コマンドとして実行）
git merge <ブランチ名> --no-ff -m "Merge branch '<ブランチ名>'"

# Step 4: worktree クリーンアップ（CWD がメインリポジトリであることを確認済み）
git worktree remove .claude/worktrees/<名前>  # または git worktree prune
git branch -d <ブランチ名>
```

#### クリーンアップ完了の検証

マージ・クリーンアップ後、以下をすべて確認すること。1つでも残っていればクリーンアップ未完了:

```bash
# worktree が main のみであること
git worktree list
# → main のみ表示されること

# worktree ブランチが残っていないこと
git branch --list 'worktree-*'
# → 出力が空であること

# .claude/worktrees/ が空であること
ls .claude/worktrees/ 2>/dev/null
# → 出力が空またはディレクトリ不在であること
```

#### CWD が壊れた場合の復旧

シェルの CWD が存在しないディレクトリを指してしまった場合、通常の Bash コマンドは一切実行できない。詳細な復旧手順は `worktree-safety` skill の「CWD が既に壊れている場合」を参照。

### セッション終了前の worktree チェック

worktree を使用したセッションでは、**セッション終了前（ユーザーへの最終応答前）に**以下のチェックを必ず実行すること。自動クリーンアップに依存すると、CWD が削除済みディレクトリを指して `ENOENT: no such file or directory, posix_spawn '/bin/sh'` エラーが発生し、セッション再起動が必要になる。

#### 原則

- worktree の自動クリーンアップ（セッション終了時）に**頼らない**
- マージ・クリーンアップは**セッション中に手動で完了**させる
- セッション終了時点で CWD が**メインリポジトリを指している**ことを保証する

#### チェック手順

セッション終了前に以下を順に確認すること:

```bash
# 1. CWD がメインリポジトリであることを確認
pwd
# → プロジェクトルートであること
# → worktree パス（.claude/worktrees/...）を指していたら即座に cd で移動する

# 2. 未マージの worktree が残っていないことを確認
git worktree list
# → main のみ表示されること

# 3. worktree ブランチが残っていないことを確認
git branch --list 'worktree-*'
# → 出力が空であること
```

#### CWD が worktree 内にある場合

セッション終了前に CWD が worktree ディレクトリ内にあることが判明した場合:

1. **まず CWD をメインリポジトリに移動する**（これが最優先）
   ```bash
   cd /path/to/main-repo
   ```
2. マージが未完了なら「worktree マージ・クリーンアップ手順」に従って完了させる
3. マージ済みなら worktree とブランチを削除する
4. セッション終了は**すべてのクリーンアップが完了してから**行う

#### worktree が未コミット変更を含む場合

マージせずにセッションを終了する必要がある場合（作業中断等）:

1. worktree 内で変更をコミットする（WIP コミットでよい）
2. CWD をメインリポジトリに移動する
3. worktree は削除**しない**（次回セッションで作業を継続するため）
4. ユーザーに worktree とブランチ名を伝え、次回セッションでの継続方法を案内する

## アーカイブポリシー

`.steering/` 直下はアクティブな作業のみを置き、完了した古い作業は `.steering/archive/` に退避する。長期運用プロジェクトで `.steering/` 直下が肥大化するのを防ぐ。

### アーカイブ判定基準

- **最終コミット日が 30 日以上前**のディレクトリを `.steering/archive/` に移動する
- ディレクトリ名の日付ではなく、**最終コミット日**で判断すること（長期継続作業を誤って archive しないため）

### 判定コマンド

```bash
for d in .steering/*/; do
  name=$(basename "$d")
  [ "$name" = "archive" ] && continue
  last=$(git log -1 --format="%ad" --date=short -- "$d")
  echo "$last  $name"
done | sort
```

### 移動手順

```bash
mkdir -p .steering/archive
git mv ".steering/<対象ディレクトリ>" ".steering/archive/"
git commit -m "📝 完了ステアリングを archive に移動: <対象>"
```

### 運用タイミング

- **月初に必ず実行する:** `/archive-steering` で棚卸しを起動し、30 日以上前のディレクトリを移動する。月初を逃した場合は気付いた時点で実行
- **新規作業着手時:** `.steering/` 配下が肥大していると感じたら追加棚卸し
- **CLAUDE.md や `docs/` から `.steering/` を参照している箇所** があれば、必要に応じてリンクを `.steering/archive/` に更新する
- **判定の自動化:** 「[判定コマンド](#判定コマンド)」を実行すれば対象ディレクトリ一覧が表示される。`archive-steering` skill が自動でこれを呼ぶ
