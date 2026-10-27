---
name: prd-writing
description: テンプレートからプロダクト要求定義書（PRD）を作成する（`/prd-writing`）。
allowed-tools: Read, Write
disable-model-invocation: true
---

## 既存 PRD

!`ls -1 docs/product-requirements*.md 2>/dev/null || echo "(no existing PRDs)"`

## 手順

1. アイデアメモ `docs/ideas/initial-requirements.md` を読む。無ければ、目的・対象ユーザー・主要機能・制約をユーザーに聞く。
2. [template.md](template.md) を読み、`[○○]` のプレースホルダーをメモの内容で具体化する。
3. `docs/product-requirements.md` に保存する（既にあれば上書き前に確認する）。
