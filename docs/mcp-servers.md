# MCP サーバー設定ガイド

[Model Context Protocol (MCP)](https://modelcontextprotocol.io) は AI ツールを外部データソースに接続するためのオープンスタンダード。Claude Code では `.mcp.json`（プロジェクトスコープ）/ `~/.claude.json`（ユーザースコープ）/ コマンドラインオプション（ローカル）で MCP サーバーを定義できる。

## このテンプレートが提供するもの

- `.mcp.json.template`: 最小空構成のテンプレート（`{"mcpServers": {}}`）
- このドキュメント: よく使う MCP サーバーの設定例

`.mcp.json` 自体は `.gitignore` 対象。配布先で `cp .mcp.json.template .mcp.json` してから個別に編集する。

## スコープの使い分け

| スコープ | パス | 共有範囲 |
|----------|------|---------|
| **Project** | `<repo>/.mcp.json` | コラボレーター全員（git にコミット） |
| **User** | `~/.claude.json` の `mcpServers` セクション | 個人の全プロジェクト |
| **Local** | `claude mcp add <name> ...` で追加 | このリポジトリ内の自分のみ |

> チーム共有が必要なものだけ Project スコープに置き、API キーなどは User スコープか環境変数経由にする。

## よく使うサーバー設定例

### filesystem — ローカルファイルシステム操作

`@modelcontextprotocol/server-filesystem` を使うと、Claude Code が指定ディレクトリ内のファイルを構造化して読み書きできる。

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    }
  }
}
```

### sequential-thinking — 段階的思考

`@modelcontextprotocol/server-sequential-thinking` は推論を多段階に分解して実行するためのサーバー。

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```

### github — GitHub Issue / PR 操作

`@modelcontextprotocol/server-github` は GitHub API をラップし、Issue や PR の検索・作成を Claude から直接実行できる。`GITHUB_PERSONAL_ACCESS_TOKEN` 環境変数が必要。

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}
```

### 複数サーバーを併用する場合

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}
```

## 有効化と確認

1. `.mcp.json.template` を `.mcp.json` にコピーし、必要なサーバーを追加
2. Claude Code を再起動（または `claude mcp list` で認識確認）
3. セッション内で `/mcp` を実行し、起動済みサーバーを確認

## 関連ドキュメント

- [Connect Claude Code to tools via MCP（公式 ja）](https://code.claude.com/docs/ja/mcp)
- [Model Context Protocol 仕様](https://modelcontextprotocol.io)
- [MCP サーバーリスト](https://github.com/modelcontextprotocol/servers)
