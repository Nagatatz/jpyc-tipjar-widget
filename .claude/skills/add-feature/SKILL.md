---
description: 新機能を実装するとき、既存コードのパターン（モジュール構成・バインディングの書き方・エラー処理・テストスタイル）を調べて合わせる。「機能を追加して」「実装して」で使用。
---

# 新機能の追加

1. **把握**: `README.md`・`sphinx-docs/dev/architecture.md`・`sphinx-docs/dev/project-structure.md` で全体像とモジュール責務を掴む（`docs/repository-structure.md` は雛形のままなので当てにしない）。
2. **既存パターン調査**: Grep で類似機能を探して読み、公開 API の書き方・エラー処理・テストの書き方を確認する（`src/bindings/`（外部 JS 束縛）・`src/components/`（React コンポーネント）・`src/domain/`（純粋ロジック）・`src/effects/`（ウォレット等の副作用）、公開口は `src/Entry.res`）。
3. **実装**: 見つけたパターンと上のディレクトリの責務分担に従う。
4. **テスト**: 現状ユニットテスト基盤は無い（`package.json` に test スクリプトなし）。`.claude/rules/testing.md` の例外（UI・外部結合）に当たらないロジックを足すなら、テスト基盤の導入をユーザーに提案する。省略するなら理由を tasklist.md に書く。
5. **検証**: `pnpm build`（ReScript のビルドが型チェックを兼ねる）。おかしければ `pnpm clean && pnpm build`。失敗したら既存パターンとの差を確かめて直し、再実行する。UI の変更はユーザーに目視確認を頼む。
6. **ドキュメント**: `.claude/rules/documentation.md` の対応表に従い、同じコミットで**日英両方**を更新する（`README.md` と `README.ja.md`、`sphinx-docs/` の英語ソースを変えたら `cd sphinx-docs && make update-po` で `.po` を更新して訳を埋める）。
