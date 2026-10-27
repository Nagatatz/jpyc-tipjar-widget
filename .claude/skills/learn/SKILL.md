---
description: セッションで得た非自明な発見・回避策・プロジェクト固有のパターンを `.claude/rules/learnings.md` に記録する（`/learn`）。
allowed-tools: Read, Write, Edit, Glob
disable-model-invocation: true
---

# Learn

保存先は `.claude/rules/learnings.md`（CLAUDE.md には書かない）。

1. 会話から、次回も役立つ非自明な知見を選ぶ: デバッグ手法、ライブラリの回避策、プロジェクト固有のパターン、環境依存の注意点、計測したパフォーマンス差。一般的な言語知識・一時的な障害・既存ルールにある内容は除く。
2. learnings.md を読み（無ければ作る）、同義のエントリがあれば新規追加せず統合する（日付だけ更新）。
3. 追記する:
   ```markdown
   # プロジェクト固有の知見（Learnings）

   - [YYYY-MM-DD] <簡潔な説明>: <詳細>
   ```
4. 追記内容をユーザーに見せて確認を得る。

新規作成したら、CLAUDE.md 末尾のコメントアウトされた `@.claude/rules/learnings.md` を有効化するよう提案する。

## 成長制御

learnings.md は毎セッション読み込まれる固定コストになるので、無制限に増やさない（`.claude/rules/claude-md-hygiene.md` の肥大化警告）。

- **上限 400 行**。超えたら古い月を退避する:
  ```bash
  bash scripts/prune-learnings.sh --dry-run  # 退避対象の確認のみ
  bash scripts/prune-learnings.sh            # 上限超過時のみ .claude/rules/learnings-archive-YYYY-MM.md へ退避
  ```
  注意: 退避先も `.claude/rules/` 内なので、Claude Code の rules 自動読み込みの対象に残る（常時ロードからは外れない）。
- **昇格**: 同種が 3 件以上たまった、または恒常的な規約に育った項目は `.claude/rules/` の独立ルール（または該当 skill）へ移し、元エントリは消す。
