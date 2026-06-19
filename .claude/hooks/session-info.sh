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
echo "Node:   $(node --version 2>/dev/null || echo 'not found')"
echo "$SEP"
exit 0
