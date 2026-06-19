# Quick Start

This guide walks you through embedding the tip jar after installation.

## Prerequisites

- Completed [Installation](installation.md)
- `NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS` set, or a recipient address ready to pass as a prop

## Embed the widget

Import the default export and render it anywhere in a React tree:

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

## Use from ReScript

In a ReScript project, declare one binding to the `default` export:

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

## How a tip flows

1. The visitor picks a preset amount or enters a custom one.
2. With MetaMask installed, they connect and send JPYC on Polygon directly to the recipient.
3. Without MetaMask, an EIP-681 QR code is shown; a mobile wallet scans it to send.

The server never custodies funds — every transfer is on-chain and direct.

## What's Next?

- [Configuration](configuration.md) — Props and environment variables
- [Changelog](changelog.md) — See what's new
