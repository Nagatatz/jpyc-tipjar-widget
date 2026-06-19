---
name: prd-writing
description: プロダクト要求定義書(PRD)を作成するための詳細ガイドとテンプレート。`/prd-writing` で起動。「PRD を書いて」「プロダクト要求定義書を作成して」「要件定義を起こして」リクエスト時、または新規プロジェクト / 新機能の企画フェーズで本スキルを案内する。
allowed-tools: Read, Write
disable-model-invocation: true
---

## 既存 PRD 一覧（自動取得）

!`ls -1 docs/product-requirements*.md 2>/dev/null || echo "(no existing PRDs)"`

## 作成手順

1. `docs/ideas/initial-requirements.md`を読み込む
2. `./template.md`を読み込む
3. テンプレートのプレースホルダー([○○]の部分)を、アイデアメモの内容に基づいて具体化する
4. `docs/product-requirements.md`として保存する
