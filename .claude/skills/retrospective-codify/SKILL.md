---
name: retrospective-codify
description: 評価・実運用・振り返りで得た学びを skill / agent の description や `.claude/rules/` に永続化する。「振り返りをまとめて」「この学びを skill に反映」「次回に活かす形で記録」で使用。
allowed-tools: Read, Edit, Write, Glob, Grep
---

# Retrospective Codify

学びを、次のセッションが自動で読むファイルに変える。単発の学びだけなら `learn` skill。

## 手順

1. 入力を集める: `quality-reports/*.md`（`empirical-prompt-tuning` の結果）、振り返りメモ、バグの根本原因。
2. 永続化先を選ぶ:

   | 学びの性質 | 永続化先 |
   |---|---|
   | skill が発火しない / 関係ない場面で発火する | `.claude/skills/<名前>/SKILL.md` の description（典型発話を足す / 使わない場面を書く） |
   | agent がツールを誤用した | `.claude/agents/<名前>.md` の description / 本文 |
   | プロジェクト共通の振る舞い | 該当する `.claude/rules/<file>.md` |
   | 個別事象の再発防止 | `.claude/rules/learnings.md` |
   | 評価フロー自体の改善 | `.claude/skills/empirical-prompt-tuning/SKILL.md` |

3. 変更差分を提示し、ユーザー承認後に Edit / Write する。
4. `bash scripts/check-references.sh`（`@import` の解決と `.claude/` 内パス参照の実在を確認）を実行し、frontmatter の YAML 構文も確かめる。

## 書き方

- 対策は「気をつける」ではなく、Claude がそのまま実行できる行動で書く。
- description は短く、典型的なユーザー発話と発火条件を含める。長い説明は本文へ。
- learnings.md への追記は `learn` skill の 1 行形式 `- [YYYY-MM-DD] <説明>: <詳細>` に従う（`scripts/prune-learnings.sh` はこの形式の行を月ごとに退避する）。観測・根本原因・対策・永続化先は <詳細> に詰める。
