#!/bin/sh
# PreToolUse hook for Edit/Write tools.
# Blocks direct editing of auto-generated files.
# Reads JSON from stdin, extracts tool_input.file_path, and checks against block patterns.
# Exit 0 = allow, Exit 2 = block.
#
# Customize: Add patterns for your project's auto-generated files.
# Examples:
#   'Generated\.java$'  -> JFlex/ANTLR generated parsers
#   '\.pb\.go$'          -> Protocol Buffers generated Go files
#   'schema\.generated\.ts$' -> GraphQL codegen output
#   'package-lock\.json$'    -> npm lock file (use npm install instead)

# Read stdin
INPUT=$(cat)

# Shared JSON reader (jq -> python3 -> plutil). A guard that cannot read its input blocks (exit 2).
HOOK_JSON_LIB="$(dirname "$0")/lib/json.sh"
[ -r "$HOOK_JSON_LIB" ] || { echo "BLOCKED by validate-file-edit: $HOOK_JSON_LIB is missing; re-run install.sh" >&2; exit 2; }
# shellcheck source=lib/json.sh
. "$HOOK_JSON_LIB"
hook_json_require validate-file-edit

FILE_PATH=$(hook_json_get "$INPUT" tool_input.file_path)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Block editing of auto-generated files
# Add your project's patterns below:
#
# if echo "$FILE_PATH" | grep -q 'GeneratedParser\.java$'; then
#   echo "BLOCKED: This file is auto-generated. Edit the grammar file instead." >&2
#   exit 2
# fi

exit 0
