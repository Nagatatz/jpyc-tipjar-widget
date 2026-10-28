---
description: Git ワークフロー（DoD 付き Issue の作成と更新 / ブランチ作成 / 絵文字プレフィックス付きコミット / PR 作成 / 状態確認）を自動化するスキル。「Issue 作って」「DoD を書いて」「DoD を更新して」「コミットして」「ブランチ切って」「PR 作って」のリクエストに proactively 使用。プロジェクトの `git-conventions.md` 規約（絵文字 9 種、ブランチ命名）に準拠。
allowed-tools: Bash, Read, Glob, Grep
---

# Git ワークフロー

AGENTS.md の Git コミット規約と `definition-of-done.md` に準拠した Issue の作成、ブランチ作成、コミット、PR 作成を支援するスキル。

## 現在の状態（自動取得）

- ブランチ: !`git branch --show-current 2>/dev/null`
- 状態: !`git status --short 2>/dev/null | head -10`
- 直近 3 コミット: !`git log --oneline -3 2>/dev/null`
- リモート差分: !`git status -sb 2>/dev/null | head -1`

## 使い方

- `/git-workflow issue <タイトル>` — DoD 付きの Issue を作成する
- `/git-workflow issue check <番号>` — 満たした DoD の項目を `[x]` に更新する
- `/git-workflow branch <名前>` — 命名規則に従うブランチを作成
- `/git-workflow commit` — 変更内容を分析し、絵文字付きコミットメッセージを生成・実行
- `/git-workflow commit -m "メッセージ"` — メッセージ指定 + 絵文字自動付与
- `/git-workflow pr` — `gh pr create` でプルリクエストを作成
- `/git-workflow status` — ブランチ状態 + コミット規約リマインダーを表示

引数なしの `/git-workflow` は `status` として動作する。

---

## モード: issue

### 目的

作業の完了条件（DoD）を Issue の本文に置く（→ `definition-of-done.md`）。DoD は会話ではなく Issue に残すので、`/clear` の後や別の agent に引き継いだ後も同じ完了条件で進められる。

### Issue 本文のフォーマット

```markdown
## 背景
- なぜこの作業が要るか

## 方針
- 採るアプローチ。解釈の幅があれば仮定とトレードオフ

## DoD
- [ ] <確かめられる完了条件>（検証: `<コマンド>`）
- [ ] テスト: <追加・更新するテスト>
- [ ] ドキュメント: <更新するファイル>（無ければ「影響なし」と書く）

## 対象外
- やらないこと
```

DoD の各項目は、テストやコマンドの結果で満たしたか判定できる形にする（→ `testing.md`）。

### 手順

1. 既存の Issue があるか確認する: `gh issue list --search "<キーワード>"`
2. 無ければ上のフォーマットで本文を作り、ユーザーに DoD の承認を得る
3. 作成する:

```bash
gh issue create --title "<タイトル>" --body-file <本文のファイル>
```

4. 既存の Issue に DoD が無ければ、本文に `## DoD` 節を追記して承認を得る（手順は次の check と同じ）

### check: DoD の更新

満たした項目を `[x]` にする。範囲が増えたら項目を追記する。本文は丸ごと置き換わるので、取得 → 編集 → 書き戻しの順に行う。

```bash
f=$(mktemp)
gh issue view <番号> --json body -q .body > "$f"
# "$f" の該当行を `- [x]` に編集する
gh issue edit <番号> --body-file "$f"
rm -f "$f"
```

- 満たしたか確かめていない項目は `[x]` にしない
- 未完了の項目を残して作業を止めるときは、何が残っているかを Issue にコメントする

---

## モード: branch

### 目的

命名規則に従ったブランチを作成する。

### ブランチ命名規則

| プレフィックス | 用途 | 例 |
|--------------|------|-----|
| `feature/` | 新機能追加 | `feature/12-amount-presets` |
| `fix/` | バグ修正 | `fix/15-qr-fallback` |
| `refactor/` | リファクタリング | `refactor/18-payment-uri` |
| `docs/` | ドキュメント更新 | `docs/20-sphinx-quickstart` |
| `test/` | テスト追加・修正 | `test/22-tip-amount` |
| `chore/` | 設定・依存関係等 | `chore/3-issue-workflow` |

プレフィックスの後に Issue 番号を付ける（`<prefix>/<Issue 番号>-<題>`）。

### 手順

1. 引数からブランチ名を取得する
2. プレフィックスが含まれていない場合、ユーザーに確認する
3. 現在のブランチ状態を確認する:

```bash
git status
git branch --show-current
```

4. 未コミットの変更がある場合はユーザーに警告する
5. ブランチを作成・チェックアウトする:

```bash
git checkout -b <ブランチ名> origin/master
```

---

## モード: commit

### 目的

変更内容を分析し、AGENTS.md の絵文字規約に従ったコミットメッセージでコミットする。

### 絵文字判定ルール

変更ファイルの差分内容から絵文字を自動判定する:

