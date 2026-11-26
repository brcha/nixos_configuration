# Hyprland

Notes on the Hyprland session. The configuration lives in `home/apps/hyprland.nix` (user config) and
`os/gui/hyprland.nix` (system module). Keep this file in sync when binds change.

## Sessions

- Hyprland (the `uwsm-managed` entry) is preselected in SDDM, and Plasma stays in the list. The default
  is set in `os/gui/hyprland.nix`; machines that import only the KDE module still default to Plasma.
  SDDM does not remember the last session across reboots, because the root filesystem is rolled back.
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
| `Super+D`      | Launcher (Vicinae)              |
| `Super+E`      | File manager (Dolphin)          |
| `Super+R`      | To-do list (rtm)                |
| `Super+S`      | Notes (Simplenote)              |

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

### Notifications

| Keys              | Action                                       |
|-------------------|----------------------------------------------|
| `Super+N`         | Open or close the notification panel         |
| `Super+Shift+N`   | Toggle do-not-disturb                        |

### Media keys

All media keys go through `swayosd-client`, which does the action and shows the on-screen indicator:
volume up/down/mute and microphone mute (raising stops at 100 %), and next, previous and play/pause
for the current MPRIS player.

### Indicators

| Keys       | Action                                                     |
|------------|------------------------------------------------------------|
| `Num Lock` | Shows the Num Lock state (SwayOSD); the key works as usual |

Scroll Lock has no indicator: the keymap binds it to no modifier, so it has no state to show.

## Desktop shell

Defined in `home/apps/hyprland-shell.nix`. Every unit is a Home Manager user service wanted by
`wayland-session@hyprland.desktop.target` (set through `wayland.systemd.target`), so none of them
start in Plasma.

- Waybar: top bar in the Sweet-Mars colours (launcher button, workspaces, the focused application's icon and window title, clock, weather, privacy
  indicators, night light, stay awake, layout, Bluetooth, volume, network, cpu, memory, notifications, tray), with icons from the installed Nerd Fonts.
  The bar is three rounded sections over the wallpaper, 10 px from the screen edges like the windows: launcher, workspaces,
  taskbar and title on the left, clock and weather in the centre, the rest on the right. Each is as wide as its content. Hovering the clock
  shows a calendar, the network icon shows the IP address, and the Bluetooth icon the connected devices.
  The NixOS snowflake at the left end opens Vicinae, like `Super+D`.
  Between the workspaces and the window title, a taskbar shows one icon per open window on any workspace: a click
  focuses the window (switching to its workspace), a middle click closes it, and hovering shows its title. The focused
  window's icon is highlighted like the active workspace.
  Waybar comes from nixpkgs-unstable (0.16). Four groups on the right are hover drawers: an icon naming the group stays
  visible, and hovering it for a moment (200 ms) slides the group out to its left, on a lighter background with a
  grey underline; moving the pointer off the group closes it. A left click on the group icon (or on cpu or memory)
  pins the drawer open, shown by an accent underline; another click unpins it, and the drawer then closes when the
  pointer next leaves it. Icons with a click action of their own keep it. Waybar has no such option upstream, so
  `home/apps/waybar-drawer-pin.patch` adds `click-to-pin` to Waybar's group drawers. The toggle switch (󰔡) opens the night light, stay
  awake and the layout; the network icon (󰛳) opens the network and Bluetooth; the gauge (󰊚) opens cpu and memory; the
  tray icon (󱊔) at the right end opens the tray. The group icons hint at what is inside: the toggle switch turns accent
  while the night light is at night or changing, or stay awake is on; the network icon dims without a network
  connection and otherwise turns accent while a Bluetooth device is connected; the gauge turns accent when the load per
  CPU or the memory in use reaches 80 %. Their tooltips sum up the group. The network and gauge hints are checked every
  10 s. Tray menus open from the revealed icons as usual; an unpinned drawer may slide shut behind an open menu, a
  pinned one stays.
  At the left end of the right-hand section, outside the drawers, accent-coloured privacy icons appear while the screen
  is shared, the microphone records or an application reads the location (GeoClue); hovering them lists the
  applications. A camera used through PipeWire shows as the screen-share icon; a camera opened directly through V4L2 is
  not seen.
  Clicking the volume opens pavucontrol; scrolling on it changes the volume. Clicking Bluetooth opens
  KDE's `kcm_bluetooth`, which pairs devices. Clicking the layout switches to the next layout. The
  weather comes from wttr.in (Belgrade) every 30 minutes. The stay awake icon toggles whether the
  lock and screen-off timers run: it starts or stops the `stay-awake` user unit, a `systemd-inhibit --what=idle` lock
  that hypridle obeys. Unlike Waybar's built-in idle inhibitor, it stays on when Waybar restarts; it ends with the
  session. The night light module shows only an icon: a sun in daylight, a moon at night, a half-and-half
  icon during a transition, and a dimmed sun when the service is off. The tooltip gives the exact
  temperature. wlsunset has no status interface, so the module reads the last "setting temperature"
  line of its journal; with no such line it assumes the daytime value. A click turns the service off or on.
  Clicking the network module opens KDE's `kcm_networkmanagement`, which needs the `ksvg` QML module
  (`os/gui/hyprland.nix`). Idle (passive) tray items are shown on purpose, for example the KDE Connect icon
  while no device is reachable.
  The tray's list of icons is kept by kded6, not Waybar: before Waybar starts, it has kded6 load its
  StatusNotifierWatcher. Icons therefore stay when Waybar restarts (for example on `just switch`) and
  when the monitor wakes and its output briefly disappears, which removes the bar. Waybar's own
  watcher went away in both cases, and Qt apps then dropped their icons until restarted.
