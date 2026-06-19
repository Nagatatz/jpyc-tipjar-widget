---
name: retrospective-codify
description: 評価セッション・実運用・振り返り (retrospective) で得られた学びを skill description / agent description / .claude/rules/ に永続化する。「振り返りをまとめて」「この学びを skill に反映」「次回に活かす形で記録」「retrospective を codify」リクエストに proactively 使用。empirical-prompt-tuning の評価結果や retrospective での気付きを「次の Claude セッションが自動で参照できる形」に変換する。
allowed-tools: Read, Edit, Write, Glob, Grep
---

# Retrospective Codify スキル

## ねらい

人間が「次回はこうしよう」と頭で思っただけの学びを、Claude Code セッションが自動で参照する
ファイル (skill description / agent description / rule / learnings.md) に変換する。
忘却を防ぎ、知見の摩耗を防ぐ。

## ワークフロー

1. **入力を整理**:
   - empirical-prompt-tuning の評価レポート (`quality-reports/*.md`)
   - 個別の retrospective メモ (会話ログ / Slack / 議事録)
   - バグの根本原因とその学び
2. **永続化先を決定** (下表参照)
3. **差分を提示**: 「どのファイルをどう変えるか」を Edit プレビューで提案
4. **適用**: ユーザー承認後に Edit / Write
5. **検証**: 配布先 (`bash install.sh /tmp/test --force`) や CI で broken link / yaml 構文を確認

## 永続化先の判断基準

| 学びの性質 | 永続化先 | 例 |
|---|---|---|
| skill X が期待通り発火しなかった | `.claude/skills/X/SKILL.md` の description | 「auto-invoke のキーワードに『差分』を追加」 |
| skill X が関係ない場面で発火した | description に「使うべきでない場面」を追記 | 「タイポ修正には使わない」 |
| agent X がツールを使い間違えた | `.claude/agents/X.md` の description / system prompt | 「Bash で git push せず、Read/Edit のみ使う」 |
| プロジェクト共通の振る舞い変更 | 該当する `.claude/rules/<file>.md` | git-conventions の更新 |
| 個別事象の記録 (再発防止) | `.claude/rules/learnings.md` の追記 | 「WSL2 では SSH agent が落ちることがある」 |
| 評価フロー自体の改善 | `.claude/skills/empirical-prompt-tuning/SKILL.md` | 「データセットは正例 / 反例を半々に」 |

## 永続化フォーマット

`.claude/rules/learnings.md` 追記時は以下フォーマット:

```markdown
## YYYY-MM-DD: <学びのタイトル>

**観測**: 何が起きたか
**根本原因**: なぜそうなったか
**対策**: 次回どうするか (Claude が自動で参照できる形)
**永続化先**: <他のファイルにも反映した場合は記載>
```

skill / agent description の編集時は frontmatter のみ変更し、本文は触らない。
description は必ず**ユーザー発話の典型例 + auto-invoke 条件**を含める。

## 関連スキル

- `learn`: 単発の学びを軽量に追記する派生 skill (本 skill のサブセット)
- `empirical-prompt-tuning`: 評価フロー本体
- `review-docs`: 永続化先のドキュメント自体の整合性レビュー

## アンチパターン

- 永続化先を決めずに learnings.md にすべて流し込む → 個別事象は記録できるが auto-invoke 改善に繋がらない
- description の本文を肥大化させる → frontmatter description は短く保ち、長文は本文に書く
- 「次回気をつける」とだけ書く → Claude が読んでも具体的な行動に繋がらない、対策を**自動化可能な形**で書く

## 参考

- 公式 best-practices「Claude にコンテキストを与える」
- `.claude/rules/code-comments.md` — コメント規約 (本 skill の永続化先候補の 1 つ)
- `docs/quality-measurement.md` — 評価ループ全体像
