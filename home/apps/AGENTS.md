# AGENTS.md — home/apps/

## What This Directory Is

Home-manager modules for GUI applications: browsers, editors and IDEs, dev GUIs, media players, creative tools, games, communication apps, desktop sessions, and the desktop-only daemons that go with them. GUI only: CLI tools live in `home/development/` and `home/tools/`. WSL turns this whole directory off (`my.apps.enable = false`).

Each module is behind its own switch, `my.apps.<file name>` (for example `my.apps.graphics`); `my.apps.enable` turns them all on. Exceptions: `kde.nix` is behind `my.kde.enable` and the `hyprland*.nix` modules behind `my.hyprland.enable`.

## Module List

- `cloud-storage.nix` — Cloud sync clients and their daemons (dropbox, megasync, onedrive, onedrivegui, yandex-disk) and the yandex-disk user service (Linux only)
- `communication.nix` — Messaging and video conferencing (telegram, discord, zoom, webex); on Linux, the Flatpak override and fontconfig file that give the hand-installed Viber Flatpak the host fonts
- `dev-tools.nix` — Developer GUIs (kcachegrind, meld, dbeaver, pgmanage, qgit, thicket); Linux only: claude-desktop, kdiff3, heaptrack
- `editors.nix` — GUI editors (zed-editor, neovide)
- `firefox.nix` — Firefox configuration, browserpass, google-chrome; Linux only: the Plasma browser integration and the Zen browser
- `fonts.nix` — user-level fontconfig rendering settings (antialiasing, hinting, sub-pixel order)
- `gaming.nix` — Gaming (steam with Vulkan/OpenGL override, protontricks); Linux only
- `graphics.nix` — Graphics and creative tools (gimp, krita, inkscape, scribus); Linux only: synfigstudio, sweethome3d (their nixpkgs builds fail on macOS)
- `hyprland.nix` — Hyprland user config (Lua), Ghostty, fuzzel, UWSM environment, Plasma-only autostart drop-ins, session start hook
- `hyprland-shell.nix` — Hyprland desktop shell: Waybar, SwayNotificationCenter, hyprlock/hypridle, polkit agent, cliphist, wlsunset, binds for lock, clipboard, notifications and screenshots
- `jetbrains.nix` — JetBrains IDEs (clion, datagrip, goland, pycharm, rust-rover, webstorm)
- `kde.nix` — KDE Plasma extras (PIM suite, Kvantum, kio plugins, remote desktop); a drop-in for `akonadi_control.service` that removes the stored MariaDB server path before every start; with `my.apps.networking`, a second drop-in that holds Akonadi back until Proton Bridge has loaded its users (up to 15 s after Bridge starts)
- `livecoding.nix` — TidalCycles live coding (tidal-cycles-full, SuperDirt, generated Neovim paths); Linux only
- `multimedia.nix` — Media players and editors (mpv, smplayer, vlc, avidemux, kdenlive, mkvtoolnix, lmms, spotify, obs-studio, qpwgraph)
- `networking.nix` — Network GUIs (protonmail-bridge-gui, proton-vpn, persepolis); Linux only: strongswanNM, ktailctl
- `productivity.nix` — Productivity apps (joplin, clockify, libreoffice, rtmapp); Linux only: zeal
- `security.nix` — Security GUIs (tor-browser, qtpass, gopass-jsonapi, clamtk)
- `system.nix` — X11, Mesa, Vulkan and Wayland diagnostic tools, Vorta, openrazer-daemon, razergenie; Linux only
- `vscode.nix` — VS Code (`programs.vscode`)

## Architecture

- `default.nix` aggregates all modules in this directory via `imports`
- `home/default.nix` imports this directory as a unit — do not import individual files from outside
- Each module is self-contained and focused on a single application category

## Conventions

