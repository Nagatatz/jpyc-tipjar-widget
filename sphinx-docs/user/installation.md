# Installation

## Requirements

- **React 19+** — the host application provides `react` and `react-dom` (they are `peerDependencies`).
- **A wallet** — the MetaMask browser extension, or any EIP-681-capable mobile wallet (MetaMask Mobile, Rainbow, etc.) for the QR fallback.
- **Polygon mainnet** — transfers settle on Polygon (chainId 137).
- **An Alchemy API key** — a Polygon mainnet API key, set as an environment variable in the host app.

## Install

Add the package with your package manager:

```bash
pnpm add jpyc-tipjar-widget
# react / react-dom are peerDependencies and must already exist in the host app
```

`viem` and `qrcode.react` are installed automatically as dependencies.

## Configure environment variables

`process.env.NEXT_PUBLIC_*` values are inlined at the host app's build time. Set the
following in the host's `.env.local`:

```
NEXT_PUBLIC_ALCHEMY_API_KEY=...
NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS=0x...
```

- `NEXT_PUBLIC_ALCHEMY_API_KEY` — an Alchemy API key for Polygon mainnet.
- `NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS` — the wallet address that receives tips.

## Tailwind CSS

The widget is styled with Tailwind utility classes. If the host app uses Tailwind,
include the widget's classes in the scan targets:

```js
// tailwind.config.js (host app)
module.exports = {
  content: [
    './src/**/*.{js,jsx,res.js}',
    './node_modules/jpyc-tipjar-widget/**/*.js', // add this
  ],
}
```

## Verify

Render the widget in a page and confirm it mounts:

```jsx
import TipJar from "jpyc-tipjar-widget"

export default function Page() {
  return <TipJar />
}
```

If MetaMask is installed you should see the connect button; otherwise the EIP-681
QR fallback is shown.

## Troubleshooting

- **The widget is unstyled** — confirm the Tailwind `content` globs include
  `node_modules/jpyc-tipjar-widget/**/*.js`.
- **The recipient address is missing** — pass `recipientAddress` as a prop or set
  `NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS`.
- **No QR code appears and MetaMask is absent** — verify the recipient address is a
  valid Polygon address; the QR encodes an EIP-681 URI for that address.
