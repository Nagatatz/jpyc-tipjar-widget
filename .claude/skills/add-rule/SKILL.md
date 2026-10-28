---
description: 会話の文脈からルールを抽出し `.claude/rules/` に永続化する。配置先（常時 / `paths:` / skill）の判定と AGENTS.md 索引の更新まで行う。「ルール化してください」「ルールに追加して」「AGENTS.md に書いて」リクエストで `/add-rule` として起動する。
allowed-tools: Read, Write, Edit, Glob, Bash
disable-model-invocation: true
---

# add-rule スキル

会話の直前の文脈からルール化すべき内容を取り出し、`.claude/rules/` に追加する。

## 0. 先にプルーニング原則を通す

`claude-md-hygiene` skill の「3 つの自問」を通す。3 つすべて No のときだけルール化する。No にならなかったら、ここで止めてその理由をユーザーに伝える（skill 化や `learn` での記録を提案する）。

## 1. 置き場所を決める

| 必要になる場面 | 置き場所 |
|---|---|
| 毎セッション | `.claude/rules/<topic>.md`（frontmatter 無し） |
| 特定のファイル種別を触るとき | `.claude/rules/<topic>.md` に `paths:` を付ける |
| 特定の作業をするとき | `.claude/skills/` に skill 化 |

`ls .claude/rules/` で既存ファイルを確認し、追記できるなら新規ファイルを作らない。ファイルが増えるほど索引が読まれなくなる。新規ファイル名はケバブケースで内容を端的に表す（例: `naming-conventions.md`）。

## 2. 書く

- 新規ファイルは `# <タイトル>` から始め、既存ルールのスタイル（日本語、平叙文、肯定形）に合わせる
- なぜそうするのか（Why）を 1 句添える。理由の無い禁止は、想定外の場面で守られない
- 迷いやすい場面があれば NG / OK の短い例を置く
- 条件ロードにする場合:

```markdown
---
paths:
  - "src/**/*.ts"
---
```

## 3. 索引を更新する

新規ファイルを作った場合だけ、`AGENTS.md` の Required Rules 索引に 1 行足す（ロード条件と 1 行の内容）。本文は `.claude/rules/` にだけ置く。既存ファイルへの追記なら索引はそのままでよい。

## 4. 機械検査に落とせないか検討する

文章のルールより、lint・hook・テストのほうが確実に守られる。linter のルール、`.claude/hooks/` の PreToolUse hook、ast-grep ルールなどで検出できるなら、ルール本文と合わせて提案する（→ `retrospective-codify` skill）。

## 5. 確認を取る

- 追加・変更する内容をユーザーに提示し、承認後に保存する
- 既存ルールと矛盾する場合は、黙って上書きせず、どちらを採るかを確認する
- 保存後、`bash scripts/check-references.sh` で参照切れが無いことを確かめる

## 関連スキル

- `claude-md-hygiene`: プルーニング原則と置き場所判定の SSoT
- `retrospective-codify`: 振り返り由来の学びのルーター。恒久ルール化は本 skill に委譲される
- `learn`: 恒久ルールでなく単発の記録に留める場合（`.claude/rules/learnings.md` への 1 行追記）
