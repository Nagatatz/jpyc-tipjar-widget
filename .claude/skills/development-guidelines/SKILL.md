---
description: チーム開発の規約（コーディング規約 / 開発プロセス標準化）を確立・維持するスキル。「開発ガイドラインを作って」「規約を整えて」のリクエスト時、または新規プロジェクトのセットアップ時に使用。implementation.md と process.md の 2 軸でカバー。
allowed-tools: Read, Write, Edit
---

# 開発ガイドラインスキル

チーム開発に必要な2つの要素をカバーします:
1. 実装時のコーディング規約 (guides/implementation.md)
2. 開発プロセスの標準化 (guides/process.md)

## 既存ドキュメントの優先順位

`docs/development-guidelines.md` に既存の開発ガイドラインがある場合は、次の優先順位で扱う:

1. **既存の開発ガイドライン (`docs/development-guidelines.md`)** - 最優先
   - プロジェクト固有の規約とプロセスが記載されている
   - このスキルのガイドより優先する

2. **このスキルのガイド** - 参考資料
   - ./guides/implementation.md: 汎用的なコーディング規約
   - ./guides/process.md: 汎用的な開発プロセス
   - 既存ガイドラインがない場合、または補足として使用

**新規作成時**: このスキルのガイドとテンプレートを参照
**更新時**: 既存ガイドラインの構造と内容を維持しながら更新

## 使い方

- `/development-guidelines` — 開発ガイドラインの確認・適用
- `/development-guidelines create` — `docs/development-guidelines.md` を新規作成
- `/development-guidelines check` — 現在のコードがガイドラインに準拠しているか確認

## 実行手順

着手前に `docs/development-guidelines.md` の有無を確かめる。あれば最優先の基準として読み、無ければ guides/ を基に新規作成を提案する。あわせて AGENTS.md から、プロジェクトの概要と技術スタック、既存のコーディング規約・コメント規約・Git コミット規約・開発プロセスを把握する。

引数ごとの目的:

- **`create`**: guides/implementation.md と guides/process.md を基に、AGENTS.md の既存規約と整合する `docs/development-guidelines.md` を生成する。AGENTS.md と重複する内容は書かず、AGENTS.md への参照リンクで繋ぐ
- **`check`**: 直近の変更ファイル（`git diff` で特定）を既存ガイドラインに照らし、準拠状況をレポートする
- **引数なし**: 既存ガイドラインの有無と概要を示し、推奨アクションを提示する

### レポート出力

以下の形式で結果を出力する:

```
## 開発ガイドライン状況

### コーディング規約
- [x] 規約項目1
- [x] 規約項目2
- [ ] 規約項目3

### 開発プロセス
- [x] ドキュメント管理
- [x] テスト実行
- [ ] Issue の DoD の作成

### 推奨アクション
1. ...
2. ...
```