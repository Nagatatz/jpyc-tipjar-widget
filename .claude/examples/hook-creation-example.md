# Hook 作成模範例

`.claude/hooks/<name>.sh` と `.claude/settings.json` への登録の作り方を示す。本テンプレートで配布される 7 hooks（`check-secrets.sh` 等）と同水準。

## 仕組み

Hooks は **Claude Code が決定論的に実行するシェルスクリプト**。CLAUDE.md などのルールは LLM への助言だが、hooks は LLM を経由せず必ず実行される。「絶対に毎回必要な処理」「ガードレール」「副作用付きの自動化」に向く。

## ライフサイクル発火点

| 発火点 | タイミング | 用途例 |
|-------|----------|-------|
| `PreToolUse` | ツール実行直前 | コマンド検証、シークレット検出、許可制御 |
| `PostToolUse` | ツール実行直後 | テスト・lint 自動実行、ログ記録 |
| `PreCompact` | コンテキスト圧縮直前 | セッション状態の保存 |
| `Stop` | セッション終了時 | 未完了タスクの警告、後片付け |
| `SessionStart` | セッション開始時 | 環境情報表示、welcome message |
| `Notification` | Claude が注意を要するとき | デスクトップ通知 |

## ファイル構成

```
.claude/
├── hooks/<name>.sh      # 本体（実行権限要）
└── settings.json        # 発火点に登録
```

## スクリプト雛形

```bash
#!/bin/bash
# <name>.sh — <hook の目的を 1 行で>
#
# 発火点: <PreToolUse Bash / PreToolUse Edit|Write 等>
# 引数: stdin に JSON が渡される（Claude Code が決定）
# 戻り値: 0 = 続行、非 0 = ブロック（PreToolUse の場合）

set -euo pipefail

# stdin から JSON を読み込み（必要なフィールドを jq で抽出）
input=$(cat)

# 例: PreToolUse Bash の場合、tool_input.command を取り出す
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# 検査ロジック
if echo "$command" | grep -qE '<禁止パターン>'; then
  echo "BLOCKED: <理由>" >&2
  exit 1
fi

# 続行
exit 0
```

## settings.json への登録

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/<name>.sh"
          }
        ]
      }
    ]
  }
}
```

- `matcher` はツール名の正規表現（`Bash` / `Edit|Write` / `.*` 等）
- `command` は `$CLAUDE_PROJECT_DIR` を起点とした絶対パスにする
- `timeout` を指定可能（秒数、デフォルト 30）

## 完成例: check-secrets.sh の構造

本テンプレートに同梱されている `.claude/hooks/check-secrets.sh` は以下のパターンを採用:

1. **stdin から `tool_input.content` を抽出**
2. **正規表現でシークレットパターンを検出**（OpenAI / Anthropic API key, GitHub PAT, PEM 等）
3. **オプトアウトコメント `# claude-allow-secret` を含む場合はスキップ**
4. **検出時は標準エラーに理由を出力して exit 1**

## 設計原則

### ✅ Hooks に向く

- **絶対に毎回必要な処理:** シークレット検出、破壊コマンド阻止
- **副作用付き自動化:** ファイル書き込み後の自動 format / lint
- **ガードレール:** policy 違反のブロック

### ❌ Hooks に向かない

- **判断が必要な処理:** LLM の理解を要するもの（→ skill / rule に書く）
- **柔軟性が必要なもの:** 状況により振る舞いを変えたい（→ skill に分離）
- **長時間処理:** タイムアウトが厳しい（標準 30 秒）

## エラーハンドリング

- `set -euo pipefail` を必ず付与（早期失敗）
- 期待外の状況では「続行」を選ぶ（exit 0）。Hook の故障で Claude Code 全体が止まるのを避ける
- 真にブロックすべきケースのみ exit 1

## テスト方法

hook はインタラクティブに動かしにくいので、stdin に test JSON を流して単体テストする:

```bash
echo '{"tool_input":{"command":"rm -rf /"}}' | bash .claude/hooks/validate-bash.sh
echo $?   # 0 (続行) or 非 0 (block) を確認
```

## 関連

- `.claude/settings.json` — 実際の発火点登録
- `.claude/rules/bash-safety.md` (skill) — validate-bash.sh と連動
- 公式: [Hooks ガイド](https://code.claude.com/docs/en/hooks-guide)
