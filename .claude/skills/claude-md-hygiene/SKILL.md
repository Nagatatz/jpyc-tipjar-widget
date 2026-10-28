---
description: AGENTS.md / `.claude/rules/` を編集する、ルールを追加・整理する、常時ロードされる規約の肥大化を見直すときに参照する。プルーニング原則（3つの自問）、置き場所の判定、AGENTS.md 索引の扱い、肥大化検知。
allowed-tools: Read, Grep, Glob
paths:
  - "AGENTS.md"
  - "AGENTS.md.template"
  - ".claude/rules/**"
---

# 常時ロード規約の健全性

> 出典: [Best practices for Claude Code（Anthropic 公式）](https://code.claude.com/docs/en/best-practices)
>
> 公式警告: 「Bloated CLAUDE.md files cause Claude to **ignore** your actual instructions」「If Claude keeps doing something you don't want despite having a rule against it, the file is probably too long and the rule is getting lost.」

`AGENTS.md` と `paths:` の無い `.claude/rules/` は **毎セッションでロードされる固定オーバーヘッド** であり、肥大化すると逆効果になる。本スキルは「短く保つ」規律の Single Source of Truth。何がいつロードされるかは `docs/rule-loading.md`。

## プルーニング原則

新しい行・新しいルールを追加するときは、以下を自問する:

1. **この行が無くても Claude は間違えないか？** 間違えないなら削除する
2. **既存コードを読めば Claude が推測できる内容か？** 推測できるなら削除する
3. **特定状況でしか使わない知識か？** Yes なら `.claude/skills/` に分離する（auto-invoke）

3 つすべて No の場合のみ、`.claude/rules/` に追加してよい。

## 含めるもの / 除外するもの

| ✅ 含める | ❌ 除外する |
|----------|------------|
| Claude が推測できないビルド・テストコマンド | コードを読めば分かること |
| デフォルトと異なるコードスタイル規則 | 標準的な言語慣習（Claude は既に知っている） |
| テスト方針と推奨テストランナー | 詳細な API ドキュメント（リンクで参照） |
| リポジトリ運用規約（ブランチ命名、PR 規約） | 頻繁に変わる情報 |
| プロジェクト固有のアーキテクチャ判断 | 長文の解説・チュートリアル |
| 開発環境の癖（必須環境変数等） | ファイルごとのコードベース記述 |
| 非自明な落とし穴・既知の地雷 | 「クリーンなコードを書け」のような自明な訓示 |

## 分離先の選び方

「毎セッションで必要か / 特定状況だけか」を、さらに「どの状況か」で分ける:

| 必要になる場面 | 置き場所 |
|--------------|---------|
| 毎セッション | `.claude/rules/<topic>.md`（frontmatter 無し） |
| 特定のファイル種別を触るとき | `.claude/rules/<topic>.md` に `paths:` を付ける |
| 特定の作業をするとき | `.claude/skills/` に skill 化、description で auto-invoke |

例: 「破壊的 Bash 操作前の安全規約」は破壊操作時のみ → `bash-safety` skill。「コードコメント規約」はソース編集時のみ → `code-comments.md` に `paths:`。「Git コミット規約」はいつでも起きる → `git-conventions.md`（frontmatter 無し）。

**`@import` は使わない。** `.claude/rules/*.md` は `@import` 無しで自動ロードされる。`@import` を書くと frontmatter に関係なく起動時に展開されるため `paths:` が無効化され、自動ロードとの二重ロードになる。

## 本文は rules、索引だけ AGENTS.md

規約本文の単一ソースは `.claude/rules/*.md`。`AGENTS.md` にはプロジェクト概要・コマンドと Required Rules 索引だけを置き、ルール本文を写さない（写すと常時ロードが二重になる）。新規ルールファイルを足したときだけ索引に 1 行足す。

ルールの背景や長い手順が必要になったら、本文には規則だけを残し、詳細を `docs/rule-details/<ルール名>.md` に移してルール末尾から 1 行で参照する。

## 過剰追加検知

以下のいずれかが観測されたら肥大化の可能性が高い:

- Claude がルールに反する挙動を繰り返す（規則が他のテキストに埋もれている）
- Claude が AGENTS.md や rules に既に答えがある質問をユーザーに投げる
- セッション開始時のコンテキスト使用率が常に 30% を超えている

対応:
1. 既存ルールを「3 つの自問」で再評価し、削れる行を削る
2. 特定状況用の知識は skill に移動する
3. `scripts/measure-context-cost.sh` で常時ロード量（AGENTS.md + `paths:` の無いルール）を変更前後で比べ、`empirical-prompt-tuning` skill で description / 本文の効果を検証する。既存会話には変更前の規約が残るため、新しいセッションで確かめる
4. `/doctor` を実行する。公式の checkup が常時ロードファイルから「コードベースから導出できる内容（ディレクトリ構成 / 依存一覧 / アーキテクチャ概説）」を削り、「落とし穴・根拠・既定と異なる規約」を残す trim 案を提示する

## 関連

- `.claude/skills/learn/`、`.claude/skills/add-rule/`、`.claude/skills/retrospective-codify/`: `.claude/rules/**` へ書き込む 3 skill。いずれも書込前に本スキルのプルーニング原則（3つの自問）を確認する対象
- `.claude/skills/permission-modes/`: Plan Mode / Issue + DoD の住み分け
- `.claude/skills/empirical-prompt-tuning/`: description / system prompt の実測ベース改善
- `.claude/skills/context-management/`: コンテキスト圧迫時の運用
- `scripts/measure-context-cost.sh`: 常時ロード規約のトークンコスト計測
