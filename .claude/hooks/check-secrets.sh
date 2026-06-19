#!/usr/bin/env bash
# PreToolUse Edit/Write hook — シークレットらしき文字列のコミット混入を防ぐ
# 検出されたら deny、`# claude-allow-secret` がコンテンツに含まれていれば許可

set -euo pipefail

input=$(cat)

# 検査対象は Edit の new_string、Write の content
content=$(printf "%s" "$input" | jq -r '.tool_input.new_string // .tool_input.content // empty' 2>/dev/null || true)

if [ -z "$content" ]; then
  exit 0
fi

# 明示的なオプトアウト（コンテンツに `claude-allow-secret` が含まれていれば検査スキップ）
if printf "%s" "$content" | grep -q "claude-allow-secret"; then
  exit 0
fi

# 高信頼パターン（誤検知が少ないもの）
patterns=(
  'AKIA[0-9A-Z]{16}'                          # AWS Access Key ID
  'ghp_[A-Za-z0-9]{36}'                       # GitHub PAT (classic)
  'github_pat_[A-Za-z0-9_]{82}'               # GitHub fine-grained PAT
  'sk-[A-Za-z0-9]{32,}'                       # OpenAI / Anthropic-like keys
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'        # PEM private keys
)

for pattern in "${patterns[@]}"; do
  if printf "%s" "$content" | grep -qE -- "$pattern"; then
    matched=$(printf "%s" "$content" | grep -oE -- "$pattern" | head -1)
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"シークレットらしき文字列が検出されました（パターン: %s, 一致: %s...）。本当に書き込む場合は、編集対象のコンテンツに「# claude-allow-secret」コメントを含めてください。"}}\n' "$pattern" "${matched:0:8}"
    exit 0
  fi
done

# 汎用パターン（key/secret/token = "..." または ": ..." 形式の長い値）
generic_pattern='\b(api[_-]?key|secret|password|token)[^=:]{0,8}[=:][^=:]{0,4}["'\''`][A-Za-z0-9_/+=.-]{16,}["'\''`]'
if printf "%s" "$content" | grep -qiE -- "$generic_pattern"; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"汎用シークレットパターン (api_key/secret/password/token = \"...\") が検出されました。コンテンツに「# claude-allow-secret」コメントを含めてオプトアウトできます。"}}\n'
  exit 0
fi

exit 0