| 絵文字 | 判定条件 | 用途 |
|-------|---------|------|
| ✨ | 新しいファイル追加、または既存ファイルに新しい関数/コンポーネント/エンドポイントを追加 | 新機能追加 |
| 🐛 | 条件分岐の修正、例外処理の追加、既存ロジックの修正 | バグ修正 |
| ♻️ | 関数の抽出・統合、名前変更、構造変更（機能変更なし） | リファクタリング |
| 📝 | `.md` ファイルのみの変更、またはコメントのみの追加・修正 | ドキュメント更新 |
| 🎨 | スタイル変更、CSS/レイアウト関連の変更 | UIやスタイルの改善 |
| ⚡ | クエリ最適化、キャッシュ追加、アルゴリズム改善 | パフォーマンス改善 |
| 🔧 | 設定ファイルの変更 | 設定ファイルの変更 |
| ✅ | テストファイルの追加・修正 | テスト追加・修正 |
| 🗑️ | ファイル削除、不要コードの除去（コード量が純減） | 不要コード削除 |

**判定優先順位**: 複数の絵文字が該当する場合、上の表の優先順位に従う（✨ が最優先）。

### 手順

#### 1. 変更内容の確認

```bash
git status
git diff
git diff --cached
```

#### 2. ステージング

個別ファイル指定で `git add` する（`git add .` / `-A` は秘密情報やビルド成果物を巻き込むため、validate-bash hook もブロックする）。

変更ファイルを分析し、以下を除外する:
- `.env` / `credentials.json` 等の秘密情報ファイル
- `node_modules/` / `bin/` / `obj/` / `dist/` / `build/` 等のビルド成果物

```bash
git add src/path/to/changed/file.ext
```

#### 3. コミットメッセージ生成

`-m` オプションでメッセージが指定されている場合:
- 指定メッセージに絵文字を自動付与する（既に絵文字がある場合は付与しない）
- 例: `-m "Add user authentication"` → `✨ Add user authentication`

メッセージが指定されていない場合:
- 差分内容を分析し、英語でコミットメッセージを生成する
- フォーマット: `<絵文字> <動詞で始まる簡潔な説明>`

#### 4. コミット実行

```bash
git commit -m "$(cat <<'EOF'
✨ Add user authentication

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

帰属行は、ハーネスが提示するもの（モデル名入り）があればそれを使う。

#### 5. push に関するルール

`git push` はユーザーの明示的な指示があるときだけ実行する（push は外部に公開される操作で取り消しにくいため）。

コミット完了後、push が必要かどうかをユーザーに確認するメッセージを表示する。

---

## モード: pr

### 目的

`gh` CLI を使用してプルリクエストを作成する。

### 手順

#### 1. 現在の状態確認

```bash
git branch --show-current
git log --oneline origin/HEAD..HEAD
git diff origin/HEAD...HEAD --stat
```

#### 2. Issue の DoD の確認

対応する Issue の DoD が全項目 `[x]` か確認する（`gh issue view <番号>`）。未完了の項目があれば、PR を作る前にユーザーに伝える。

#### 3. PR タイトルの生成

- コミット履歴を分析し、変更の主目的を特定する
- 70文字以内のタイトルを生成する
- 絵文字は PR タイトルには含めない

#### 4. PR 本文の生成

以下のフォーマットで PR 本文を作成する:

```markdown
## Summary
- 変更の概要（1〜3行）

## Changes
- 変更されたファイルとその内容

Closes #<Issue 番号>

## Test plan
- [ ] ビルドが成功すること
- [ ] テストが全件パスすること
- [ ] 手動テスト: （具体的なテスト項目）

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

#### 5. リモートへの push

PR 作成前にリモートへ push する（ユーザーに確認後）:

```bash
git push -u origin <ブランチ名>
```

#### 6. PR 作成

```bash
gh pr create --title "タイトル" --body "$(cat <<'EOF'
本文
EOF
)"
```

作成された PR の URL を表示する。

---

## モード: status

### 目的

現在のブランチ状態とコミット規約のリマインダーを表示する。

### 手順

#### 1. 状態表示

以下のコマンドを実行し、結果を整形して表示する:

```bash
git branch --show-current
git status --short
git log --oneline -5
git stash list
```

#### 2. レポート

```
## Git 状態

**ブランチ**: feature/add-feature
**未コミット変更**: 3ファイル
**最新コミット**: ✨ Add new feature (2分前)

### 最近のコミット
1. ✨ Add new feature
2. 🐛 Fix parsing error
3. ♻️ Refactor repository pattern

### 未コミット変更
- M  src/path/to/file.ext
- M  config/settings.json
- ?? src/path/to/new_file.ext

### コミット規約リマインダー
| 絵文字 | 用途 |
|-------|------|
| ✨ | 新機能追加 |
| 🐛 | バグ修正 |
| ♻️ | リファクタリング |
| 📝 | ドキュメント更新 |
| 🎨 | UIやスタイルの改善 |
| ⚡ | パフォーマンス改善 |
| 🔧 | 設定ファイルの変更 |
| ✅ | テスト追加・修正 |
| 🗑️ | 不要コード削除 |
```
