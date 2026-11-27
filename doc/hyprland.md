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
| `Super+M`         | Power menu (wlogout)                         |

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

### Overview and window switching

| Keys                                | Action                                                           |
|-------------------------------------|------------------------------------------------------------------|
| `Alt+Tab`                           | Next window, most recent first; releasing `Alt` switches to it   |
| `Alt+Shift+Tab` or ``Alt+` ``       | Previous window                                                  |
| `Alt+Escape`                        | Close the switcher without switching                             |
| `Super+Tab`                         | Workspace overview with live window thumbnails, or close it      |

In the overview, `Tab`, `Shift+Tab` or the arrows select a window, `Enter` or a click switches to it,
a click on an empty part of a workspace switches to that workspace, and `Escape` or a click outside
the workspaces closes it. The binds are in `hyprland.lua` and trigger global shortcuts of the
Quickshell switcher and overview (see Quickshell below).

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

- Bar (Quickshell, `Bar.qml`): one per screen, 40 px high, in the Sweet-Mars colours with icons from the
  installed Nerd Fonts. Three sections attached to the top edge, each as wide as its content, with rounded lower
  corners and curves that blend each section into the screen edge it touches (`BarSection.qml`): the workspaces of
  its screen (click to switch) and the focused window's icon and title on the left; the clock and the weather in
  the centre; on the right, from left to right, the failed-units count, the privacy icons, the toggles drawer, the
  volume, the connectivity and system drawers, the notification bell, the tray drawer and the power button. Only
  the sections take clicks; the gaps between them pass clicks to the windows. Tooltips are small popups below the
  bar (`BarTooltip.qml`).

  Auto-hide (`EdgeAutoHide.qml`), each screen's bar on its own: hidden while its workspace has windows, it slides
  in (about 200 ms) when the pointer touches the top edge, stays while the pointer is on a section, a card is open
  on its screen, a tray menu is open or the swaync panel is open, and slides away 300 ms after it is no longer
  needed; pointing back during the slide brings it back from where it is. On an empty workspace it stays visible.
  The bar reserves no space: windows use the full height, and the shown bar is drawn over their top. The swaync
  panel and notification popups keep their place below the bar's row, so they leave a gap above them while the
  bar is hidden. A drawer opening while the pointer rests exactly on the top edge can make
  Hyprland end the bar's hover; the next pointer motion restores it.

  Hover drawers (`Drawer.qml`): an icon naming the group stays visible, and hovering it for 200 ms slides the group
  out to its left (300 ms), on a lighter background with a grey underline; moving the pointer off the group closes
  it. A left click on the group icon (or on cpu or memory) pins the drawer, shown by an accent underline; another
  click unpins it. The toggle switch (󰔡) opens the night light, stay awake and the layout; the network icon (󰛳) the
  network and Bluetooth; the gauge (󰊚) cpu and memory; the tray icon (󱊔) the tray. The icons hint at what is
  inside: the toggle switch turns accent while the night light is at night or changing, or stay awake is on; the
  network icon dims without a network connection and turns accent while a Bluetooth device is connected; the gauge
  turns accent when the load per CPU or the memory in use reaches 80 %. Their tooltips sum up the group.
  - Night light: a sun in daylight, a moon at night, a half-and-half icon during a transition and a dimmed sun when
    the service is off; the tooltip gives the exact temperature. wlsunset has no status interface, so a script
    reads the last "setting temperature" line of its journal; with no such line it assumes the daytime value. A
    click turns the service off or on.
  - Stay awake: toggles whether the lock and screen-off timers run, by starting or stopping the `stay-awake` user
    unit, a `systemd-inhibit --what=idle` lock that hypridle obeys. It stays on when Quickshell restarts and ends
    with the session.
  - Both are read every 30 s, and at once when `unit-toggle` (the bar's clicks or swaync's quick settings) calls
    `qs ipc -c shell call bar refresh`. The layout follows Hyprland's `activelayout` event; a click switches to
    the next layout.
  - Network and Bluetooth come from Quickshell's NetworkManager and BlueZ services; hovering the network shows the
    IP address (from `ip`), hovering Bluetooth the connected devices. Clicking the network opens KDE's
    `kcm_networkmanagement`, which needs the `ksvg` QML module (`os/gui/hyprland.nix`); clicking Bluetooth opens
    `kcm_bluetooth`, which pairs devices.
  - Cpu and memory come from `/proc` every 10 s.
  - Tray: every item, idle ones too (for example KDE Connect while no device is reachable). A left click activates
    an item (or opens the menu of an item that only has a menu), a middle click runs its secondary action, a right
    click opens its menu, and the wheel scrolls it. What a left click does is up to each application: some toggle
    their window, others only show it. Tray menus are widget menus, so Quickshell runs as a QApplication
    (`//@ pragma UseQApplication` in `shell.qml`).

  The tray's list of icons is kept by kded6, not Quickshell: before Quickshell starts, `quickshell.service` has
  kded6 load its StatusNotifierWatcher. Icons therefore stay when Quickshell restarts (for example on `just switch`)
  and when the monitor wakes and its output briefly disappears, which removes the bar. Without it, Qt apps dropped
  their icons until they were restarted.

  The failed-units count (system and user, checked every 10 s) appears in the accent colour while any unit has
  failed; hovering lists them, and a click opens Ghostty with `systemctl --failed` for both. The privacy icons come
  from PipeWire: a monitor while a video capture stream (a shared screen, or a camera through PipeWire) is linked
  and running, a microphone while an audio recording stream is; hovering lists the applications. A camera opened
  directly through V4L2 is not seen, and there is no location icon.

  The volume shows the default output: scrolling changes it by 1 % up to 100 %, a middle click mutes it (with the
  on-screen indicator), a right click opens pavucontrol, and hovering shows the media and volume card, which a
  click holds. Hovering the clock or the weather shows their cards the same way. The weather comes from wttr.in
  (Belgrade, its JSON format), fetched by the `weather` user unit at login and every 30 minutes (`weather.timer`):
  the bar shows a weather glyph (a night variant after sunset) and the temperature.
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
- Quickshell popups: cards that grow out of the bar, one shape with the section above them, centred under the
  module that opened them (they follow it when a drawer moves it) and kept on the screen; a card that reaches the
  screen edge of its section runs down that edge. Hovering the module slides its card down (after
  150 ms, so passing over it shows nothing), and it hides 250 ms after the pointer leaves both the module and the
  card, so the pointer can move into the card. A click on the module holds the card: it then stays until a click
  outside the bar and the card, Esc, or another click on the module. The clock shows a
  month calendar in the system locale with ISO week numbers and today marked; the arrows or the mouse wheel change
  the month (wheel up for the next one), and a button with today's date, shown while another month is displayed,
  returns to the current one. The weather shows current conditions (temperature, feels-like, humidity, wind,
  sunrise and sunset) and a three-day forecast (noon glyph, high and low, highest chance of rain); the `weather` unit
  writes the data to `~/.cache/weather.json` through `home/apps/weather.jq`, the bar reads it every
  minute, and both keep the last data when a fetch fails. The volume module's card shows, from top to bottom:
  - The playing media, while a player is open: cover, title and artist (a click on them brings the player's window
    up), a seek bar with the elapsed and total time, and shuffle, previous, play/pause, next and repeat (off, the
    whole playlist, the current track). With several players open, a row of their names picks the one shown;
    otherwise it is the one playing, else the first.
  - Output: mute button, volume slider and the current device; a click on the device lists the others to switch to.
  - Applications: a volume slider and mute button per application that plays sound (all its streams together).
  - Input: the same as the output for the microphone.
  - Sound settings, which opens pavucontrol.

  The volume sliders (output, applications, input) also follow the mouse wheel, 1 % per step.

  Only one card shows at a time: a hover replaces another card unless that card is held, and a click replaces it
  in any case.
  Quickshell runs as `quickshell.service` of the Hyprland session (nothing in Plasma); the QML is in
  `home/apps/quickshell/` and errors go to `journalctl --user -u quickshell`. It uses Qt's Basic controls style,
  because the Breeze style picked by the KDE platform theme needs Kirigami.
