# AGENTS.md

## 最上位原則: Verification-first

コード変更には、エージェント自身が実行できる検証手段（テスト / lint / 型チェック / ビルド / スクリーンショット）を併設する。曖昧な指示は着手前に検証可能なゴールへ変換する（→ `.claude/rules/testing.md`）。Claude Code では、コード変更後に検証を実行していないターンを Stop hook が止める。

## プロジェクト概要

ブログ記事や任意の React ページに組み込める JPYC（日本円ステーブルコイン）投げ銭ウィジェット。ユーザーは MetaMask 経由で Polygon 上の JPYC を受取アドレスへ直接送金する（サーバーは資金を預からないオンチェーン直接送金）。MetaMask が無い環境では EIP-681 形式の QR コードでフォールバックする。`rich` / `simple` の 2 variant を持つ。

- 言語: ReScript（コンパイル済み `.res.js` を npm 配布）
- ビルドシステム: rescript（pnpm パッケージ管理）
- 対象プラットフォーム: React 19+（`react` / `react-dom` は peerDependencies）/ ブラウザ
- パッケージ: `jpyc-tipjar-widget`（npm）
- 既定ブランチ: `master`

## ビルド・実行コマンド

```bash
# ビルド（型チェックを兼ねる）
pnpm build

# クリーンビルド
pnpm clean && pnpm build
```

ユニットテストの基盤は未導入。検証は `pnpm build` の型チェックで行う。UI の確認用 demo は無い（0.1.2 で削除）ので、UI 変更は利用側のページで確かめ、その方法を Issue に書く。

## Sphinx ドキュメント

正式な日英ドキュメントは `sphinx-docs/`（英語ソース + `locale/ja/` 翻訳）で管理する。英語を正とし、英語を変えたら同じコミットで日本語も更新する（→ `.claude/rules/documentation.md`）。

```bash
cd sphinx-docs && make install  # 依存関係インストール（uv）
make html                       # 英語 HTML ビルド
make build-all                  # 全言語ビルド + Pagefind
make serve                      # ローカルサーバーで確認
make check                      # 品質チェック (lint + test)
make update-po                  # 英語ソース変更後に日本語 .po を更新
```

## タスク管理

GitHub Issues を作業の正とする。完了条件（DoD）、進捗、判断は Issue に置き、PR から参照する。旧 `.steering/` は完了済みの履歴であり、新規には作らない。

## プロジェクト構成

ディレクトリ構成と各ドキュメントの役割は `docs/repository-structure.md` を参照。

## エージェントの運用

Issue に目的・制約・検証できる完了条件を残す。原因不明の調査・設計比較は Fable 5.2、範囲が明確な変更は Opus 5.5 を候補にし、共有設定でモデル版を固定しない。汎用サブエージェントは親を継承し、権限・検証ゲートは変えない。

## 必須の品質検証

送金 URI・金額変換・ウォレット境界など振る舞い・仕様・不変条件・テストに関わる変更では、GitHub Issue の DoD に以下の 3 項目を置く。文言・整形のみで対象がなければ理由を記録する。

- **ミューテーションテスト**: 有効な変異でテストが落ちることを確認し、検出・生存・除外根拠を記録する。既存の専用ランナーは未確認。
- **プロパティベーステスト**: 合成した整数金額の最小単位への変換と URI 生成、チェーン・受取先・桁の境界を検証する。リポジトリの機能テスト基盤は未整備。 性質・入力範囲・再現条件を記録する。
- **形式証明**: 承認前に送金しないこと、入力と URI の金額・チェーンが一致すること。 仕様を実装とは別にレビューし、前提・証明範囲・実装との対応を記録する。既存の証明基盤は未確認。有界モデル検査は探索範囲外の証明とは扱わない。

未整備・未実行は合格とせず残作業を Issue に残す。既存の品質ゲートは維持する。 合成データとウォレットのモックを使い、検証で実送金・署名・実ウォレットに接続しない。

## Required Rules

`.claude/rules/*.md` が規約の単一ソース。本ファイルには索引だけを置き、ルール本文は写さない（`@import` もしない）。Claude Code は `paths:` の無いルールを常時、`paths:` のあるルールを一致するファイルを扱うときにロードする。

`.claude/rules/` を自動でロードしない環境では、対象ファイルを調査・編集する前に該当ルールの本文を自分で読む。規約を変更する前に `.claude/skills/claude-md-hygiene/SKILL.md` を読む。

| ルール | ロード条件 | 内容 |
|---|---|---|
| [`definition-of-done`](.claude/rules/definition-of-done.md) | 常時 | 作業ごとに Issue へ DoD を書く。計画〜マージ後の完了条件（SSoT） |
| [`git-conventions`](.claude/rules/git-conventions.md) | 常時 | 絵文字プレフィックス + 英語動詞のコミット、1 コミット 1 論理変更、Issue 番号つきブランチ |
| [`issue-workflow`](.claude/rules/issue-workflow.md) | 常時 | 並行作業時の着手（`status/in-progress`）・「要判断」の書き方・手放し方 |
| [`testing`](.claude/rules/testing.md) | 常時 | 曖昧な指示を検証可能なゴールに変換、3 回失敗したら相談 |
| [`issue-pr-reference`](.claude/rules/issue-pr-reference.md) | 常時 | 文章中の Issue は 📋 + inline code、PR は 🔀 + リンクで区別 |
| [`documentation`](.claude/rules/documentation.md) | 常時 | ドキュメントは日英必須、英語が正 |
| [`test-authoring`](.claude/rules/test-authoring.md) | ソースファイル | コード変更にはテストを作成・更新、配置と命名 |
| [`code-comments`](.claude/rules/code-comments.md) | ソースファイル | 周囲に合わせ、名前から復元できない「なぜ」だけを書く |
| [`minimal-change`](.claude/rules/minimal-change.md) | ソースファイル | 要求を満たす最小の差分、ついで改善を混ぜない |
| [`github-actions`](.claude/rules/github-actions.md) | `.github/workflows/**` ほか | 外部 action は SHA 固定 + バージョンコメント |

「ソースファイル」は各ルールの `paths:` に一致するファイル。正確な条件は各ルールの frontmatter を確認する。

## 入口ファイル

規約の本文は本ファイルに置く。repo 直下の `CLAUDE.md` は `@AGENTS.md` の 1 行だけにしている。以前の実環境では repo 直下に `CLAUDE.md` がないと本ファイルが読まれなかったため、読み込み専用アダプターを維持する（規約本文ではない）。`@AGENTS.md` の 1 行の `CLAUDE.md` を置くと読まれた（2026-10-28 に Claude Code 2.1.312 で確認。上位に `hobby/CLAUDE.md` があることが原因かは確かめていない）。`CLAUDE.md` に本文を足さない。

## 個人メモ

チームに共有しない指示は `~/.claude/CLAUDE.md` に書く（全プロジェクトに効く）。`CLAUDE.local.md` は使わない。
