# design

## 洗い出し結果
| 箇所 | 現状 | 対応 |
|---|---|---|
| `.github/workflows/docs.yml` setup-node | `'24'` | `'^24.22.1'` |
| `.github/workflows/release.yml` setup-node | `'24'` | `'^24.22.1'` |
| `.devcontainer/devcontainer.json.template` | node feature 既定 (`lts`、作成時の最新 LTS) | 変更しない (未使用の雛形・作成時に最新 LTS が入る) |
| `package.json` engines | 無し | 追加しない (ブラウザ向けライブラリで Node 上で動かない。engines は利用側 (nagatatz-jp 等) の install に警告を出す) |
| README / docs | Node の版表記なし (changelog の過去記載のみ) | changelog Unreleased に Internal として追記 (EN + JA .po) |

`'24'` のままだと setup-node は runner の toolcache にある 24.x (修正前の可能性あり) をそのまま使うため、
semver 範囲 `^24.22.1` で下限を固定する。toolcache が満たさなければ修正版をダウンロードする。

## 依存の調査結果
- pnpm-lock.yaml: express / body-parser / koa / brotli 系なし (runtime 依存は @rescript/react, @rescript/runtime, qrcode.react, viem のみ)
- sphinx-docs/uv.lock: brotli / brotlicffi なし。urllib3 2.7.0 は brotli 未導入なら br を展開しない。uvicorn/starlette (sphinx-autobuild, ローカルのみ) は request body を展開しない
- Node 自体の zlib (fetch の br 自動展開、npx pagefind / pa11y-ci) が経路 → Node の版固定で対処
