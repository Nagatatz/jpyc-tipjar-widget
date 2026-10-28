---
description: セッション中に得た知見のうち **チームで共有すべきもの** を `.claude/rules/learnings.md` に記録するスキル。`/learn` で起動。「これを学びとして記録して」「チームに共有したい」「learnings に追加して」リクエスト時に使用。個人的・環境固有の学びは公式 Auto memory が自動で拾うため対象外（→ `docs/memory-and-learning.md`）。
allowed-tools: Read, Write, Edit, Glob
disable-model-invocation: true
---

# Learn スキル

セッション中に得た知見のうち、**チームで共有する価値があるもの**を `.claude/rules/learnings.md` に永続化するスキルです。`/learn` で明示的に呼び出してください。

## まず Auto memory との住み分けを判断する

Claude Code の Auto memory は既定で有効で、ビルドコマンド・デバッグ知見・環境の癖といった学びを **Claude が自動的に** `~/.claude/projects/<project>/memory/` へ書き溜めている。`/learn` はその代替ではない。

| 問い | Yes なら |
|------|---------|
| これは自分のマシン / 自分の作業環境だけの話か？ | **何もしない**。Auto memory が拾う（`/memory` で確認できる） |
| チームの他のメンバーにも同じ判断をしてほしいか？ | `/learn` で `learnings.md` に記録する |
| すでに恒久的な規約と言える水準か？ | `/add-rule` で独立したルールにする |

決め手は **git で共有されるか**。Auto memory はマシンローカルで共有されない。逆に個人的な気付きを `learnings.md` に入れると、チーム全員の常時ロードを太らせる。詳細は `docs/memory-and-learning.md`。

## 保存先

`.claude/rules/learnings.md` に記録する。`.claude/rules/` 配下のファイルは `@import` を書かなくても Claude Code が自動ロードするため、AGENTS.md への追記は不要。

## 記録対象

チーム共有価値があることを確認したうえで、以下のカテゴリに該当する知見を抽出する:

| カテゴリ | 例 |
|---------|-----|
| ワークアラウンド | 「ライブラリXのバグにより、△△の回避策が必要」 |
| プロジェクト固有パターン | 「このプロジェクトでは○○パターンを使う」 |
| 誰の環境でも踏む地雷 | 「このビルドは Node 24 未満だと無言で失敗する」 |
| 設計判断の背景 | 「○○を採用しなかったのは△△の制約があるため」 |

## 記録しないもの

- **Auto memory が既に拾っている個人的・機械的な発見**（自分のマシン固有の設定、個人の作業手順、単発のデバッグ経緯）
- 一般的なプログラミング知識（言語仕様、標準ライブラリの使い方）
- 一時的な問題（ネットワーク障害、一時的なAPI停止）
- 既にルールファイルに記載済みの情報

## 実行手順

1. **知見の抽出**: 現在のセッションの会話履歴を振り返り、上記カテゴリに該当する非自明な発見を特定する
2. **重複チェック**: `.claude/rules/learnings.md` を読み込み（存在する場合）、既に記載済みでないことを確認する
3. **記録**: `.claude/rules/learnings.md` に追記する（ファイルがなければ作成する）
4. **確認**: 追記した内容をユーザーに提示し、確認を得る

## 記録フォーマット

`.claude/rules/learnings.md` に以下の形式で記録する:

```markdown
# プロジェクト固有の知見（Learnings）

- [YYYY-MM-DD] <簡潔な説明>: <詳細な知見>
```

## ライフサイクル（成長制御）

`learnings.md` は `.claude/rules/` 配下にあり**毎セッション自動ロードされる固定オーバーヘッド**になりうる。`claude-md-hygiene` skill の肥大化警告に従い、無制限に成長させない。記録時は以下を守る:

- **重複・統合**: 追記前に既存エントリを読み、同義のものがあれば新規追加せず統合する（日付だけ更新）。
- **サイズ上限**: 既定 **400 行**。超過したら剪定する（下記）。
- **昇格（promote）**: 同種の知見が 3 件以上たまった、または恒常的な規約に育った項目は、`learnings.md` から抜き出して `.claude/rules/` の独立ルール（または該当 skill）に昇格させ、元エントリは削除する。一過性メモと恒久規約を混在させない。
- **剪定（prune）**: 古い・参照されない月のエントリは `scripts/prune-learnings.sh` で `.claude/learnings-archive/YYYY-MM.md` に退避する（`.claude/rules/` の外なので常時ロードから外れる）。

```bash
bash scripts/prune-learnings.sh            # 上限超過時のみ古い月を archive
bash scripts/prune-learnings.sh --dry-run  # 退避対象の確認のみ
```

## 使用タイミング

- チームの他メンバーも踏むであろう罠を発見した後
- 新しいワークアラウンドを発見し、それが環境非依存だと確認できた後
- ユーザーから「チームに共有して」「learnings に追加して」と指示された場合

「覚えておいて」だけの指示は Auto memory の領分なので、本スキルを呼ばずに Claude が自動保存すればよい。

複数の学びのまとめ、評価レポート由来の知見、skill / agent の description 改編を伴う場合は `retrospective-codify` を使う（本 skill は learnings.md への単発1行記録専用で、その記法の SSoT）。恒久的な規約として `.claude/rules/` に定着させたい場合は `add-rule` を使う。