- SwayNotificationCenter (swaync): notification popups and a panel with quick settings on top and
  past notifications below, with the do-not-disturb switch and a Clear all button. The quick
  settings are a row of buttons, a volume slider and media controls:
  - Toggles: night light (󰖔), stay awake (󰅶) and Bluetooth power (󰂯); a toggle is accent-coloured
    while on. Night light and stay awake start and stop the same units as the bar's icons, which
    follow at once. The buttons read the current state each time the panel opens.
  - Actions: screenshot (󰹑, Flameshot), lock (󰌾) and sound settings (󰓃, pavucontrol). They close
    the panel first, so it does not show in the screenshot.
  - The volume slider sets the default output; the arrow next to it expands a slider per
    application.
  - Media controls (album art, play/pause, previous, next) appear while a player reports what it
    plays, one card per player.
  - There is no brightness slider (wuwei's monitors have no backlight device) and no Wi-Fi toggle
    (wuwei uses ethernet).

  The bell in the bar shows whether there are notifications (accent colour) and is greyed out under
  do-not-disturb; the tooltip gives the count. Click it for the panel, right-click for
  do-not-disturb. Normal popups time out after 8 s (low urgency 5 s, critical never) and stay in the panel until cleared. Styled in the
  Sweet-Mars colours on top of swaync's own style. Run as its own unit and deliberately not
  installed as a package or D-Bus service (the Home Manager module would install it), because its
  D-Bus activation file would let it take over notifications in Plasma. For the same reason its
  packaged base style is passed on the command line.
- hypridle and hyprlock: lock after 10 minutes, screen off after 15.
- hyprpolkitagent: polkit prompts. cliphist: clipboard history.
- SwayOSD: the on-screen indicator for volume, microphone mute, the media player and Num Lock, in
  the Sweet-Mars colours. Its built-in limit of 100 % caps the volume keys. There are no brightness
  keys: wuwei's monitors have no backlight device, and DDC/CI is not set up.
- Vicinae: the launcher. Its server runs as a user unit of the Hyprland session, in a Sweet-Mars
  theme and without a tray icon. It keeps its own clipboard history next to cliphist, and copies
  instead of pasting (pasting needs `/dev/uinput`). Its settings window cannot save changes,
  because Home Manager owns `settings.json`. Fuzzel stays for the power menu and the cliphist
  picker, which keep working when the Vicinae server is down.
- wlsunset: night light, like Plasma's Night Color. 5000 K at night, 6500 K by day, switching at
  sunrise and sunset computed from fixed coordinates (Belgrade). Plasma uses its own.
- hyprpaper: the wallpaper, on every monitor. The Bing picture of the day, like Plasma's: a timer
  checks Bing at login and every hour, saves the UHD image in `~/.cache/bing-wallpaper` and hands
  it to hyprpaper (`hyprctl hyprpaper wallpaper`). Until the first download, and when there is no
  network and nothing saved yet, it shows ScarletTree from the Plasma wallpapers. The plain colour
  (`misc.background_color`) shows while hyprpaper starts. Run the check by hand with
  `systemctl --user start bing-wallpaper`.

## KDE apps

KDE applications (Dolphin, Okular, Kate, KMail, ...) run unchanged in Hyprland.

- `~/.config/uwsm/env-hyprland` (Hyprland sessions only) sets `QT_QPA_PLATFORMTHEME=kde`, so Qt apps
  follow the Plasma colour scheme and style (Kvantum), and `XDG_MENU_PREFIX=plasma-`, so the
  application menu, "Open with" and default applications work as in Plasma. `KDE_FULL_SESSION` and
  `KDE_SESSION_VERSION` make QtKeychain (KMail, Akonadi) use the KWallet API; without them it uses
  the freedesktop Secret Service, which is KWallet too, but under different entries
  ("Entry not found").
- Wallet: Plasma starts `pam_kwallet_init` at login to pass the login password to KWallet; Hyprland
  runs it on start so KMail and other wallet users find an open wallet.
- The portal is restarted on start: it can come up before the compositor environment is imported and
  would then launch apps (`xdg-open`, "Open with") without `WAYLAND_DISPLAY`.
- Portals (`os/gui/hyprland.nix`): Hyprland's portal for screen sharing and global shortcuts, KDE's
  for file dialogs and the colour scheme, KWallet's for secrets, GTK as the fallback.
- UWSM runs XDG autostart, so Plasma's autostart apps start in Hyprland too. Yakuake,
  Flameshot, syncthingtray, Clockify, Telegram, KGpg and KTailctl are skipped through a systemd drop-in
  (`ConditionEnvironment=XDG_CURRENT_DESKTOP=KDE`); add other apps to `plasmaOnly` in
  `home/apps/hyprland.nix` to do the same.
- Hyprland starts Flameshot, syncthingtray, Clockify, Telegram, KGpg, KTailctl, MEGAsync, OneDriveGUI and the KDE Connect
  indicator itself, once Waybar's tray exists (`wait-for-tray` waits for the tray host, not only the watcher): tray apps
  started earlier get no icon (syncthingtray shows a "system tray not available" window). MEGAsync and
  OneDriveGUI have no XDG autostart entry, so Hyprland starts them itself. OneDriveGUI starts minimized and syncs by itself.
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
  another app does the same. The browsers' Picture-in-Picture window floats above the tiled windows, opens
  centred and takes the focus. It stays on its workspace and keeps the size the browser remembers
  (resize it with `Super`+right mouse drag; Wayland does not let the browser remember the position). Zoom's helper windows while sharing (share toolbar, video window,
  annotation layer) float and do not take focus; its main and meeting windows tile. `initial_workspace_tracking = 0` makes apps started with the session
  open their windows on the workspace you are on. `focus_on_activate` makes a window that asks for
  attention (a browser asked to open a link from the terminal or the mail client) take the focus, which
  switches to its workspace.
