# Changelog

## Unreleased

<!-- Add changes for the next release here -->

### Added

-

### Changed

-

### Fixed

-

## 0.1.3 (2026-06-19)

### Changed

- Add an npm version badge to the README. Documentation only; the published widget is identical to 0.1.2 (this release exists so the badge appears on the npm package page).

## 0.1.2 (2026-06-19)

### Changed

- Add `repository`, `homepage`, and `bugs` fields to `package.json` so the npm page links back to the source and provenance verification passes.

### Removed

- Remove the internal Vite demo harness used for variant screenshots (it was never part of the published package).

### Internal

- Bump GitHub Actions to Node 24 runtimes (checkout v7, setup-node v6, setup-uv v7, upload-pages-artifact v5, deploy-pages v5, upload-artifact v7).

## 0.1.1 (2026-06-19)

### Changed

- Documentation only: add CI (Docs/Release) and GitHub Sponsors badges to the README. No code changes; the published widget is identical to 0.1.0.

## 0.1.0

### Added

- Initial release of the JPYC tip jar widget.
- `rich` and `simple` layout variants.
- Server-less on-chain JPYC transfer on Polygon via MetaMask.
- EIP-681 QR code fallback for mobile wallets when MetaMask is absent.

<!-- Template for new releases:

## x.y.z (YYYY-MM-DD)

### Added
- New feature description

### Changed
- Changed behavior description

### Fixed
- Bug fix description

### Removed
- Removed feature description
-->
