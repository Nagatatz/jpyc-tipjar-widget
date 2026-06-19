# CLAUDE.md 健全性規約

> 出典: [Best practices for Claude Code（Anthropic 公式）](https://code.claude.com/docs/en/best-practices)
>
> 公式警告: 「Bloated CLAUDE.md files cause Claude to **ignore** your actual instructions」「If Claude keeps doing something you don't want despite having a rule against it, the file is probably too long and the rule is getting lost.」

CLAUDE.md（および `@import` 連鎖でロードされる `.claude/rules/` 配下のファイル）は **毎セッションでロードされる固定オーバーヘッド** であり、肥大化すると逆効果になる。本ルールは「短く保つ」規律を Single Source of Truth として明示する。

## プルーニング原則

新しい行・新しいルールを追加するとき、必ず以下を自問すること:

1. **この行を削除したら、Claude が間違えるか？** 間違えないなら削除する
2. **既存コードを読めば Claude が推測できる内容か？** 推測できるなら削除する
3. **特定状況でしか使わない知識か？** Yes なら `.claude/skills/` に分離する（auto-invoke）

3 つすべて No の場合のみ、CLAUDE.md / `.claude/rules/` に追加してよい。

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

## 状況発火スキルへの分離基準

「毎セッションで必要か / 特定状況だけか」で判断:

- **常時必要** → `.claude/rules/` + CLAUDE.md.template の `@import`
- **特定状況** → `.claude/skills/` に skill 化、description で auto-invoke

例: 「破壊的 Bash 操作前の安全規約」は常時要らない（破壊操作時のみ）→ `bash-safety` skill。「Git コミット規約」は実装後に毎回適用 → `git-conventions.md` ルール。

## 過剰追加検知

以下のいずれかが観測されたら CLAUDE.md / ルールが肥大化している可能性が高い:

- Claude がルールに反する挙動を繰り返す（規則が他のテキストに埋もれている）
- Claude が CLAUDE.md に既に答えがある質問をユーザーに投げる（表現が曖昧 / 重要度が伝わっていない）
- セッション開始時のコンテキスト使用率が常に 30% を超えている

対応:
1. 既存ルールを「3 つの自問」で再評価し、削れる行を削る
2. 特定状況用の知識は skill に移動する
3. `empirical-prompt-tuning` skill で description / ルール本文の効果を実測する

## 関連規約

- `.claude/rules/permission-modes.md`: Plan Mode / steering の住み分け
- `.claude/skills/empirical-prompt-tuning/`: description / system prompt の実測ベース改善
- `.claude/skills/context-management/`: コンテキスト圧迫時の運用
