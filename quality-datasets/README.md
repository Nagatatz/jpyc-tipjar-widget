# Quality Datasets

`empirical-prompt-tuning` skill が利用するテストデータセットの保管場所。
`scripts/evaluate-skills.sh` の入力として使用する。

## ファイル形式

```yaml
target: <skill / agent 名>
type: agent | skill
description: 一行説明
cases:
  - id: 1
    prompt: "ユーザー発話"
    expected_invocation: <skill / agent 名 | none>
    notes: 補足

  - id: 2
    prompt: "別の発話"
    expected_invocation: none
    notes: 反例 (発火すべきでない場面)
```

## 作成ガイド

1. **対象を 1 つに絞る**: 複数 skill / agent を同時に評価しない (改善ループが回らなくなる)
2. **10-20 件**を目安にする: 少なすぎると統計的に弱い、多すぎると改善ループが重い
3. **正例と反例を半々**にする: 期待 invocation あり / なしを混ぜる (false positive 検出のため)
4. **エッジケースを入れる**: 「似ているが対象外」「複数 skill が候補になる」など
5. **id は連番、notes は人間が読む前提**で記述

## 既存データセット

- `code-reviewer.yaml` — code-reviewer agent (Phase 10 のベースライン例、10 cases)
- `_TEMPLATE.yaml` — 新規データセット作成用の skeleton（プレースホルダ付き）

## 新規作成例

新しい agent / skill を評価対象にする場合、`_TEMPLATE.yaml` または `code-reviewer.yaml` を起点に作成:

```bash
# 真新しい対象を評価する場合（推奨）
cp quality-datasets/_TEMPLATE.yaml quality-datasets/<対象>.yaml

# 既存例の構造を参考に作る場合
cp quality-datasets/code-reviewer.yaml quality-datasets/<対象>.yaml

# 中身を編集後、計測実行
bash scripts/evaluate-skills.sh quality-datasets/<対象>.yaml
```

## 拡充の優先度

22 skill / 6 agent すべてに対応データセットを用意するのは現実的ではない。次の優先度で拡充する:

1. **高:** auto-invoke が頻繁な skill（`steering`, `git-workflow`, `add-feature`）
2. **中:** description リライト履歴があるもの（`docs/audits/2026-05-12-skill-descriptions.md` で更新済みの 7 件）
3. **低:** `disable-model-invocation: true` の skill（auto-invoke 評価対象外。手動起動を促す description としての品質のみ評価）

## 関連

- `.claude/skills/empirical-prompt-tuning/SKILL.md` — 評価フロー本体
- `scripts/evaluate-skills.sh` — 実行スクリプト
- `docs/quality-measurement.md` — 運用ガイド全体
