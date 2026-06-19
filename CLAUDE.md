# CLAUDE.md

## 強制的な行動指示

本ファイルおよび `@import` で読み込まれるルール、`.claude/skills/` 配下のスキル本文に書かれている規約は **すべて強制** であり、ユーザーから明示的に解除されない限り例外なく従うこと。違反した場合は即座に修正する。

## 最上位原則: Verification-first

> 公式: 「Give Claude a way to verify its work. **This is the single highest-leverage thing you can do.**」

すべてのコード変更には、Claude 自身が検証可能な手段（ユニットテスト / lint / typecheck / ビルド / スクリーンショット）を併設すること。検証手段が無い変更は出荷しない。曖昧な指示（「動くようにして」等）を受けた場合は、実装着手前に検証可能なゴールに変換すること（→ `@.claude/rules/testing.md` の「検証可能ゴール変換」表）。

## プロジェクト概要

ブログ記事や任意の React ページに組み込める JPYC（日本円ステーブルコイン）投げ銭ウィジェット。ユーザーは MetaMask 経由で Polygon 上の JPYC を受取アドレスへ直接送金する（サーバーは資金を預からないオンチェーン直接送金）。MetaMask が無い環境では EIP-681 形式の QR コードでフォールバックする。`rich` / `simple` の 2 variant を持つ。

- 言語: ReScript（コンパイル済み `.res.js` を npm 配布）
- ビルドシステム: rescript（pnpm パッケージ管理）
- 対象プラットフォーム: React 19+（`react` / `react-dom` は peerDependencies）/ ブラウザ

## ビルド・実行コマンド

```bash
# ビルド
pnpm build          # rescript build

# クリーンビルド
pnpm clean && pnpm build   # rescript clean && rescript build

# テスト
# （現状ユニットテスト基盤は未導入。検証は `pnpm build` の型チェック + demo/ での動作確認で行う）
```

> **検証手段**: ReScript のビルド（`pnpm build`）が型チェックを兼ねる。UI 変更は `demo/` を起動して目視・スクリーンショットで確認する。テスト基盤を追加する場合は `@.claude/rules/testing.md` の方針に従う。

## Sphinx ドキュメント

正式な日英ドキュメントは `sphinx-docs/`（英語ソース + `locale/ja/` 翻訳）で管理する。

```bash
cd sphinx-docs && make install  # 依存関係インストール（uv）
make html                       # 英語 HTML ビルド
make build-all                  # 全言語ビルド + Pagefind
make serve                      # ローカルサーバーで確認
make check                      # 品質チェック (lint + test)
make update-po                  # 英語ソース変更後に日本語 .po を更新
```

## プロジェクト構成

@docs/repository-structure.md

## ドキュメントは日英必須

このプロジェクトのドキュメントは **日本語・英語の両方を必須** とする。**英語ドキュメントを更新したら、対応する日本語ドキュメントを同じ変更（コミット）内で必ず更新する**こと。詳細は `@.claude/rules/documentation.md`「バイリンガル必須ルール」を参照。

## 開発規約

- パッケージ: `jpyc-tipjar-widget`（npm）

> `.claude/` 配下の rule / skill / agent / command の役割分担と新規追加判断基準は README.md「規約とスキルの住み分け」セクション参照。

### 常時適用される規約 (rules)

以下のルールはすべてのセッションで `@import` され、常に適用される。

@.claude/rules/testing.md
@.claude/rules/code-comments.md
@.claude/rules/git-conventions.md
@.claude/rules/steering-workflow.md
@.claude/rules/documentation.md
@.claude/rules/definition-of-done.md
@.claude/rules/permission-modes.md
@.claude/rules/minimal-change.md
@.claude/rules/claude-md-hygiene.md
@.claude/rules/delegate-investigation.md

<!--
  /learn skill が `.claude/rules/learnings.md` を生成したら、以下のコメントを外して有効化する。
  存在しないファイルを @import すると Claude Code が警告する可能性があるため、生成前は無効化しておく。

  @.claude/rules/learnings.md
-->


### 状況発火型の知識 (skills)

以下は `.claude/skills/` に配置されており、該当状況になると Claude が自動でロードする。手動呼び出しは不要。

| スキル | 発火タイミング |
|------|--------------|
| **bash-safety** | 破壊的な Bash 操作（rm, rm -r, ディレクトリ削除等）を実行する直前 |
| **worktree-safety** | git worktree の作成・削除・整理時 / CWD 壊れの復旧時 |
| **context-management** | コンテキスト圧迫時 / 探索→実装の切替時 |
| **token-optimization** | サブエージェント / モデル選択時 |

## 個人ノート

`CLAUDE.local.md` を作成すると、git 追跡対象外の個人メモとして扱われる（`.gitignore` 済み）。チームに共有しない作業手順、個人 API キー操作メモ、デバッグ用一時情報などを記述してよい。`@CLAUDE.local.md` で CLAUDE.md から取り込むこともできる。
