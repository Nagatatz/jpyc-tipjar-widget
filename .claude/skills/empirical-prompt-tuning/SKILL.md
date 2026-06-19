---
name: empirical-prompt-tuning
description: skill / agent の description / system prompt が意図通りの auto-invoke / 完遂率を達成しているか実測ベースで評価する。「skill の品質を測りたい」「agent をチューニングしたい」「auto-invoke が効いているか確認したい」「description リライトの効果を検証したい」リクエストに proactively 使用。テストデータセット (quality-datasets/<対象>.yaml) を入力に取り、評価フローを案内する。
allowed-tools: Read, Bash, Glob, Grep
---

# Empirical Prompt Tuning スキル

## ねらい

本テンプレートが配布する skill / agent の `description` リライトの効果を「実測」で検証する。
推測ではなくテストデータで反復改善する。Anthropic engineering "Building effective agents" の
**Evaluator-Optimizer パターン**を縮小実装したもの。

## ワークフロー

1. **対象を 1 つに絞る** (例: `code-reviewer` agent)
2. **テストデータセットを作成** (`quality-datasets/<対象>.yaml`) — 10-20 件
   - auto-invoke が**期待される** prompt と**期待されない** prompt の両方を含める
3. **ベースライン測定**: `bash scripts/evaluate-skills.sh quality-datasets/<対象>.yaml`
4. **レポート確認**: `quality-reports/<日付>-<対象>.md` を人間が判定
5. **改善仮説**: description / system prompt / allowed-tools をリライト
6. **再測定**: 改善幅 5% 未満で頭打ち判定 → ループ終了
7. **永続化**: `retrospective-codify` skill で学びを `.claude/rules/learnings.md` などに反映

## データセット形式

`quality-datasets/<対象>.yaml`:

```yaml
target: code-reviewer
type: agent  # agent | skill
description: code-reviewer agent の auto-invoke / タスク完遂を評価
cases:
  - id: 1
    prompt: "コミット前にレビューして"
    expected_invocation: code-reviewer
    notes: 委譲が期待される定型パターン
  - id: 2
    prompt: "ls -la を実行して"
    expected_invocation: none
    notes: ファイル操作は agent 委譲対象外
```

## 実行

```bash
export ANTHROPIC_API_KEY=sk-ant-...
bash scripts/evaluate-skills.sh quality-datasets/code-reviewer.yaml
# → quality-reports/<YYYY-MM-DD>-code-reviewer.md にレポート生成
```

## 評価指標

| 指標 | 計測方法 | 目標 |
|---|---|---|
| auto-invoke 成功率 | 期待 invocation と実観測 invocation の一致率 | 80% 以上 |
| タスク完遂率 | 出力テキストの人間判定 | 90% 以上 |
| トークン消費 | `claude -p` の usage メタデータ (利用可能な場合) | ベースライン -20% |

## 改善仮説の立て方

ベースライン測定で「期待挙動と異なるケース」を見つけたら:

| 症状 | 改善仮説 |
|---|---|
| auto-invoke が発火しない | description の冒頭にユーザー発話の典型例を追加 |
| 関係ない場面で発火する | description に「使うべきでない場面」を明記 |
| 発火後に脱線する | system prompt の手順を箇条書きに分解 |
| ツール呼び出しが過剰 | `allowed-tools` を絞る |

## CI 化

`.github/workflows/quality-measurement.yml.template` を有効化すると週次 cron で自動測定できる。
API コストに注意し、配布先で意図的に opt-in する。

## 関連スキル

- `retrospective-codify`: 評価結果を skill / rule に永続化
- `learn`: 単発の学びを `.claude/rules/learnings.md` に追記
- `review-docs`: ドキュメント自体の品質レビュー（テンプレ対象外）

## 参考

- 公式 best-practices「自分の作業を検証する方法を Claude に与える」
- Anthropic engineering "Building effective agents" — Evaluator-Optimizer パターン
- `docs/quality-measurement.md` — 運用ガイド全体
