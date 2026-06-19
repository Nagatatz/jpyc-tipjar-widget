# 調査タスクの subagent 分離規約

> 出典: [Best practices for Claude Code（Anthropic 公式）](https://code.claude.com/docs/en/best-practices), [Context Engineering for Coding Agents（Martin Fowler / Birgitta Böckeler）](https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html)
>
> 公式: 「Since context is your fundamental constraint, **subagents are one of the most powerful tools available**.」

コードベース調査・コード読み込みの多いタスクは、メイン会話のコンテキストを汚さないため **必ず subagent に分離** すること。メイン会話は「決定」と「実装」に集中させる。

## 判定基準

以下のいずれかに該当するタスクは subagent に分離すること:

- **3 ファイル以上を横断的に読む必要がある探索**
- **「どこで X が定義されているか」「Y を参照しているのはどこか」型のシンボル / キーワード検索**
- **不慣れな領域の理解（認証フロー / DB スキーマ / API パターン把握）**
- **PR / ブランチの差分要約**
- **既存実装パターンの抽出（「既存のウィジェットはどう実装されているか」）**
- **コードレビュー（書いたコードを別コンテキストで批評させる Writer/Reviewer パターン）**

逆に、**1〜2 ファイルの該当箇所が既に判明している場合は直接 Read** を使う（subagent は過剰）。

## subagent タイプの選び方

| タスク | 推奨 subagent | 理由 |
|--------|--------------|------|
| ファイル名 / シンボルの所在特定 | `Explore`（read-only） | 最速・低コスト |
| 軽量検索（grep / glob） | `quick-search`（Haiku） | 低レイテンシ |
| 横断的な深掘り（複数領域の関連性） | `general-purpose` または `Plan` | 包括的調査 |
| コード品質レビュー | `code-reviewer`（Sonnet） | 8 観点フレームワーク |
| セキュリティレビュー | `security-reviewer`（Opus） | 深い分析 |
| ビルド・テスト失敗の原因分析 | `build-resolver`（Sonnet, worktree 隔離） | 失敗の本質に到達 |
| バグ・スタックトレース分析 | `debugger`（Sonnet） | 根本原因分析 |
| PR 差分要約 | `pr-summary` skill（内部で Explore fork） | コンテキスト保護 |
| トピック徹底調査 | `deep-research` skill（内部で Explore fork） | 詳細な領域理解 |

## Agent 単発 vs Workflow オーケストレーション

subagent を「1 回呼ぶ」だけで足りるか、複数エージェントを**決定論的に**束ねる Workflow が要るかを区別する。

| 状況 | 使うもの |
|------|---------|
| 1 つの調査・レビュー・修正を別コンテキストに委譲 | `Agent`（または上表の subagent） |
| N 個の独立対象を同一手順で処理（移行スイープ・全ファイル変換） | **Workflow**（`pipeline`） |
| 検証多段（find → adversarial verify → synthesize）で品質を担保 | **Workflow** |
| 観点別の並行探索を 1 つの答えに統合（multi-modal sweep） | **Workflow**（`parallel` → synthesize） |
| ループ・条件分岐をモデル任せでなく確定的に回したい | **Workflow** |

**Workflow は明示 opt-in 機能**（ユーザーが「workflow を使って」等と要求した場合のみ起動）。雛形は `.claude/workflows/`（`comprehensive-review` / `migration-sweep` / `research-fanout`）。1 段の調査で済むなら Workflow は過剰 — `Agent` を使う。

## メイン会話のコンテキスト保護原則

- **subagent には自己完結したプロンプトを渡す**: 「本会話のここまで」ではなく、subagent が初見で必要な情報をすべて含める
- **subagent の結果は要約のみ受け取る**: 探索結果の生 grep 出力をメイン会話に持ち込まない
- **並列実行可能なら 1 メッセージで並行起動する**: 独立した調査は並列、依存関係があれば直列

## 禁止事項

- 「ちょっと調べる」つもりで Read / Grep を 5 回以上連打する（メインのコンテキストが汚れる）
- subagent の結果を全文転記する（要約せよ）
- 検証 / 信頼チェックなしに subagent の主張を採用する（公式: 「memory says X exists ≠ X exists now」）

## 関連規約

- `.claude/skills/token-optimization/`: モデル選択（Haiku / Sonnet / Opus）とコンテキスト節約戦略
- `.claude/skills/context-management/`: コンテキスト圧迫時の `/compact` 戦略
- `.claude/skills/deep-research/`, `.claude/skills/pr-summary/`: fork 実行型の調査 skill
