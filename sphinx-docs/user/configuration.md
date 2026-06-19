# Configuration

The widget is configured through component props and host-app environment variables.

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `recipientAddress` | `string` (optional) | env var | Receiving wallet address. Falls back to `NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS` when omitted. |
| `variant` | `"rich" \| "simple"` (optional) | `"rich"` | Visual theme. `rich` is a decorative rose-gradient design with emoji; `simple` is a plain design with a white background and gray border. |

## Environment variables

Set these in the host app (inlined at build time as `process.env.NEXT_PUBLIC_*`):

| Variable | Required | Description |
|----------|----------|-------------|
| `NEXT_PUBLIC_ALCHEMY_API_KEY` | Yes | Alchemy API key for Polygon mainnet. |
| `NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS` | When `recipientAddress` prop is omitted | Wallet address that receives tips. |

## Network and token

These are fixed by the widget and not configurable:

| Item | Value |
|------|-------|
| Chain | Polygon mainnet (chainId 137) |
| Token | JPYC (money-transfer-business type) `0xE7C3D8C9a439feDe00D2600032D5dB0Be71C3c29` |
| QR scheme | [EIP-681](https://eips.ethereum.org/EIPS/eip-681) |
