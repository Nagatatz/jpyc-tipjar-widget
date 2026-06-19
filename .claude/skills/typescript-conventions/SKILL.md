---
name: typescript-conventions
description: TypeScript / TSX ファイルを編集するときに自動でロードされるチーム規約。型安全 / strict mode / async-await / エラーハンドリング / モジュール構造のスタンダード。配布先で実プロジェクトに合わせて編集する雛形。
paths:
  - "**/*.ts"
  - "**/*.tsx"
allowed-tools: Read
---

# TypeScript 規約

> **配布先で実プロジェクトに合わせて編集する雛形**。TypeScript を使わないプロジェクトでは削除推奨。
> Python / Go / Rust / Kotlin 等を使う場合は、本ファイルをコピーして `paths` を変更してください（例: `python-conventions` で `**/*.py`）。

## 型安全

- `any` 禁止。型がわからない場合は `unknown` を使い、ナローイング (`typeof` / `instanceof` / type guard) で絞る
- API 境界 / DB 境界では Zod / valibot 等で実行時バリデーション
- `as` キャストは最小限。安全な型変換は `satisfies` / 関数で表現
- 関数の引数・戻り値に明示的な型注釈（特に export される関数）

## モジュール構造

- 1 ファイル = 1 機能の責務（複数の独立した責務を 1 ファイルに混ぜない）
- バレル import (`index.ts` 経由の再 export) は浅い階層のみで使う
- 循環参照を避ける: A → B → A の依存があれば共通モジュールに切り出す

## 非同期処理

- `async/await` 統一（`.then()` チェーンを使わない）
- 並行処理は `Promise.all` / `Promise.allSettled` を使う
- 上位レイヤーで `try/catch`、下位レイヤーは throw のみ（必要に応じて custom Error クラス）

## エラーハンドリング

- ドメインエラーは `Error` 継承の独自クラス
- ユーザー入力検証は zod schema を境界（API handler / form）で行う
- エラーメッセージはユーザー向け / 開発者向けを分離（`message` と `cause`）

## naming convention

- 変数 / 関数: `camelCase`
- クラス / 型 / interface: `PascalCase`
- 定数（モジュールスコープ）: `UPPER_SNAKE_CASE`
- ファイル名: `kebab-case.ts`（component は `PascalCase.tsx`）

## テスト

- ユニットテスト: `*.test.ts` を同階層に配置
- インテグレーションテスト: `tests/integration/` 配下
- モックはなるべく避け、実装に近い fake オブジェクトを使う

## tsconfig 推奨設定

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true
  }
}
```
