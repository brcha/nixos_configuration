# Hyprland

Notes on the Hyprland session. The configuration lives in `home/apps/hyprland.nix` (user config) and
`os/gui/hyprland.nix` (system module). Keep this file in sync when binds change.

## Sessions

- Plasma stays the default session. Hyprland is an extra entry in SDDM.
- Pick the entry marked `uwsm-managed`. The plain `Hyprland` entry bypasses UWSM.
- Hyprland-only services must not start in Plasma: bind them to the UWSM Hyprland target, not to
  `graphical-session.target`.

## Keybindings

`Super` is the main modifier. `Super+Space` switches the keyboard layout (us / rs). It is a Hyprland bind
and not an XKB option, so applications such as Claude's input box never see the key press.

### Programs

| Keys           | Action                          |
|----------------|---------------------------------|
| `Super+Return` | Terminal (Ghostty)              |
| `Super+D`      | Launcher (fuzzel)               |
| `Super+E`      | File manager (Dolphin)          |

### Windows

| Keys                       | Action                              |
|----------------------------|-------------------------------------|
| `Super+Q`                  | Close window                        |
| `Super+V`                  | Toggle floating                     |
| `Super+F`                  | Toggle fullscreen                   |
| `Super+T`                  | Toggle split direction              |
| `Super+Arrows`             | Move focus                          |
| `Super+Shift+Arrows`       | Move window                         |
| `Super+Left mouse drag`    | Move floating window                |
| `Super+Right mouse drag`   | Resize window                       |

### Workspaces

| Keys                    | Action                          |
|-------------------------|---------------------------------|
| `Super+1` ... `Super+0` | Switch to workspace 1-10        |
| `Super+Shift+1` ... `0` | Move window to workspace 1-10   |
| `Super+Scroll`          | Next / previous workspace       |

### Session

| Keys              | Action                                       |
|-------------------|----------------------------------------------|
| `Super+L`         | Lock the screen (hyprlock)                   |
| `Super+M`         | Power menu: log out, reboot, shut down       |

### Clipboard and screenshots

| Keys                | Action                                          |
|---------------------|-------------------------------------------------|
| `Super+Shift+V`     | Clipboard history (cliphist, picked in fuzzel)  |
| `Print`             | Flameshot capture with annotations              |

### Media keys

Volume up/down/mute and microphone mute use `wpctl`. Next, previous and play/pause use `playerctl`.

## Desktop shell

Defined in `home/apps/hyprland-shell.nix`. Every unit is a Home Manager user service wanted by
`wayland-session@hyprland.desktop.target` (set through `wayland.systemd.target`), so none of them
start in Plasma.

- Waybar: top bar in the Sweet-Mars colours (workspaces, window title, clock, weather, idle
  inhibitor, layout, Bluetooth, volume, network, cpu, memory, tray), with icons from the installed Nerd Fonts. Hovering the clock
  shows a calendar, the network icon shows the IP address, and the Bluetooth icon the connected devices.
  Clicking the volume opens pavucontrol; scrolling on it changes the volume. Clicking Bluetooth opens
  KDE's `kcm_bluetooth`, which pairs devices. Clicking the layout switches to the next layout. The
  weather comes from wttr.in (Belgrade) every 30 minutes. The idle inhibitor icon toggles whether the
  lock and screen-off timers run.
  Known limitation: clicking a workspace does nothing. Waybar 0.15 still sends the legacy
  `hyprctl dispatch workspace N` form, which Hyprland 0.55 (Lua config) rejects. Use `Super+1..0`.
  Re-test after the next Waybar release in nixpkgs.
  Clicking the network module opens KDE's `kcm_networkmanagement`, which needs the `ksvg` QML module
  (`os/gui/hyprland.nix`). Passive tray items are shown, so an idle KDE Connect icon stays visible.
- mako: notifications. Run as its own unit and deliberately not installed as a package or D-Bus
  service, because its D-Bus activation file would let it take over notifications in Plasma.
- hypridle and hyprlock: lock after 10 minutes, screen off after 15.
- hyprpolkitagent: polkit prompts. cliphist: clipboard history.
- wlsunset: night light, like Plasma's Night Color. 5000 K at night, 6500 K by day, switching at
  sunrise and sunset computed from fixed coordinates (Belgrade). Plasma uses its own.
- No wallpaper daemon yet: the background is a plain colour (`misc.background_color`). Add
  hyprpaper once an image is chosen.

## KDE apps

