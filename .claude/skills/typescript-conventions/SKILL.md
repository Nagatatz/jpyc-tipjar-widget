---
name: typescript-conventions
description: TypeScript / TSX ファイルを編集するときに自動でロードされるチーム規約（型安全・非同期・エラー処理・命名・テスト配置）。
paths:
  - "**/*.ts"
  - "**/*.tsx"
allowed-tools: Read
---

# TypeScript 規約

このリポジトリの本体は ReScript（`src/*.res`）。`.ts` / `.tsx` を追加・編集するときだけ適用する。

- **型**: `any` 禁止（`unknown` + ナローイング）。`as` は最小限、`satisfies` を優先。export する関数は引数・戻り値に型注釈。API / 外部入力の境界で Zod / valibot などで実行時検証。
- **モジュール**: 1 ファイル 1 責務。バレル再 export は浅い階層だけ。循環参照は共通モジュールへ切り出す。
- **非同期**: `async/await` に統一（`.then()` チェーンを使わない）。並行は `Promise.all` / `allSettled`。`try/catch` は上位レイヤー、下位は throw のみ。
- **エラー**: ドメインエラーは `Error` 継承クラス。ユーザー向け `message` と開発者向け `cause` を分ける。
- **命名**: 変数・関数 `camelCase`、クラス・型 `PascalCase`、モジュール定数 `UPPER_SNAKE_CASE`、ファイル `kebab-case.ts`（component は `PascalCase.tsx`）。
- **テスト**: `*.test.ts` を同階層、統合テストは `tests/integration/`。モックより実装に近い fake を使う。
- **tsconfig**: `strict`・`noUncheckedIndexedAccess`・`exactOptionalPropertyTypes`・`noImplicitOverride` を true。
