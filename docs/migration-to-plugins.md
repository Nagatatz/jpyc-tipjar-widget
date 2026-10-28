# プラグイン移行設計メモ

> **ステータス（2026-07-02）: 第一歩 実施済み（v1.1.0）。** `.claude-plugin/plugin.json` と `.claude-plugin/marketplace.json`、および plugin 用 `.claude/hooks/hooks.json` を追加し、本リポジトリを単一プラグインの marketplace として `/plugin install` 可能にした。**コンポーネントは `.claude/` 構成を維持**し、plugin.json のカスタムパス（`skills`/`commands`/`agents`/`outputStyles` は `string|array` 型で `./` 相対の任意パスを受け付ける — plugins-reference.md）で宣言している。移設は行っていない。install.sh 配布は**縮退させず併存**（下記「移行優先度」参照）。

本テンプレートは `install.sh` 経由で `.claude/skills/`, `.claude/commands/`, `.claude/rules/`, `.claude/hooks/`, `.claude/statusline.sh`, `AGENTS.md.template`, `.mcp.json.template`, `.github/...` などを配布している。Claude Code 公式は `/plugin` コマンドおよび marketplace 経由のプラグイン配布を推奨しており、plugin 化することで以下の利点が得られる。

## 現状（install.sh）の課題

- 配布スクリプトの肥大化（`install.sh` は現在 ~540 行）
- 配布先で **再 install** しないと更新が反映されない
- 配布先側での個別ファイル管理が必要
- 依存関係の解決が手動

## plugin 化のメリット

- `/plugin install <name>` で一発インストール
- バージョン管理と自動更新
- 他チームへの再配布性（marketplace 公開）
- skill / hook / agent / command のメタデータが統一管理

## 移行ステップ

1. ✅ **`.claude-plugin/plugin.json`** を新設（実施済み）
   - `name` / `displayName` / `version` / `description` / `author` / `homepage` / `repository` / `license` / `keywords`
   - コンポーネントはカスタムパスで `.claude/` を指す（`skills`/`commands`/`agents`/`outputStyles`）、`hooks` は `./.claude/hooks/hooks.json`
2. ✅ **`.claude-plugin/marketplace.json`** を新設（実施済み）
   - 本リポジトリを単一プラグインとして配布（`source: "./"`）
3. ⬜ **`install.sh` の縮退**（未実施・別フェーズ）
   - skill/hook/command の配布ロジックを plugin に肩代わりさせ、AGENTS.md.template / .mcp.json.template / sphinx-docs / .github / .devcontainer の「**プロジェクトファイル系**」配布のみ残す
   - 既存 downstream への影響（旧 `.claude/skills/` を残すか削除するか）が大きいため、install.sh は当面併存

## 縮退判断（2026-08-07 再調査）

**結論: `install.sh` の縮退は見送る。** plugin 機能自体は十分成熟しており第一歩（marketplace 配布）は実施済みだが、`install.sh` を置き換えるには至らない。

### 見送る理由

1. **plugin は `CLAUDE.md` / `.claude/rules/` を配布できない**

   > A CLAUDE.md file at the plugin root is not loaded as project context. Plugins contribute context through skills, agents, and hooks rather than CLAUDE.md.
   > — [Plugins reference](https://code.claude.com/docs/en/plugins-reference)

   本テンプレートの中核は rules 層（`definition-of-done` / `testing` ほか）であり、これが配れない以上 `install.sh` は残る。plugin と install.sh は**併存**させる。

2. **スキャフォールディングが配れない**

   `sphinx-docs/` `.github/` `.devcontainer/` `AGENTS.md.template` `quality-datasets/` は plugin の管轄外。

> **ディレクトリ規約の二重管理は回避済み。** plugin は既定でルート直下の `skills/` `agents/` `hooks/` を読むが、本リポジトリは plugin.json のカスタムパスで `.claude/` 配下を指しているため、構成変更も symlink も不要（→ 移行ステップ 1）。

### 今後の検討事項（未実施）

- **dual-loading**: 本リポジトリを clone して project として使う場合は `.claude/` が project スコープで auto-load、plugin として install した場合は `claude-project-template:<name>` で namespaced load。スコープが異なるため衝突しないが、同一環境で両方を有効にすると二重ロードになりうる点に注意。
- plugin 版と install.sh 版で `.claude/rules/`（plugin にフィールドが無い）や AGENTS.md scaffold の扱いが異なる点の整理。

### 参考: 標準的な plugin 構成と操作

再調査コストを下げるため、判明した手順を記録しておく。個人利用なら GitHub 公開は不要で、**ローカルパスの marketplace** で完結する。

```
<repo>/
├── .claude-plugin/
│   └── marketplace.json
└── plugins/
    └── <plugin-name>/
        ├── .claude-plugin/plugin.json   # name, description, version
        ├── skills/<name>/SKILL.md
        ├── agents/*.md
        ├── hooks/hooks.json             # settings.json の hooks オブジェクトと同形式
        ├── .mcp.json
        └── .lsp.json
```

```json
{
  "name": "my-marketplace",
  "plugins": [
    { "name": "my-plugin", "source": "./plugins/my-plugin" }
  ]
}
```

```
/plugin marketplace add ./path/to/repo
/plugin install my-plugin@my-marketplace
/plugin marketplace update          # 更新の取り込み
```

開発中は marketplace を挟まず `claude --plugin-dir ./plugins/my-plugin` で読み込める。`/reload-plugins` で再読込。`claude plugin validate ./plugins/my-plugin` で構成を検証できる。

`claude plugin init <name>` を使うと `~/.claude/skills/<name>/` に plugin 一式が作られ、marketplace もインストール操作も無しに `<name>@skills-dir` として自動ロードされる。個人用途で全プロジェクトに効かせたいだけなら、こちらが最短。

### 移行するときの注意

- plugin skill は `/<plugin-name>:<skill-name>` と名前空間が付く。`.claude/skills/` の同名 skill は**上書きされず併存**するため、移行後は元ファイルを削除する
- `.claude/agents/` の同名 agent は plugin 版を**上書きする**ため、こちらも元ファイルの削除が必要

## 関連

- 公式: [Plugins reference](https://code.claude.com/docs/en/plugins-reference)
- 公式: [Discover and install prebuilt plugins through marketplaces](https://code.claude.com/docs/en/discover-plugins)
- 公式: [Create and distribute a plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces)
