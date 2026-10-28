# ドキュメント規約

## 日英必須（英語が正）

公開・共有するドキュメントは日本語・英語の両方を揃える。英語を先に変え、**同じコミットで**日本語も更新する。「あとで翻訳」はしない。すぐに訳せないときも、見出しの構造を揃えて要約と TODO を入れる。

| 英語（正） | 日本語 | 同期のしかた |
|---|---|---|
| `README.md` | `README.ja.md` | 両方を手で編集する |
| `sphinx-docs/` の英語ソース `.md` | `sphinx-docs/locale/ja/LC_MESSAGES/` の `.po` | `cd sphinx-docs && make update-po` で `.po` を更新し、空の `msgstr` を訳す |

## 置き場所

- `docs/` — 開発者向けの設計メモ（`docs/repository-structure.md` ほか）
- `sphinx-docs/` — 利用者・コントリビューター向けの公開ドキュメント（GitHub Pages）。`user/`（導入・設定・changelog）と `dev/`（開発・構成）
- 作業ごとの計画と完了条件は GitHub Issue に書く（→ `definition-of-done.md`）。リポジトリにファイルを作らない

## 機能を変えたとき

利用者に見える変更は、コードと同じ作業で `README.md` / `README.ja.md` の該当節と `sphinx-docs/user/`（`changelog.md` の Unreleased を含む）を両言語で更新する。コマンドや構成が変わったら `AGENTS.md` も直す。Issue の DoD にドキュメントの項目を入れる。
