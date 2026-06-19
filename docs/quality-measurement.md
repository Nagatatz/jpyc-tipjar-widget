# Skill / Agent 品質計測 運用ガイド

本テンプレートが配布する skill / agent は **意図通り auto-invoke されるか / タスクを完遂するか / コンテキストを効率的に使うか** が運用品質の鍵。`empirical-prompt-tuning` skill を中核に、実測ベースで継続改善するループを運用する。

## 実装ファイル

| ファイル | 役割 |
|---|---|
| `.claude/skills/empirical-prompt-tuning/SKILL.md` | 評価フローの起点となるメタスキル |
| `.claude/skills/retrospective-codify/SKILL.md` | 学びを description / rule / learnings.md に永続化するメタスキル |
| `scripts/evaluate-skills.sh` | テストデータセットを `claude -p` で実行しレポート生成 |
| `quality-datasets/<対象>.yaml` | テストデータセット (人間が作成) |
| `quality-datasets/README.md` | データセット作成ガイド |
| `.github/workflows/quality-measurement.yml.template` | 週次 cron CI 雛形 (opt-in) |

## 評価対象

優先度の高い順:

1. **agent**: 6 体（code-reviewer / build-resolver / security-reviewer / quick-search / debugger / release-manager）
2. **skill (auto-invoke 対象)**: bash-safety / worktree-safety / context-management / token-optimization / typescript-conventions / pr-summary / deep-research など
3. **skill (手動起動)**: steering / git-workflow / archive-steering など — auto-invoke 評価不要、ワークフロー完遂率で評価

## 評価指標

各 skill / agent について:

| 指標 | 計測方法 | 目標 |
|---|---|---|
| **auto-invoke 成功率** | テストプロンプト 10 件のうち、期待通り発火した割合 | 80% 以上 |
| **タスク完遂率** | 発火後、要件を満たす出力を生成できた割合 | 90% 以上 |
| **コンテキスト消費量** | スキル起動から完了までのトークン数（メイン会話への影響含む） | ベースライン -20% |
| **再現性** | 同じ入力で安定した出力を生成するか | 主観評価 |

## 運用フロー

### 手動運用 (Option A — 推奨開始点)

```bash
# 1. データセット作成 (初回のみ、code-reviewer.yaml をコピーして雛形に)
cp quality-datasets/code-reviewer.yaml quality-datasets/<対象>.yaml
# → 中身を編集

# 2. ベースライン測定
export ANTHROPIC_API_KEY=sk-ant-...
bash scripts/evaluate-skills.sh quality-datasets/<対象>.yaml
# → quality-reports/<日付>-<対象>.md 生成

# 3. レポートを人間レビュー
# - auto-invoke 成功率を集計
# - 失敗ケースから改善仮説を立てる

# 4. description / system prompt をリライト
# (該当 .claude/skills/X/SKILL.md または .claude/agents/X.md を Edit)

# 5. 再測定 → 改善幅 5% 未満で頭打ち判定 → ループ終了

# 6. 学びを permanent に反映 (retrospective-codify skill が案内)
```

### CI 自動化 (Option B)

週次バッチで全 skill / agent を再評価する。配布先で意図的に有効化する:

```bash
mv .github/workflows/quality-measurement.yml.template \
   .github/workflows/quality-measurement.yml

gh secret set ANTHROPIC_API_KEY --body "sk-ant-..."

# .yml の `# schedule:` セクションのコメントアウトを外す
git add .github/workflows/quality-measurement.yml
git commit -m "🔧 Enable weekly quality measurement"
git push
```

結果は GitHub Actions のアーティファクトとして 90 日保管される (`quality-reports-<run_id>`).

### Anthropic Console 連携 (Option C — 任意)

公式の Anthropic Console で Workbench 評価を活用する場合:
- skill / agent の prompt を Workbench に登録
- 同じテストデータセットを Workbench 上で実行
- GUI で結果が見やすい

本テンプレートでは Option A → B が標準ルート。Option C は GUI を好む配布先の選択肢。

## データセットの作り方

1. **対象を 1 つに絞る**: 複数 skill / agent を同時に評価しない
2. **10-20 件を目安に**: 少なすぎると統計的に弱い、多すぎると改善ループが重い
3. **正例と反例を半々**: false positive (誤発火) を検出するため
4. **エッジケースを入れる**: 「似ているが対象外」「複数 skill が候補になる」など

詳細は `quality-datasets/README.md` 参照。

## 評価結果から学びを永続化する

`retrospective-codify` skill を使い、`quality-reports/` の知見を以下に反映:

| 学びの性質 | 永続化先 |
|---|---|
| skill X の auto-invoke 改善 | `.claude/skills/X/SKILL.md` の description |
| agent X のツール使い方 | `.claude/agents/X.md` の description / system prompt |
| プロジェクト共通の規約変更 | `.claude/rules/<file>.md` |
| 個別事象の再発防止 | `.claude/rules/learnings.md` 追記 |

## ベースライン測定のサンプル

`quality-datasets/code-reviewer.yaml` が初期データセット (10 cases)。

正例（code-reviewer に委譲されるべき発話）:
- 「コミット前にこの変更をレビューして」
- 「PR を作る前にコードを見てほしい」
- 「デッドコードがあるか調べて」

反例（委譲すべきでない / 別 agent に委譲）:
- 「セキュリティ脆弱性を確認して」 → security-reviewer
- 「ファイル一覧を見せて」 → 直接 ls
- 「git log を表示して」 → 直接実行

このサンプルは「目標 80% を達成したか」のベースラインを取る最小データセット。
配布先で同等のデータセットを他 agent / skill 用に作成する。

## CI コストの目安

- 1 case あたり Sonnet で約 1k〜10k input tokens、output 1k〜5k tokens
- 10 case × 6 agents = 60 case/run、約 100k〜500k tokens/run
- 週次運用なら月 4 回、年間 5M〜25M tokens 程度
- 配布先のリポジトリオーナー負担。本テンプレートは cron をデフォルト無効化

## 関連

- 公式 best-practices「自分の作業を検証する方法を Claude に与える」
- Anthropic engineering "Building effective agents" — Evaluator-Optimizer パターン
- `.claude/skills/empirical-prompt-tuning/SKILL.md` — 評価フロー本体
- `.claude/skills/retrospective-codify/SKILL.md` — 学びの永続化
- `.claude/skills/learn/SKILL.md` — 単発の学び追記 (軽量版)
