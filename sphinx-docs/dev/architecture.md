# Architecture

## Overview

The widget is a self-contained React component compiled from ReScript. It performs a
**server-less, on-chain direct transfer**: the visitor sends JPYC on Polygon straight
to the recipient's wallet, and no backend ever custodies funds. When MetaMask is
unavailable, it degrades to an EIP-681 QR code that mobile wallets can scan.

## Key Components

The source is organized into layers under `src/`:

| Layer | Responsibility |
|-------|----------------|
| `Entry.res` | Public entry point — the `default` export and the `~variant` prop. |
| `Theme.res` | Styles aggregated per variant (`rich` / `simple`). |
| `bindings/` | Minimal bindings to external libraries: `Viem`, `BrowserEthereum`, `QRCode`, `Clipboard`. |
| `domain/` | Pure values and logic: `Chain`, `Jpyc`, `TipAmount`, `PaymentUri`. No side effects. |
| `effects/` | Side effects: the `WalletProvider` abstraction and its `MetaMaskProvider` implementation. |
| `components/` | UI: `TipJar`, `AmountSelector`, `ConnectButton`, `TxStatus`, `QrFallback`. |

## Design Principles

1. **Server-less / non-custodial** — every transfer is on-chain and direct; the
   recipient is any wallet address.
2. **Layered purity** — `domain/` holds pure logic, `effects/` isolates side effects,
   and `bindings/` keeps external-library surface area minimal.
3. **Graceful fallback** — without MetaMask, the widget still works via an EIP-681 QR
   code, so mobile-wallet users are never blocked.

## Transfer flow

```{mermaid}
graph TD
    A[Visitor] --> B[AmountSelector]
    B --> C{MetaMask available?}
    C -->|Yes| D[ConnectButton → MetaMaskProvider]
    D --> E[viem: JPYC transfer on Polygon]
    E --> F[TxStatus]
    C -->|No| G[QrFallback: EIP-681 QR]
    G --> H[Mobile wallet sends transfer]
```

## QR fallback specification

- Scheme: [EIP-681](https://eips.ethereum.org/EIPS/eip-681)
- Format: `ethereum:<JPYC>@137/transfer?address=<recipient>&uint256=<amount-wei>`
- Amount handling: a preset or custom amount includes the `uint256` query; when no
  amount is entered the query is omitted and the wallet prompts for it.
- Rendering: `QRCodeSVG` from `qrcode.react` (pure SVG, SSR-safe).
