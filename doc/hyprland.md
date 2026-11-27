# Hyprland

Keyboard shortcuts of the Hyprland session.

In SDDM, pick the Hyprland entry marked `uwsm-managed`; the plain `Hyprland` entry bypasses UWSM.

## Keybindings

`Super` is the main modifier. `Super+Space` switches the keyboard layout (us / rs).

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
| `Super+L`         | Lock the screen                              |
| `Super+M`         | Power menu                                   |

In the power menu, `l` locks and `e` logs out; Reboot and Shut down need a click, or the arrow keys and `Enter`. `Escape` closes it.

### Clipboard and screenshots

| Keys                | Action                                          |
|---------------------|-------------------------------------------------|
| `Super+Shift+V`     | Clipboard history                               |
| `Print`             | Screenshot with annotations (Flameshot)         |

### Notifications

| Keys              | Action                                       |
|-------------------|----------------------------------------------|
| `Super+N`         | Open or close the notification panel         |
| `Super+Shift+N`   | Toggle do-not-disturb                        |

### Window switching and overview

| Keys                                | Action                                                           |
|-------------------------------------|------------------------------------------------------------------|
| `Alt+Tab`                           | Next window, most recent first; releasing `Alt` switches to it   |
| `Alt+Shift+Tab` or ``Alt+` ``       | Previous window                                                  |
| `Alt+Escape`                        | Close the switcher without switching                             |
| `Super+Tab`                         | Workspace overview, or close it                                  |

In the overview, `Tab`, `Shift+Tab` or the arrows select a window, `Enter` or a click switches to it,
a click on an empty part of a workspace switches to that workspace, and `Escape` or a click outside
the workspaces closes it.

### Media keys

The volume, microphone mute and media player keys work as usual and show an on-screen indicator; the volume stops at 100 %. `Num Lock` shows its state on screen.

### KDE applications

`Ctrl+M` shows or hides an application's menu bar, since Hyprland has no global menu. The choice is stored per application.

## Ghostty

Default Linux keybindings (not set by this configuration):

| Keys                            | Action               |
|---------------------------------|----------------------|
| `Ctrl+Shift+T`                  | New tab              |
| `Ctrl+Tab` / `Ctrl+Shift+Tab`   | Next / previous tab  |
| `Alt+1` ... `Alt+8`             | Go to tab            |
| `Ctrl+Shift+N`                  | New window           |
| `Ctrl+Shift+O` / `Ctrl+Shift+E` | Split right / down   |
