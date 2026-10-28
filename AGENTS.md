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

## プロジェクト構成

ディレクトリ構成と各ドキュメントの役割は `docs/repository-structure.md` を参照。

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
| [`code-comments`](.claude/rules/code-comments.md) | 常時 | ドキュメントコメントの付け方 |
| [`minimal-change`](.claude/rules/minimal-change.md) | 常時 | 要求を満たす最小の差分、ついで改善を混ぜない |
| [`delegate-investigation`](.claude/rules/delegate-investigation.md) | 常時 | 調査の多いタスクは subagent に分ける |
| [`test-authoring`](.claude/rules/test-authoring.md) | ソースファイル | コード変更にはテストを作成・更新、配置と命名 |

「ソースファイル」は各ルールの `paths:` に一致するファイル。正確な条件は各ルールの frontmatter を確認する。

## 入口ファイル

規約の本文は本ファイルに置く。repo 直下の `CLAUDE.md` は `@AGENTS.md` の 1 行だけにしている。この repo は hobby workspace の下にあり、上位の `hobby/CLAUDE.md` があると Claude Code は本ファイルを読まないため（2026-10-28 に Claude Code 2.1.312 で確認）。`CLAUDE.md` に本文を足さない。

## 個人メモ

チームに共有しない指示は `~/.claude/CLAUDE.md` に書く（全プロジェクトに効く）。`CLAUDE.local.md` は使わない。
