# unifi-protect-tray

UniFi Protect alarms as **desktop notifications on Linux**, with a camera list in the
system tray. Doorbell rings, people, packages or anything else you set up in Protect's
**Alarm Manager** pop up on your desktop with a thumbnail and a **View** button.

There's nothing to configure twice. What you're notified about, for which cameras and on
which schedule is decided only in UniFi Protect. This app shows whatever Protect sends.

Built for KDE Plasma 6. Other desktops with a system tray and a freedesktop notification
server should work too.

## Features

- **Notifications from Alarm Manager**: every alarm with a *Custom Webhook* action
  becomes a notification with the alarm's thumbnail (or a fresh camera snapshot). The
  doorbell is marked urgent.
- **View button** opens the event, or the camera, in the Protect web app.
- **Tray menu** lists your cameras; click one to open it in Protect.
- **Do not disturb** for 1 hour, 4 hours or until turned off. The doorbell still comes
  through.
- **Settings in the menu**: console address, API key, this computer's address, and a
  connection test.
- **No UniFi password stored**: it only needs an API key, kept in a file only you can read.

## Requirements

- Python 3 with **PyQt6** (`python-pyqt6` on Arch, `python3-pyqt6` on Debian/Ubuntu/Fedora)
- `notify-send` (libnotify), `xdg-open`, `ip` (iproute2), systemd user services
- A UniFi console running **UniFi Protect** that can reach this computer on your network

## Install

```sh
git clone https://github.com/JamesStuder/unifi-protect-tray.git
cd unifi-protect-tray
./install.sh
```

On first start the tray icon asks for:

1. **Console address**: the IP or host name of your UniFi console, e.g. `192.168.1.1`.
2. **API key**: in the console's web UI, open **Integrations** (the plug icon), click
   **Create API Key** and copy it. It's shown only once.

Both can be changed later under **Settings** in the tray menu.

### Firewall

The console sends alarms to this computer on TCP port **8765**. If a firewall is
running, allow that port from the console only, e.g. with ufw:

```sh
sudo ufw allow proto tcp from 192.168.1.1 to any port 8765 comment 'protect-tray webhook'
```

Give this computer a fixed IP (a DHCP reservation in UniFi Network) so the webhook
address doesn't change. The URL uses the address this computer reaches the console
from. If you switch between Wi-Fi and Ethernet, set a fixed one under
**Settings → This computer's address** (for example your reserved Wi-Fi IP).

## Set up alarms in Protect

1. In the tray menu, click **Copy webhook URL**.
2. Open Protect's **Alarm Manager** (the tray menu has a shortcut) and click **Create Alarm**.
3. Choose the trigger, e.g. **Activity → Ring** on your doorbell, or **Person** on a few
   cameras, and optionally a schedule.
4. Under **Action**, choose **Webhook → Custom Webhook** and paste the URL. Under
   **Advanced**, set the method to **POST** and turn on **Use Thumbnails**.
5. Save. Create one alarm per thing you want on your desktop.

The alarm's **name** becomes the notification title, so name them the way you want
them to read ("Doorbell", "Person at the back door").

## How it works

- A small web server listens for Protect's webhook on port 8765. The URL contains a
  random secret token, so requests without it are rejected.
- Camera names and snapshots come from Protect's official Integration API, using the
  API key (`X-API-KEY` header).
- The console's self-signed certificate is accepted for requests to the configured
  console address only.

Files:

| Path | Contents |
|---|---|
| `~/.local/bin/protect-tray` | the app |
| `~/.config/protect-tray/config.json` | console address, this computer's address, port, webhook token, do-not-disturb |
| `~/.config/protect-tray/api-key` | the API key (mode 600) |
| `~/.config/systemd/user/protect-tray.service` | starts it with your desktop session |

The webhook port can be changed with `"port"` in `config.json` (restart the service
afterwards). `protect-tray url` prints the webhook URL.

## Troubleshooting

- **Logs:** `journalctl --user -u protect-tray -f`. Every received alarm is logged,
  without its thumbnail.
- **No notification:** check the tray icon's tooltip, then the log. If no `http` line
  shows up when the alarm fires, the console can't reach this computer: check the
  firewall rule and that the webhook URL still has this computer's current IP.
- **"API key rejected":** create a new key and enter it under Settings → API key.
- **Notification says only "Protect alarm":** the webhook is set to GET (the default).
  Set its method to **POST** under Advanced to get the alarm name and thumbnail.

## Uninstall

```sh
./uninstall.sh
```

Settings and the API key stay in `~/.config/protect-tray`. Delete that folder, and the
key in the console's Integrations page, to remove them too.

## License

MIT. Not affiliated with or endorsed by Ubiquiti. UniFi and UniFi Protect are
trademarks of Ubiquiti Inc.
