# Building

The widget is written in ReScript and compiled in-source to `.res.js` files that are
published to npm.

## Build Commands

| Command | Description |
|---------|-------------|
| `pnpm build` | Compile ReScript to `.res.js` (`rescript build`). |
| `pnpm clean` | Remove generated build artifacts (`rescript clean`). |
| `pnpm clean && pnpm build` | Clean rebuild. |

The ReScript build doubles as the type check — there is no separate typecheck step.

## Output

`.res.js` files are emitted next to their `.res` sources (in-source compilation).
The npm package bundles the compiled `.res.js`, the `.res`/`.resi` sources, `README.md`,
`README.ja.md`, and `LICENSE` (see the `files` field in `package.json`).

## Publishing

```bash
# 1. Bump the version in package.json
# 2. Publish (prepublishOnly runs `rescript clean && rescript build`)
npm publish --access public
```

## CI Pipeline

GitHub Actions templates are provided under `.github/workflows/` (Claude code review,
auto PR description, quality measurement, and the documentation site build). Activate
them by removing the `.template` suffix and configuring the required secrets.
