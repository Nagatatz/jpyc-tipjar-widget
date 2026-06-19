#!/bin/sh
# Notification hook: cross-platform desktop notification.
# macOS: osascript, WSL: Windows toast via powershell.exe, Linux: notify-send.
# Fallback: silent. Exit 0 always (informational only).
# pztn:260619 Add WSL detection so notifications surface on the Windows host.

TITLE="Claude Code"
MSG="Claude needs your attention"

# pztn:260619 WSL is reported as Linux by uname; detect it via /proc/version
# and route notifications to the Windows host (powershell BurntToast, else msg.exe).
is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

case "$(uname -s)" in
  Darwin)
    osascript -e "display notification \"$MSG\" with title \"$TITLE\" sound name \"Sosumi\"" 2>/dev/null
    ;;
  Linux)
    if is_wsl; then
      if command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -NoProfile -Command \
          "New-BurntToastNotification -Text '$TITLE','$MSG'" >/dev/null 2>&1 \
          || msg.exe "$(whoami)" "$TITLE: $MSG" >/dev/null 2>&1 || true
      elif command -v msg.exe >/dev/null 2>&1; then
        msg.exe "$(whoami)" "$TITLE: $MSG" >/dev/null 2>&1 || true
      fi
    elif command -v notify-send >/dev/null 2>&1 && [ -n "$DISPLAY" ]; then
      notify-send "$TITLE" "$MSG" 2>/dev/null || true
    fi
    ;;
esac

exit 0