KDE applications (Dolphin, Okular, Kate, KMail, ...) run unchanged in Hyprland.

- `~/.config/uwsm/env-hyprland` (Hyprland sessions only) sets `QT_QPA_PLATFORMTHEME=kde`, so Qt apps
  follow the Plasma colour scheme and style (Kvantum), and `XDG_MENU_PREFIX=plasma-`, so the
  application menu, "Open with" and default applications work as in Plasma. `KDE_FULL_SESSION` and
  `KDE_SESSION_VERSION` make QtKeychain (KMail, Akonadi) use KWallet; without them it asks
  gnome-keyring, which holds none of the KDE passwords ("Entry not found").
- Wallet: Plasma starts `pam_kwallet_init` at login to pass the login password to KWallet; Hyprland
  runs it on start so KMail and other wallet users find an open wallet.
- The portal is restarted on start: it can come up before the compositor environment is imported and
  would then launch apps (`xdg-open`, "Open with") without `WAYLAND_DISPLAY`.
- Portals (`os/gui/hyprland.nix`): Hyprland's portal for screen sharing and global shortcuts, KDE's
  for file dialogs and the colour scheme, GTK as the fallback.
- UWSM runs XDG autostart, so Plasma's autostart apps start in Hyprland too. Yakuake,
  Flameshot, syncthingtray and Clockify are skipped through a systemd drop-in
  (`ConditionEnvironment=XDG_CURRENT_DESKTOP=KDE`); add other apps to `plasmaOnly` in
  `home/apps/hyprland.nix` to do the same.
- Hyprland starts Flameshot, syncthingtray, Clockify, MEGAsync, OneDriveGUI and the KDE Connect
  indicator itself, once Waybar's tray exists: tray apps started earlier get no icon (syncthingtray shows a "system tray
  not available" window). MEGAsync and OneDriveGUI have no XDG autostart entry, so Hyprland starts them
  itself. OneDriveGUI starts minimized and syncs by itself.
- Clockify always opens its window at start and has no start-hidden option. Hyprland starts it
  through `clockify-hidden` (`home/apps/hyprland.nix`), which closes the window as soon as it
  appears; Clockify then keeps running in the tray, and a click on the tray icon shows the window.
  The window may flash for a moment at login. Plasma keeps the normal autostart.
- Flameshot runs through `flameshot-hyprland`, which enables `useGrimAdapter` for this session only
  (a system-scope `flameshot.ini` via `XDG_CONFIG_DIRS`), because the shared user file is also used
  by Plasma.
- Window rules (`home/apps/hyprland.nix`): modal dialogs (for example a print dialog) are centred;
  floating windows alone are not, because menus are floating windows too. Blur stays on, with a
  `no_blur` class list for apps whose menus show a blurred margin (Simplenote); add a class there if
  another app does the same. `initial_workspace_tracking = 0` makes apps started with the session
  open their windows on the workspace you are on.
- Menu bars: KDE apps hide their menu bar when Plasma's global menu shows it, and Hyprland has no
  global menu. Press `Ctrl+M` in the app to show its menu bar (the choice is stored per app).
- KDE Connect: the daemon starts through XDG autostart; `kdeconnect-indicator` is started with
  Hyprland to give it a tray icon in Waybar (Plasma uses a plasmoid instead).
- MIME defaults and GTK settings are left alone on purpose: KDE rewrites `mimeapps.list` and the
  GTK `settings.ini` at runtime, and both files are shared by the two sessions already.

## Ghostty

Default Linux keybindings (not set by this configuration):

| Keys                            | Action               |
|---------------------------------|----------------------|
| `Ctrl+Shift+T`                  | New tab              |
| `Ctrl+Tab` / `Ctrl+Shift+Tab`   | Next / previous tab  |
| `Alt+1` ... `Alt+8`             | Go to tab            |
| `Ctrl+Shift+N`                  | New window           |
| `Ctrl+Shift+O` / `Ctrl+Shift+E` | Split right / down   |

## To revisit

- KDE Connect: once the new phone is paired, remove `show-passive-items` from the Waybar tray in
  `home/apps/hyprland-shell.nix` so the icon hides while no device is connected.

## Notes

- Apps are launched as UWSM scopes (`uwsm app --`). Fuzzel does the same through its `launch-prefix`.
- Home Manager manages `~/.config/hypr/hyprland.lua`. If Hyprland generates a default config
  there on a start without one, remove it before the next activation, or Home Manager aborts with
  "would be clobbered".
