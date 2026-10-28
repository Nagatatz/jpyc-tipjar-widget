#!/bin/sh
# SessionStart hook: displays development environment info.
# Informational only (exit 0 always).
#
# Customize this script for your project's toolchain.
# Examples:
#   echo "Python: $(python3 --version 2>&1)"
#   echo "Node:   $(node --version 2>/dev/null || echo 'not found')"
#   echo "JDK:    $(java -version 2>&1 | head -1)"
#   echo "Go:     $(go version 2>/dev/null || echo 'not found')"

PROJECT_NAME=$(basename "$(pwd)")
HEADER="=== ${PROJECT_NAME} Dev Environment ==="
SEP=$(echo "$HEADER" | tr -c '\n' '=')
echo "$HEADER"
echo "Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
# The safety hooks read their input with lib/json.sh (jq -> python3 -> plutil) and block
# every call they guard when none of these is available.
HOOK_JSON_BACKEND=none
HOOK_JSON_LIB="$(dirname "$0")/lib/json.sh"
# shellcheck source=lib/json.sh
[ -r "$HOOK_JSON_LIB" ] && . "$HOOK_JSON_LIB"
case $HOOK_JSON_BACKEND in
  jq) ;;
  none)
    echo "WARNING: jq not found and no fallback parser (python3 / plutil) works, so the safety hooks"
    echo "  (validate-bash, check-secrets, ...) block every tool call they guard."
    echo "  Install jq: macOS 'brew install jq' / Debian 'sudo apt-get install jq' / Windows 'winget install jqlang.jq'"
    ;;
  *) echo "Note: jq not found; the safety hooks read their input with $HOOK_JSON_BACKEND instead (installing jq is recommended)." ;;
esac
echo "$SEP"
exit 0
