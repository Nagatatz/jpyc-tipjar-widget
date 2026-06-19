# jpyc-tipjar-widget

**言語: [English](./README.md) | 日本語（このファイル）**

[![npm version](https://img.shields.io/npm/v/jpyc-tipjar-widget?logo=npm&color=cb3837)](https://www.npmjs.com/package/jpyc-tipjar-widget)
[![Docs](https://github.com/Nagatatz/jpyc-tipjar-widget/actions/workflows/docs.yml/badge.svg)](https://github.com/Nagatatz/jpyc-tipjar-widget/actions/workflows/docs.yml)
[![Release](https://github.com/Nagatatz/jpyc-tipjar-widget/actions/workflows/release.yml/badge.svg)](https://github.com/Nagatatz/jpyc-tipjar-widget/actions/workflows/release.yml)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/Nagatatz?logo=githubsponsors&logoColor=white&label=Sponsor&color=db61a2)](https://github.com/sponsors/Nagatatz)

> このファイルは英語版 [`README.md`](./README.md) の翻訳です。`README.md` が正（canonical）であり、英語版を更新した際は本ファイルも同じ変更内で更新します。

ブログ記事や任意の React ページに組み込める、**JPYC（日本円ステーブルコイン）投げ銭ウィジェット**です。
ユーザーは MetaMask 経由で Polygon ネットワーク上の JPYC を受取アドレスへ直接送金します。
**サーバーは資金を一切預かりません**（オンチェーン直接送金）。

ReScript で実装され、コンパイル済みの React コンポーネント（`.res.js`）として npm 配布します。

MetaMask が未インストールの環境では、EIP-681 形式の QR コードと受取アドレスを
フォールバック表示し、モバイルウォレット（MetaMask Mobile, Rainbow など）で
読み取って送金できます。

## 特長

- **2 つの見た目（variant）**: `rich`（rose グラデーション + 絵文字の装飾的デザイン）と
  `simple`（白背景・グレー枠・絵文字最小化の素朴なデザイン）を選べます。
- **サーバーレス送金**: オンチェーンで完結。受取は任意のウォレットアドレス。
- **QR フォールバック**: MetaMask 拡張機能が無くてもモバイルウォレットで送金可能。

## 対応ウォレット / チェーン

- ウォレット: MetaMask 拡張機能（メイン）／ EIP-681 対応モバイルウォレット（QR フォールバック）
- チェーン: Polygon mainnet (chainId = 137)
- トークン: JPYC（資金移動業型 / `0xE7C3D8C9a439feDe00D2600032D5dB0Be71C3c29`）

## インストール

```bash
pnpm add jpyc-tipjar-widget
# react / react-dom は peerDependencies（ホスト側に既存のものを使用）
```

`viem` と `qrcode.react` は本パッケージの依存として自動的に入ります。

## 使い方

### JS / TS（React）から

```jsx
import TipJar from "jpyc-tipjar-widget"

export default function Article() {
  return (
    <article>
      {/* rich（既定） */}
      <TipJar />

      {/* simple レイアウト + 受取アドレスを明示 */}
      <TipJar variant="simple" recipientAddress="0x..." />
    </article>
  )
}
```

### ReScript から

ReScript プロジェクトでは binding を 1 つ用意して `default` export を取り込みます。

```rescript
@module("jpyc-tipjar-widget") @react.component
external make: (
  ~recipientAddress: string=?,
  ~variant: [#rich | #simple]=?,
) => React.element = "default"

let default = make
```

```rescript
// 利用側
<TipJarWidget variant=#simple />
```

### プロップス

| プロップ | 型 | 既定 | 説明 |
|---------|-----|------|------|
| `recipientAddress` | `string`（任意） | 環境変数 | 受取ウォレットアドレス。省略時は `NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS` を使用 |
| `variant` | `"rich" \| "simple"`（任意） | `"rich"` | 見た目テーマ |

## 環境変数

利用側（ホスト）アプリのビルド時に `process.env.NEXT_PUBLIC_*` がインライン展開されます。
ホストの `.env.local` に以下を設定してください。

```
NEXT_PUBLIC_ALCHEMY_API_KEY=...
NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS=0x...
```

- `NEXT_PUBLIC_ALCHEMY_API_KEY`: Alchemy で発行した Polygon mainnet 用の API Key
- `NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS`: 投げ銭を受け取るウォレットアドレス

サンプルは `.env.local.example` を参照。

## Tailwind CSS について

本ウィジェットは Tailwind のユーティリティクラスでスタイリングされています。
利用側が Tailwind を使う場合、**ウィジェットのクラスもスキャン対象に含めてください**。

```js
// tailwind.config.js（利用側）
module.exports = {
  content: [
    './src/**/*.{js,jsx,res.js}',
    './node_modules/jpyc-tipjar-widget/**/*.js', // ← 追加
  ],
}
```

## QR フォールバックの仕様

- スキーム: [EIP-681](https://eips.ethereum.org/EIPS/eip-681)
- 形式: `ethereum:<JPYC>@137/transfer?address=<recipient>&uint256=<amount-wei>`
- 金額の有無:
  - プリセット選択中 / カスタム入力済み: `uint256` クエリ付き
  - 未入力: クエリなし（ウォレット側で入力）
- 描画: `qrcode.react` の `QRCodeSVG`（純 SVG, SSR セーフ）

## ディレクトリ構成

```
src/
├── Entry.res          # 公開エントリ（default export, ~variant 受け口）
├── Theme.res          # variant ごとのスタイル集約
├── bindings/          # 外部ライブラリ最小バインディング（Viem / BrowserEthereum / QRCode / Clipboard）
├── domain/            # 純粋な値・ロジック（Chain / Jpyc / TipAmount / PaymentUri）
├── effects/           # 副作用（WalletProvider 抽象 / MetaMaskProvider）
└── components/        # UI（TipJar / AmountSelector / ConnectButton / TxStatus / QrFallback）
```

## 開発

```bash
pnpm install
pnpm build      # rescript build（in-source で .res.js を生成）
pnpm clean      # 生成物を削除
```

## 公開（npm publish）手順

```bash
# 1. バージョンを更新（package.json の version）
# 2. ビルド込みで publish（prepublishOnly が clean + build を実行）
npm publish --access public   # 初回（public スコープ）
```

`files` 指定によりコンパイル済み `.res.js` と `.res` ソースが同梱されます。

## 注意事項：旧 JPYC との混同に注意

以下のアドレスは**別物**です。誤って使用しないでください。

- `0x431D5dfF03120AFA4bDf332c61A6e1766eF37BDB` — 旧 JPYC v2 → JPYC Prepaid にリブランド済み
- `0x2370f9d504c7a6E775bf6E14B3F12846b594cD53` — v1 (Ethereum)

本ウィジェットは正式な資金移動業型 JPYC（`0xE7C3D8C9a439feDe00D2600032D5dB0Be71C3c29`）のみを対象とします。

## ライセンス

MIT
