# Examples — ゴールドスタンダード参考集

> 出典: [Stack Overflow Blog "Building shared coding guidelines for AI"](https://stackoverflow.blog/2026/03/26/coding-guidelines-for-ai-agents-and-people-too/) — 「AI はパターンを愛する。全規約に準拠した参考ファイル（ゴールドスタンダード）を提示せよ」

本ディレクトリには、本テンプレートの規約（`.claude/rules/` 全体）を**すべて満たした模範例**を配置する。Claude が「規約に準拠した変更とは具体的にどういう形か」を学習するためのリファレンス。

## ファイル

| ファイル | 内容 |
|---------|------|
| `commit-message-examples.md` | 9 種の絵文字プレフィックス別、模範的なコミットメッセージ例 |
| `feature-pr-walkthrough.md` | 機能追加 PR の全工程（steering → 実装 → テスト → ドキュメント → コミット粒度）模範例 |
| `skill-creation-example.md` | 新規 skill の SKILL.md 雛形 + description 3 基準準拠例 |
| `hook-creation-example.md` | 新規 hook スクリプトの雛形 + settings.json 登録例 |

## 使い方

新規 skill / rule / agent / 機能を追加するとき、本ディレクトリの例を**参考にする**。Claude に「`.claude/examples/feature-pr-walkthrough.md` の構造に従って実装してください」のように明示的に参照させると、規約準拠率が上がる。

## 維持方針

- 規約変更時は本ディレクトリの例も同期して更新する（ドキュメント更新規約に従う）
- 各例は最小限の量に保つ — 「動く例」よりも「読みやすい例」を優先
- 古い / 廃止された規約に依存する例は削除する
