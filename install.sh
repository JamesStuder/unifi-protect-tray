#!/usr/bin/env bash
# Install protect-tray for the current user (no root needed, except for the optional firewall rule).
set -euo pipefail
cd "$(dirname "$0")"

missing=()
for cmd in notify-send xdg-open ip systemctl; do
    command -v "$cmd" >/dev/null || missing+=("$cmd")
done
python3 -c 'import PyQt6.QtWidgets, PyQt6.QtNetwork' 2>/dev/null || missing+=("PyQt6 (python-pyqt6 / python3-pyqt6)")
if ((${#missing[@]})); then
    echo "Missing dependencies: ${missing[*]}" >&2
    exit 1
fi

install -Dm755 bin/protect-tray               "$HOME/.local/bin/protect-tray"
install -Dm644 systemd/protect-tray.service   "$HOME/.config/systemd/user/protect-tray.service"
install -Dm644 protect-tray.desktop           "$HOME/.local/share/applications/protect-tray.desktop"
sed -i "s|^Exec=protect-tray|Exec=$HOME/.local/bin/protect-tray|" "$HOME/.local/share/applications/protect-tray.desktop"

systemctl --user daemon-reload
systemctl --user enable --now protect-tray.service

port=$(python3 -c 'import json,os; p=os.path.expanduser("~/.config/protect-tray/config.json"); print(json.load(open(p)).get("port", 8765))' 2>/dev/null || echo 8765)
echo "Installed. The tray icon asks for your console address and API key on first start."
echo "If a firewall is running, allow TCP port $port from your UniFi console only, e.g. with ufw:"
echo "  sudo ufw allow proto tcp from <console-ip> to any port $port comment 'protect-tray webhook'"
