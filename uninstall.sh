#!/usr/bin/env bash
# Remove protect-tray (settings and the API key in ~/.config/protect-tray are kept).
set -euo pipefail
systemctl --user disable --now protect-tray.service 2>/dev/null || true
rm -f "$HOME/.local/bin/protect-tray" "$HOME/.config/systemd/user/protect-tray.service" \
      "$HOME/.local/share/applications/protect-tray.desktop"
systemctl --user daemon-reload
echo "Removed. ~/.config/protect-tray (settings and API key) was left in place; delete it to remove the key."
