---
description: コーディング規約と開発プロセスのガイドライン（`docs/development-guidelines.md`）を作成・確認する。「開発ガイドラインを作って」「規約を整えて」、または新規プロジェクトのセットアップ時に使用。
allowed-tools: Read, Write, Edit
---

# 開発ガイドライン

```text
/development-guidelines          # 有無を確認し、概要と推奨アクションを示す
/development-guidelines create   # docs/development-guidelines.md を新規作成
/development-guidelines check    # 直近の変更（git diff）がガイドラインに沿うか確認
```

## 優先順位

1. `docs/development-guidelines.md`（あれば最優先。更新時は既存の構造を保つ）
2. `CLAUDE.md` と `.claude/rules/`（常時適用の規約）
3. 本 skill の汎用ガイド — コーディング規約は [guides/implementation.md](guides/implementation.md)、開発プロセスは [guides/process.md](guides/process.md)。既存ガイドラインが無いときか補足として使う

## create

guides の 2 ファイルを読み、CLAUDE.md・`.claude/rules/` と矛盾しない `docs/development-guidelines.md` を作る。重複する規約は書かず、該当ファイルへのリンクにする。

## check

ガイドラインを読み、`git diff` の変更ファイルを照らし、次の形で報告する:

```markdown
## 開発ガイドライン状況
### コーディング規約
- [x] / [ ] 項目
### 開発プロセス
- [x] / [ ] 項目
### 推奨アクション
1. …
```
