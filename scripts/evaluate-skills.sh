#!/usr/bin/env bash
# evaluate-skills.sh — empirical-prompt-tuning の評価実行スクリプト
#
# テストデータセット (quality-datasets/<対象>.yaml) の各 prompt を
# claude -p で実行し、結果を quality-reports/<日付>-<対象>.md に出力する。
#
# 使い方:
#   bash scripts/evaluate-skills.sh quality-datasets/<対象>.yaml
#
# 必要な環境:
#   - ANTHROPIC_API_KEY 環境変数
#   - claude CLI (curl -fsSL https://claude.ai/install.sh | bash)
#   - yq があれば優先利用、無ければ awk フォールバック

set -euo pipefail

DATASET="${1:?Usage: $0 <dataset.yaml>}"

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "ERROR: ANTHROPIC_API_KEY is not set" >&2
  echo "Hint: export ANTHROPIC_API_KEY=sk-ant-..." >&2
  exit 1
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "ERROR: claude CLI not found in PATH" >&2
  echo "Install: curl -fsSL https://claude.ai/install.sh | bash" >&2
  exit 1
fi

if [ ! -f "$DATASET" ]; then
  echo "ERROR: dataset not found: $DATASET" >&2
  exit 1
fi

TARGET=$(grep -E "^target:" "$DATASET" | head -1 | awk '{print $2}')
TYPE=$(grep -E "^type:" "$DATASET" | head -1 | awk '{print $2}')
DATE=$(date -u +%Y-%m-%d)
REPORT_DIR="quality-reports"
REPORT_FILE="$REPORT_DIR/${DATE}-${TARGET}.md"

if [ -z "$TARGET" ] || [ -z "$TYPE" ]; then
  echo "ERROR: dataset must define 'target' and 'type' at top level" >&2
  exit 1
fi

mkdir -p "$REPORT_DIR"

cat > "$REPORT_FILE" <<EOF
# Quality Report — $TARGET ($TYPE)

- **Date**: $DATE
- **Dataset**: $DATASET
- **Evaluator**: scripts/evaluate-skills.sh

## Cases

EOF

if command -v yq >/dev/null 2>&1; then
  CASE_COUNT=$(yq '.cases | length' "$DATASET")
else
  CASE_COUNT=$(grep -c "^  - id:" "$DATASET" || true)
fi

if [ "$CASE_COUNT" -eq 0 ]; then
  echo "ERROR: dataset has 0 cases (need at least 1 under 'cases:')" >&2
  exit 1
fi

echo "Found $CASE_COUNT cases. Running..."

for ((i=1; i<=CASE_COUNT; i++)); do
  if command -v yq >/dev/null 2>&1; then
    PROMPT=$(yq ".cases[$((i-1))].prompt" "$DATASET")
    EXPECTED=$(yq ".cases[$((i-1))].expected_invocation" "$DATASET")
  else
    # awk フォールバック: id 順に prompt / expected_invocation を抽出
    PROMPT=$(awk -v idx="$i" '
      /^  - id:/ { count++ }
      count == idx && /^    prompt:/ {
        sub(/^    prompt: */, "")
        gsub(/^"|"$/, "")
        print
        exit
      }
    ' "$DATASET")
    EXPECTED=$(awk -v idx="$i" '
      /^  - id:/ { count++ }
      count == idx && /^    expected_invocation:/ {
        sub(/^    expected_invocation: */, "")
        print
        exit
      }
    ' "$DATASET")
  fi

  echo "  [$i/$CASE_COUNT] $PROMPT"

  # claude -p で実行 (失敗してもループ継続)
  ACTUAL_OUTPUT=$(claude -p "$PROMPT" --output-format text 2>&1 | head -50 || echo "(execution failed)")

  cat >> "$REPORT_FILE" <<EOF
### Case $i

- **Prompt**: \`$PROMPT\`
- **Expected invocation**: $EXPECTED
- **Actual output (first 50 lines)**:

\`\`\`
$ACTUAL_OUTPUT
\`\`\`

- **Human review**: [ ] pass  [ ] fail  [ ] partial
- **Notes**:

EOF
done

cat >> "$REPORT_FILE" <<EOF

## Summary (人間記入欄)

- auto-invoke 成功率: __ / $CASE_COUNT
- タスク完遂率: __ / $CASE_COUNT
- 総評:
- 改善仮説:
EOF

echo ""
echo "Report generated: $REPORT_FILE"
