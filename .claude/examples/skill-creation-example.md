# Skill 作成模範例

`.claude/skills/<name>/SKILL.md` の作り方をゴールドスタンダード水準で示す。本テンプレートの `claude-md-hygiene.md` / `audit-skill-descriptions.sh` の基準すべてに準拠する。

## ディレクトリ構成

```
.claude/skills/<skill-name>/
├── SKILL.md              # 必須: frontmatter + 本文
└── (resources/ ...)     # 任意: SKILL.md から参照する補助スクリプトなど
```

## SKILL.md 雛形

```markdown
---
name: <skill-name>
description: <動詞で開始する 1〜2 文の概要>。「<ユーザー発話例 1>」「<ユーザー発話例 2>」リクエスト時、または<技術的トリガー条件>に proactively 使用。<どんな価値を提供するかの 1 文>。
allowed-tools: Read, Edit, Bash
# 以下は任意:
# disable-model-invocation: true   # auto-invoke を禁止し、/skill-name 手動起動のみにする場合
# model: sonnet                    # Haiku / Sonnet / Opus を明示する場合
# effort: high                     # 計算予算ヒント
---

# <Skill タイトル> スキル

## ねらい

このスキルが解決する課題を 1〜3 文で簡潔に。Why が伝わる粒度。

## 使い方

ユーザーが本スキルを呼び出した／本スキルが auto-invoke された後の処理手順を箇条書きで:

1. 最初に行うこと（入力の確認、コンテキスト読み込み等）
2. 主要処理ステップ
3. 出力フォーマット
4. ユーザーへの確認・承認が必要なポイント

## 使う基準

- **使う場面:** <ユースケース A> / <ユースケース B>
- **使わない場面:** <類似だが別 skill のケース> / <skill 不要のケース>

## 関連スキル

- `<related-skill-1>` — <関係の説明>
- `<related-skill-2>` — <関係の説明>
```

## description の 3 基準（必須）

`scripts/audit-skill-descriptions.sh` の判定基準。**すべて満たす**こと:

| 基準 | 内容 | 例 |
|------|------|-----|
| **V (Verb-start)** | 動詞 / 動詞句で開始または説明に含む | "実行する" "評価する" "レビューする" "記録する" 等 |
| **T (Trigger)** | 発火条件を明示 | "〜時に" "リクエスト時に" "proactively 使用" |
| **K (Keywords)** | ユーザー発話を「...」形式で含む | 「コミットして」「レビューして」「実装して」等 |

### auto-invoke と手動起動の使い分け

| 設定 | 用途 | description の語尾 |
|------|------|------------------|
| (デフォルト) | モデルが状況を判定して自動起動 | `〜リクエスト時に proactively 使用` |
| `disable-model-invocation: true` | `/skill-name` 手動起動のみ | `〜リクエスト時に本スキルを案内する` |

## 良い description / 悪い description の比較

### ❌ 悪い例

```yaml
description: 実装コードの品質を5つの観点で検証する（スペック準拠・コード品質・テストカバレッジ・セキュリティ・パフォーマンス）
```

不足: 発火条件なし、ユーザー語彙なし。

### ✅ 良い例

```yaml
description: 実装コードの品質を 5 つの観点（スペック準拠・コード品質・テストカバレッジ・セキュリティ・パフォーマンス）で検証する。「実装をレビューして」「品質チェックして」「コード品質を確認して」リクエスト時、またはコミット前 / PR 作成前の自己検証として proactively 使用。
```

3 基準すべて満たす:
- V: "検証する" / "レビューして" 等の動詞表現
- T: "リクエスト時" "コミット前 / PR 作成前" の発火条件
- K: 「実装をレビューして」「品質チェックして」「コード品質を確認して」のユーザー語彙

## 作成後の検証

新規 skill 作成後、以下を実行して品質を確認:

```bash
# 静的監査（コスト 0）
bash scripts/audit-skill-descriptions.sh

# 実測監査（API key + quality-datasets が必要）
cp quality-datasets/_TEMPLATE.yaml quality-datasets/<skill-name>.yaml
# データセットを編集
bash scripts/evaluate-skills.sh quality-datasets/<skill-name>.yaml
```

## 関連規約

- `.claude/rules/claude-md-hygiene.md` — 健全性原則と肥大化検知
- `.claude/rules/delegate-investigation.md` — subagent への調査分離
- `docs/audits/2026-05-12-skill-descriptions.md` — 過去の監査結果と改善履歴
