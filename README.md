# jpyc-tipjar-widget

**Language: English (this file) | [日本語](./README.ja.md)**

A **JPYC (Japanese-yen stablecoin) tip jar widget** you can embed in a blog post or
any React page. Users send JPYC on the Polygon network directly to your receiving
address via MetaMask. **The server never custodies funds** (on-chain direct transfer).

Implemented in ReScript and distributed on npm as compiled React components (`.res.js`).

When MetaMask is not installed, the widget falls back to an EIP-681 QR code plus the
receiving address, which mobile wallets (MetaMask Mobile, Rainbow, etc.) can scan to
complete the transfer.

## Features

- **Two visual variants**: `rich` (decorative rose-gradient design with emoji) and
  `simple` (plain design — white background, gray border, minimal emoji).
- **Serverless transfers**: settled fully on-chain; the recipient is any wallet address.
- **QR fallback**: transfers work from a mobile wallet even without the MetaMask extension.

## Supported wallets / chains

- Wallets: MetaMask extension (primary) / EIP-681-capable mobile wallets (QR fallback)
- Chain: Polygon mainnet (chainId = 137)
- Token: JPYC (money-transfer-business type / `0xE7C3D8C9a439feDe00D2600032D5dB0Be71C3c29`)

## Installation

```bash
pnpm add jpyc-tipjar-widget
# react / react-dom are peerDependencies (the host app provides them)
```

`viem` and `qrcode.react` are installed automatically as dependencies of this package.

## Usage

### From JS / TS (React)

```jsx
import TipJar from "jpyc-tipjar-widget"

export default function Article() {
  return (
    <article>
      {/* rich (default) */}
      <TipJar />

      {/* simple layout + explicit recipient address */}
      <TipJar variant="simple" recipientAddress="0x..." />
    </article>
  )
}
```

### From ReScript

In a ReScript project, declare one binding to import the `default` export.

```rescript
@module("jpyc-tipjar-widget") @react.component
external make: (
  ~recipientAddress: string=?,
  ~variant: [#rich | #simple]=?,
) => React.element = "default"

let default = make
```

```rescript
// call site
<TipJarWidget variant=#simple />
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `recipientAddress` | `string` (optional) | env var | Receiving wallet address. Falls back to `NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS` when omitted |
| `variant` | `"rich" \| "simple"` (optional) | `"rich"` | Visual theme |

## Environment variables

`process.env.NEXT_PUBLIC_*` values are inlined at the host app's build time.
Set the following in the host's `.env.local`:

```
NEXT_PUBLIC_ALCHEMY_API_KEY=...
NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS=0x...
```

- `NEXT_PUBLIC_ALCHEMY_API_KEY`: an Alchemy API key for Polygon mainnet
- `NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS`: the wallet address that receives tips

See `.env.local.example` for a sample.

## About Tailwind CSS

This widget is styled with Tailwind utility classes. If the host app uses Tailwind,
**include the widget's classes in the scan targets** as well.

```js
// tailwind.config.js (host app)
module.exports = {
  content: [
    './src/**/*.{js,jsx,res.js}',
    './node_modules/jpyc-tipjar-widget/**/*.js', // <- add this
  ],
}
```

## QR fallback specification

- Scheme: [EIP-681](https://eips.ethereum.org/EIPS/eip-681)
- Format: `ethereum:<JPYC>@137/transfer?address=<recipient>&uint256=<amount-wei>`
- Amount handling:
  - Preset selected / custom amount entered: includes the `uint256` query
  - Not entered: no query (the wallet prompts for the amount)
- Rendering: `QRCodeSVG` from `qrcode.react` (pure SVG, SSR-safe)

## Directory layout

```
src/
├── Entry.res          # public entry (default export, ~variant prop)
├── Theme.res          # styles aggregated per variant
├── bindings/          # minimal bindings to external libs (Viem / BrowserEthereum / QRCode / Clipboard)
├── domain/            # pure values and logic (Chain / Jpyc / TipAmount / PaymentUri)
├── effects/           # side effects (WalletProvider abstraction / MetaMaskProvider)
└── components/        # UI (TipJar / AmountSelector / ConnectButton / TxStatus / QrFallback)
```

## Development

```bash
pnpm install
pnpm build      # rescript build (emits .res.js in-source)
pnpm clean      # remove build artifacts
```

## Publishing (npm publish)

```bash
# 1. Bump the version (package.json `version`)
# 2. Publish with a build (prepublishOnly runs clean + build)
npm publish --access public   # first time (public scope)
```

The `files` field bundles the compiled `.res.js` and the `.res` sources.

## Note: do not confuse with legacy JPYC

The following addresses are **different tokens**. Do not use them by mistake.

- `0x431D5dfF03120AFA4bDf332c61A6e1766eF37BDB` — former JPYC v2, rebranded to JPYC Prepaid
- `0x2370f9d504c7a6E775bf6E14B3F12846b594cD53` — v1 (Ethereum)

This widget targets only the official money-transfer-business JPYC
(`0xE7C3D8C9a439feDe00D2600032D5dB0Be71C3c29`).

## License

MIT
