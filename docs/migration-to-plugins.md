# プラグイン移行設計メモ

本テンプレートは現在 `install.sh` 経由で `.claude/skills/`, `.claude/commands/`, `.claude/rules/`, `.claude/hooks/`, `.claude/statusline.sh`, `CLAUDE.md.template`, `.mcp.json.template`, `.github/...` などを配布している。Claude Code 公式は `/plugin` コマンドおよび marketplace 経由のプラグイン配布を推奨しており、長期的には本テンプレートも plugin 化することで以下の利点が得られる。

## 現状（install.sh）の課題

- 配布スクリプトの肥大化（`install.sh` 200 行超）
- 配布先で **再 install** しないと更新が反映されない
- 配布先側での個別ファイル管理が必要
- 依存関係の解決が手動

## plugin 化のメリット

- `/plugin install <name>` で一発インストール
- バージョン管理と自動更新
- 他チームへの再配布性（marketplace 公開）
- skill / hook / agent / command のメタデータが統一管理

## 想定移行ステップ

1. **`.claude-plugin/plugin.json`** をリポジトリルートに新設
   - `name`, `description`, `version`, `author`, `provides` (skills, hooks, commands, agents)
2. **`.claude-plugin/marketplace.json`**（オプション）
   - 自分がマーケットプレイスホスティングする場合
3. **`install.sh` を縮退**
   - skill/hook/command の配布ロジックは plugin が肩代わり
   - CLAUDE.md.template / .mcp.json.template / sphinx-docs / .github / .devcontainer の「**プロジェクトファイル系**」配布のみ残す
4. **配布先での導入手順**
   ```bash
   /plugin install claude-project-template
   # CLAUDE.md / sphinx-docs 等は別途 install.sh --no-claude-md --no-skill から
   ```

## 移行優先度

- **本フェーズではスコープ外**。実装は将来検討事項。
- `install.sh` ベースの安定運用を優先し、plugin marketplace 機能の成熟と公式ドキュメントの安定化を待つ
- 移行時には既存配布先への影響（旧 `.claude/skills/` を残すか削除するか）を別途検討

## 関連

- 公式: [Plugins reference](https://code.claude.com/docs/en/plugins-reference)
- 公式: [Discover and install prebuilt plugins through marketplaces](https://code.claude.com/docs/en/discover-plugins)
- 公式: [Create and distribute a plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces)