- Module signature: `{ pkgs, lib, config, available, ... }:` — add `flake` only when `flake.config` or `flake.inputs` is needed
- Wrap the module body in `config = lib.mkIf config.my.apps.<name> { ... };` (add `&& pkgs.stdenv.isLinux` for a Linux-only module)
- Package lists use `with pkgs;` style, wrapped in `available`; add an explicit `lib.optionals pkgs.stdenv.isLinux [ ... ]` list, with a comment giving the reason, for packages that `available` lets through but that do not work or build on macOS
- Follow the naming pattern established by existing files (`category.nix`)
- To add a new module:
  1. Create `<name>.nix` in this directory
  2. Add it to the `imports` list in `default.nix`
  3. Add `<name>` to the `my.apps` children in `options/default.nix`

## Important Notes

- `gaming.nix` uses a `steam.override { extraPkgs = pkgs: [...]; }` closure to inject Vulkan/OpenGL libraries — preserve this pattern exactly when modifying Steam configuration
- `livecoding.nix` uses `pkgs.unstable.tidal-cycles-full` (absent from 26.05) and is guarded by `my.apps.livecoding` and `pkgs.stdenv.isLinux`. Do not run `superdirt-install`: it performs an imperative `Quarks.install` that shadows the pinned quark derivations. It also generates `~/.config/nvim/tidal-paths.lua`, which `home/development/nvim/lua/plugins/tidal.lua` reads, so the `passthru` store paths stay in one file
- GUI applications that require system-level support (e.g., hardware access, kernel modules) must also be enabled at the NixOS level in `os/`
- KDE-specific theming and integration belongs in `kde.nix`, not scattered across other modules
- Hyprland modules (`hyprland*.nix`) are guarded with `pkgs.stdenv.isLinux && config.my.hyprland.enable`; the NixOS host forwards `my.hyprland` to the user, so the system and home parts follow one switch. Do not read `osConfig`
- User services that should run only with the app (like the yandex-disk unit in `cloud-storage.nix`) live in the app's module, inside its switch. Replacing a hand-made unit or XDG autostart entry with a managed one needs the old file removed by hand first, or activation fails on the existing file
- Nothing Hyprland-only may reach the Plasma session, which also reaches `graphical-session.target`:
  - bind user units to `wayland-session@hyprland.desktop.target` (`wayland.systemd.target`), not `graphical-session.target` or `tray.target`
  - keep packages that ship a D-Bus service or an XDG autostart file (SwayNotificationCenter, `networkmanagerapplet`) out of the profile; a Home Manager module that always installs its package (`services.swaync`) cannot be used, so write the unit by hand
  - check leaks in the Home Manager output (`home-manager-files`, `.config/systemd/user`), not the NixOS `etc/systemd/user` tree
- UWSM runs XDG autostart, so Plasma's autostart apps also start in Hyprland. Suppress one with a systemd drop-in (`ConditionEnvironment=XDG_CURRENT_DESKTOP=KDE`): add its unit to `plasmaOnly` in `hyprland.nix`. Tray apps are then started from the `hyprland.start` hook through `wait-for-tray`, because an app started before Waybar's tray exists gets no icon
- Do not manage `mimeapps.list` or the GTK `settings.ini` from Home Manager: KDE rewrites them at runtime, and activation fails with "would be clobbered"
- Hyprland uses a Lua config (`configType = "lua"`, `hl.*` API). Validate with `Hyprland --verify-config --config <file>` on the generated `hyprland.lua`; it rejects unknown keys. Keep `doc/hyprland.md` in sync when binds change
- KDE's Fonts KCM (`kcm_fonts`/`KXftConfig`) owns no config file of its own: on Apply it rewrites whichever fontconfig file under `~/.config/fontconfig/conf.d/` sorts first, which is one of Home Manager's — turning it from a symlink into a plain file and aborting the next `home-manager` activation ("would be clobbered"). `fonts.nix` sets `force = true` on those entries so activation reclaims them instead of failing. Change font rendering preferences in `fonts.nix`, not in System Settings — a KDE-side change there will keep getting overwritten on the next switch
