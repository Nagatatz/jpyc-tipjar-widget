# Project Structure

## Top-Level Layout

```
jpyc-tipjar-widget/
├── src/                  # Source code
├── docs/                 # Internal design documents
├── sphinx-docs/          # Public documentation (Sphinx)
├── .github/workflows/    # CI/CD workflows
└── AGENTS.md             # Development conventions (agent entry point)
```

## Source Code Organization

```
src/
├── Entry.res          # public entry (default export, ~variant prop)
├── Theme.res          # styles aggregated per variant
├── bindings/          # minimal bindings to external libs (Viem / BrowserEthereum / QRCode / Clipboard)
├── domain/            # pure values and logic (Chain / Jpyc / TipAmount / PaymentUri)
├── effects/           # side effects (WalletProvider abstraction / MetaMaskProvider)
└── components/        # UI (TipJar / AmountSelector / ConnectButton / TxStatus / QrFallback)
```

ReScript compiles in-source, so each `.res` file has a sibling `.res.js`. See
[Architecture](architecture.md) for the responsibility of each layer.

## Bilingual documentation

Documentation is bilingual (English + Japanese). English is the source of truth and
Japanese follows in the same change:

- `README.md` (English, canonical) ↔ `README.ja.md` (Japanese)
- `sphinx-docs/` English sources ↔ `sphinx-docs/locale/ja/` `.po` translations
  (run `make update-po` after editing the English sources)

