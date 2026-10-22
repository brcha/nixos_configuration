# Hyprland

Notes on the Hyprland session. The configuration lives in `home/apps/hyprland.nix` (user config) and
`os/gui/hyprland.nix` (system module). Keep this file in sync when binds change.

## Sessions

- Plasma stays the default session. Hyprland is an extra entry in SDDM.
- Pick the entry marked `uwsm-managed`. The plain `Hyprland` entry bypasses UWSM.
- Hyprland-only services must not start in Plasma: bind them to the UWSM Hyprland target, not to
  `graphical-session.target`.

## Keybindings

`Super` is the main modifier. `Win+Space` is reserved for switching the keyboard layout (us / rs).

### Programs

| Keys           | Action                          |
|----------------|---------------------------------|
| `Super+Return` | Terminal (Ghostty)              |
| `Super+D`      | Launcher (fuzzel)               |
| `Super+E`      | File manager (Dolphin)          |
| `F12`          | Ghostty quick terminal (global) |

### Windows

| Keys                       | Action                              |
|----------------------------|-------------------------------------|
| `Super+Q`                  | Close window                        |
| `Super+V`                  | Toggle floating                     |
| `Super+F`                  | Toggle fullscreen                   |
| `Super+T`                  | Toggle split direction              |
| `Super+Arrows` / `H J K L` | Move focus                          |
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

| Keys      | Action                                |
|-----------|---------------------------------------|
| `Super+M` | Exit Hyprland (`uwsm stop`)           |

### Media keys

Volume up/down/mute and microphone mute use `wpctl`. Next, previous and play/pause use `playerctl`.

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

- F12 quick terminal: remove it (the `hyprland.start` autostart in `home/apps/hyprland.nix` and the
  rows above) if it is still unused after a few weeks on Hyprland.

## Notes

- Apps are launched as UWSM scopes (`uwsm app --`). Fuzzel does the same through its `launch-prefix`.
- The F12 quick terminal depends on a Ghostty daemon started with Hyprland and registered as a
  global shortcut through the portal. It is passed on the command line so Plasma (where Yakuake
  uses F12) is not affected.
- Home Manager manages `~/.config/hypr/hyprland.lua`. If Hyprland generates a default config
  there on a start without one, remove it before the next activation, or Home Manager aborts with
  "would be clobbered".
