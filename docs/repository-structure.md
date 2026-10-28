# リポジトリ構造

利用者・コントリビューター向けの説明は `sphinx-docs/dev/project-structure.md`（英語、日本語は `.po`）と `sphinx-docs/dev/architecture.md` にある。本ファイルはエージェントが作業で使う置き場所の早見表。

```
jpyc-tipjar-widget/
├── AGENTS.md          # エージェント共通の入口（概要・コマンド・ルール索引）
├── CLAUDE.md          # `@AGENTS.md` の 1 行だけ
├── src/               # ReScript ソース（in-source でコンパイルし、隣に .res.js ができる）
│   ├── Entry.res      # 公開口（default export、~variant prop）
│   ├── Theme.res      # variant ごとのスタイル
│   ├── bindings/      # 外部ライブラリへの最小限の binding（Viem / BrowserEthereum / QRCode / Clipboard）
│   ├── domain/        # 純粋な値とロジック（Chain / Jpyc / TipAmount / PaymentUri）
│   ├── effects/       # 副作用（WalletProvider の抽象と MetaMaskProvider）
│   └── components/    # UI（TipJar / AmountSelector / ConnectButton / TxStatus / QrFallback）
├── sphinx-docs/       # 公開ドキュメント（英語ソース + locale/ja/）
├── docs/              # 開発者向けの設計メモ
├── scripts/           # 規約ファイルの点検（check-references.sh / measure-context-cost.sh ほか）
├── quality-datasets/  # skill / agent の発火を測るデータセット
├── .claude/           # rules・skills・agents・commands・hooks・settings
├── .agents/skills     # `.claude/skills` への symlink（Codex など `.agents/skills` を読むエージェント向け）
└── .github/workflows/ # docs.yml（Pages）・release.yml（npm publish）
```

## 主要ファイルの役割

| ファイル | 役割 |
|---|---|
| `AGENTS.md` | エージェント共通の入口。概要・コマンド・`.claude/rules/` の索引だけを置く |
| `CLAUDE.md` | `@AGENTS.md` の 1 行だけ（repo 直下に `CLAUDE.md` が無いと Claude Code が `AGENTS.md` を読まなかったため。理由は `AGENTS.md` の「入口ファイル」） |
| `.claude/rules/*.md` | 規約の本文。`paths:` の無いものは常時、あるものは一致するファイルを扱うときにロードされる |
| `.claude/settings.json` | hooks 登録・権限・statusLine |
| `.github/workflows/release.yml` | `v*` tag の push で npm に publish する（OIDC trusted publishing） |
| `sphinx-docs/user/changelog.md` | 変更履歴。次の版の変更は Unreleased に書く |

作業ごとの計画と完了条件はリポジトリに置かず、GitHub Issue の `## DoD` に書く（→ `.claude/rules/definition-of-done.md`）。
