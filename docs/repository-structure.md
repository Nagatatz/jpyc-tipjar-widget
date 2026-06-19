# リポジトリ構造定義書

> **配布先プロジェクトでの編集を前提とした雛形です。** 自プロジェクトの実構成に合わせて全面的に書き換えてください。CLAUDE.md.template の `@docs/repository-structure.md` から参照されるため、削除は非推奨です。

## プロジェクト構成（テンプレート例）

```
<project-root>/
├── CLAUDE.md                   # Claude Code の常時ロードコンテキスト
├── .claude/
│   ├── agents/                 # サブエージェント定義
│   ├── commands/               # スラッシュコマンド
│   ├── examples/               # ゴールドスタンダード参考集
│   ├── hooks/                  # ライフサイクル hook スクリプト
│   ├── output-styles/          # 出力スタイル
│   ├── rules/                  # 常時 @import されるルール
│   ├── settings.json           # 権限・hook 登録・statusLine 設定
│   ├── skills/                 # 状況発火型スキル
│   └── statusline.sh           # statusLine コマンド
├── docs/                       # 永続的設計ドキュメント
├── sphinx-docs/                # 外部公開ユーザードキュメント (任意)
├── src/                        # ソースコード（言語に応じて配置）
└── tests/                      # ユニット・統合テスト
```

## レイヤー責務

配布先プロジェクトでは、上記テンプレート例を参考に、実際のディレクトリ構成・レイヤー責務・依存方向の説明を追記してください。例:

- **`src/domain/`** — ドメインモデル。外部 I/O から独立
- **`src/application/`** — ユースケース層。`domain/` のみに依存
- **`src/infrastructure/`** — 外部 I/O 実装（DB / API / FS）

## 主要ファイルの役割

| ファイル | 役割 |
|---------|------|
| `CLAUDE.md` | Claude Code 用の常時コンテキスト。`@import` で `.claude/rules/` をロード |
| `.claude/settings.json` | hooks 登録 / 権限 / statusLine 設定 |
| `.steering/<日付>-<連番>-<タイトル>/` | 作業単位のステアリングドキュメント |
| `docs/product-requirements.md` | プロダクト要求定義書（任意） |
| `docs/architecture.md` | 技術仕様書（任意） |

## 関連ドキュメント

- `.claude/rules/documentation.md` — ドキュメント管理規約
- `.claude/rules/steering-workflow.md` — ステアリングワークフロー
