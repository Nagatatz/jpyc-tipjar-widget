---
name: retrospective-codify
description: 振り返りや評価で得た学びを skill / agent description / rules に永続化する。「振り返りをまとめて」「この学びを skill に反映」リクエスト時に使用。
allowed-tools: Read, Edit, Write, Glob, Grep
---

# Retrospective Codify スキル

## ねらい

人間が「次回はこうしよう」と頭で思っただけの学びを、Claude Code セッションが自動で参照する
ファイル (skill description / agent description / rule / learnings.md) に変換する。
忘却を防ぎ、知見の摩耗を防ぐ。

## いつ使うか / いつ使わないか

単発の「これを学びとして記録して」程度の気付きは、manual-only の `learn`（`/learn`）に委ねる（learnings.md への1行追記専用）。本 skill は、**複数の学び・評価レポート由来の知見・skill/agent description の改編を伴う**場合に使う。永続化先が `.claude/rules/` の恒久ルールになる場合は `add-rule` の手順に従う。

## ワークフロー

1. **入力を整理**:
   - empirical-prompt-tuning の評価レポート (`quality-reports/*.md`)
   - 個別の retrospective メモ (会話ログ / Slack / 議事録)
   - バグの根本原因とその学び
2. **永続化先を決定** (下表参照)
3. **差分を提示**: 「どのファイルをどう変えるか」を Edit プレビューで提案
4. **適用**: ユーザー承認後に Edit / Write
5. **検証**: `bash scripts/check-references.sh` や CI で broken link / yaml 構文を確認

## 永続化先の判断基準

まず「その学びは git で共有すべきか」を問う。**共有不要（自分の環境・自分の作業手順の話）なら永続化先は Auto memory であり、本 skill の出番はない。** Claude が自動で書き溜めているので何もしなくてよい（→ `docs/memory-and-learning.md`）。

| 学びの性質 | 永続化先 | 例 |
|---|---|---|
| 自分のマシン / 個人の作業手順に閉じた発見 | **Auto memory**（自動、操作不要） | 「手元では uv の PATH 設定が要る」 |
| skill `<対象>` が期待通り発火しなかった | `.claude/skills/<対象>/SKILL.md` の description | 「使う場面に『差分を説明してほしい依頼』を加える」 |
| skill `<対象>` が関係ない場面で発火した | description に「使うべきでない場面」を追記 | 「タイポ修正には使わない」 |
| agent `<対象>` がツールを使い間違えた | `.claude/agents/<対象>.md` の description / system prompt | 「Bash で git push せず、Read/Edit のみ使う」 |
| プロジェクト共通の振る舞い変更 | `add-rule` skill の手順で `.claude/rules/<file>.md` に反映 | git-conventions の更新 |
| チーム全員が踏む個別事象 (再発防止) | `.claude/rules/learnings.md` の追記 | 「このビルドは Node 24 未満だと無言で失敗する」 |
| 特定のファイル種別でしか効かない規約 | `.claude/rules/<file>.md` に `paths:` を付けて追加 | TypeScript だけの命名規約 |
| 評価フロー自体の改善 | `.claude/skills/empirical-prompt-tuning/SKILL.md` | 「データセットは正例 / 反例を半々に」 |

## 永続化フォーマット

`.claude/rules/learnings.md` への追記は、SSoT である `learn` skill の「記録フォーマット」（単一行 `- [YYYY-MM-DD] <説明>: <詳細>`）に従う。`prune-learnings.sh` の行数管理もこの形式を前提とするため、根本原因分析が長くなる場合も learnings.md では1行に要約し、詳細な観測・根本原因・対策は永続化先（rule / description）側に反映する。

description を直すときは frontmatter だけを変える（本文の変更は上の表の別の永続化先として扱う）。
description には、使う場面を意図の種類で書く（発話の例は 1〜2 個で足りる。発火しなかった発話を 1 つずつ足していくと、description が毎回のリクエストで膨らむうえ、似た別の発話には効かない）。

## 関連スキル

- `learn`: 単発の学びを learnings.md に軽量追記する manual-only skill（learnings.md の記法はこちらが SSoT）
- `add-rule`: 学びを恒久的な `.claude/rules/` ルールにする場合の手順（本 skill はルール化をここに委譲）
- `claude-md-hygiene`: `.claude/rules/**` へ書き込む前のプルーニング原則（3つの自問）
- `empirical-prompt-tuning`: 評価フロー本体
- `review-docs`: 永続化先のドキュメント自体の整合性レビュー

## アンチパターン

- Auto memory で足りる個人的な学びを `.claude/rules/` に入れる → チーム全員の常時ロードを太らせるだけで、共有価値は無い
- 永続化先を決めずに learnings.md にすべて流し込む → 個別事象は記録できるが auto-invoke 改善に繋がらない
- description の本文を肥大化させる → frontmatter description は短く保ち、長文は本文に書く
- 「次回気をつける」とだけ書く → Claude が読んでも具体的な行動に繋がらない、対策を**自動化可能な形**で書く

## 参考

- 公式 best-practices「Claude にコンテキストを与える」
- `.claude/rules/code-comments.md` — コメント規約 (本 skill の永続化先候補の 1 つ)
- `docs/quality-measurement.md` — 評価ループ全体像
