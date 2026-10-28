# requirements: Node2Shell / HTTP2Shell (CVE-2026-111497) 対応

## 背景
Node.js 同梱 Brotli (1.0.3〜1.2.0) の展開処理にメモリ破壊。修正版は Node.js 22.23.4 / 24.22.1 / 26.12.1
(nodejs.org/dist/index.json で security=true・2026-10-20/21 リリースを確認済み)。

## 要求
1. repo 内で Node の版を指定している箇所を修正版以上に固定する
2. 依存に Brotli を展開する経路 (express / body-parser / koa / dev server / brotli 系パッケージ、Python 側の brotli / brotlicffi / urllib3) が無いか調べ、あれば上げる
3. 公開物 (npm パッケージ) は変えない。tag・publish・版上げはしない (版上げは PR に案として書く)

## 完了条件
- workflow の node-version が修正版未満に解決されない指定になっている
- 調査結果が PR に書かれている
- `pnpm build` が heavy.sh 経由で通る