- Menu bars: KDE apps hide their menu bar when Plasma's global menu shows it, and Hyprland has no
  global menu. Press `Ctrl+M` in the app to show its menu bar (the choice is stored per app).
- KDE Connect: the daemon starts through XDG autostart; `kdeconnect-indicator` is started with
  Hyprland to give it a tray icon in Waybar (Plasma uses a plasmoid instead).
- MIME defaults and GTK settings are left alone on purpose: KDE rewrites `mimeapps.list` and the
  GTK `settings.ini` at runtime, and both files are shared by the two sessions already.

## Ghostty

New Ghostty windows start in the home directory (`working-directory = home`). A tab or window
opened from inside Ghostty still uses the directory of the window it was opened from.

On the first `ssh` to a host that lacks the `xterm-ghostty` terminfo, Ghostty installs it into
`~/.terminfo` on that host (`ssh-terminfo`). Where that is not possible (no `tic` on the host),
`TERM` falls back to `xterm-256color` (`ssh-env`). Hosts that already have the entry are
remembered; `ghostty +ssh-cache` lists or clears them.

Default Linux keybindings (not set by this configuration):

| Keys                            | Action               |
|---------------------------------|----------------------|
| `Ctrl+Shift+T`                  | New tab              |
| `Ctrl+Tab` / `Ctrl+Shift+Tab`   | Next / previous tab  |
| `Alt+1` ... `Alt+8`             | Go to tab            |
| `Ctrl+Shift+N`                  | New window           |
| `Ctrl+Shift+O` / `Ctrl+Shift+E` | Split right / down   |

## Notes

- Apps are launched as UWSM scopes (`uwsm app --`). Vicinae and fuzzel do the same through their
  launch prefix.
- Home Manager manages `~/.config/hypr/hyprland.lua`. If Hyprland generates a default config
  there on a start without one, remove it before the next activation, or Home Manager aborts with
  "would be clobbered".
