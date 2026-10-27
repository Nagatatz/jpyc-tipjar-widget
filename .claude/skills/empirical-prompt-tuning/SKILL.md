---
name: empirical-prompt-tuning
description: skill / agent の description や system prompt が狙いどおり auto-invoke・完遂するかを、テストデータセットで実測して改善する。「skill の品質を測りたい」「agent をチューニングしたい」「auto-invoke が効いているか確認したい」「description リライトの効果を検証したい」で使用。
allowed-tools: Read, Bash, Glob, Grep
---

# Empirical Prompt Tuning

推測ではなく実測で description を改善する（Evaluator-Optimizer ループ）。運用全体は `docs/quality-measurement.md`。

## ループ

1. 対象を 1 つに絞る（例: `code-reviewer` agent）。
2. `quality-datasets/<対象>.yaml` を 10〜20 件作る。発火すべき prompt とすべきでない prompt を半々に。書式は `quality-datasets/_TEMPLATE.yaml`。
3. 測定する（`claude` CLI と `ANTHROPIC_API_KEY` が必要。API 課金が発生するので実行前にユーザーに確認する）:
   ```bash
   bash scripts/evaluate-skills.sh quality-datasets/<対象>.yaml   # → quality-reports/<YYYY-MM-DD>-<対象>.md
   ```
4. レポートは人間が判定する。目標: auto-invoke 一致率 80% 以上、タスク完遂率 90% 以上、トークン消費はベースライン比 -20%（usage が取れる場合）。
5. 症状に合わせて直す: 発火しない → description 冒頭に典型発話 / 誤発火 → 使わない場面を明記 / 脱線 → 手順を箇条書きに分解 / ツール過多 → `allowed-tools` を絞る。
6. 再測定し、改善幅 5% 未満になったら終了。学びは `retrospective-codify` skill で永続化する。

週次の自動測定は `.github/workflows/quality-measurement.yml.template` を有効化する（API コストがかかるので opt-in）。