- Quickshell dock (`Dock.qml`): one per screen, centred at the bottom edge and shaped like
  the bar's sections turned upside down. From left to right: the NixOS snowflake (Vicinae, like `Super+D`), the
  pinned applications, a separator, and the running applications that are not pinned; a dot marks a running one
  and hovering shows its name. A left click starts an application, or brings up its window, and further clicks
  cycle through its windows; a middle click starts another instance. Applications start through UWSM
  (`uwsm app -- <id>.desktop`), so they keep running when Quickshell restarts. The pinned list is `dockApps` in
  the user's data (`users/users.nix`), desktop entry ids without `.desktop`; the Chrome web apps (WhatsApp,
  Instagram, ReciMe) are `chrome-<id>-Default` entries, and their windows carry the same id. It auto-hides like
  the bar, at the bottom edge.
- Quickshell window switcher (`Alt+Tab`): a row of windows from every workspace (not special ones),
  most recently used first, each with a live thumbnail, its icon, title and workspace number. Windows not focused since
  Quickshell started follow in Hyprland's focus order. It takes no keyboard focus: every key reaches
  it as a Hyprland bind, so the window in front keeps the keyboard while the switcher is shown.
- Quickshell overview (`Super+Tab`): the workspaces (not special ones) as cards with the monitor's
  shape, each window drawn at its place as a live thumbnail; the active workspace has a lighter
  border, the selected window the accent. There is no launcher or search field: Vicinae launches
  apps. The overview holds the keyboard while it is shown and gives it back when it closes.
- hypridle and hyprlock: lock after 10 minutes, screen off after 15.
- wlogout: the power menu, opened by `Super+M` and the power button at the right end of the bar. One
  row of Lock, Log out, Reboot and Shut down. `l` locks and `e` logs out; Reboot and Shut down have no
  key and need a click, or the arrow keys and Enter. Escape or a click outside the buttons closes it.
  Lock comes first, so a stray Enter only locks. There is no Suspend button. Defined in
  `home/apps/hyprland.nix`.
- hyprpolkitagent: polkit prompts. cliphist: clipboard history.
- SwayOSD: the on-screen indicator for volume, microphone mute, the media player and Num Lock, in
  the Sweet-Mars colours. Its built-in limit of 100 % caps the volume keys. There are no brightness
  keys: wuwei's monitors have no backlight device, and DDC/CI is not set up.
- Vicinae: the launcher. Its server runs as a user unit of the Hyprland session, in a Sweet-Mars
  theme and without a tray icon. It keeps its own clipboard history next to cliphist, and copies
  instead of pasting (pasting needs `/dev/uinput`). Its settings window cannot save changes,
  because Home Manager owns `settings.json`. Fuzzel stays for the cliphist picker, which keeps
  working when the Vicinae server is down.
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
  indicator itself, once the bar's tray exists (`wait-for-tray` waits for the tray host, not only the watcher): tray apps
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
  Hyprland to give it a tray icon in the bar (Plasma uses a plasmoid instead).
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
