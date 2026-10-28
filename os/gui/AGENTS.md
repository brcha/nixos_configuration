# AGENTS.md — os/gui/

## What This Directory Is

NixOS modules for the graphical environment. Manages desktop environments, display configuration, fonts, and GUI-layer system services.

## Module List

- `default.nix` — defines `nixosModules.gui` (`options.nix`, `flatpak.nix`, `fonts.nix`, `ssh-agent.nix`, `torrents.nix`), `nixosModules.kde` and `nixosModules.hyprland`; `nixosModules.default` imports all three
- `options.nix` — the `my.gui` group: `my.gui.enable` with children `flatpak`, `fonts`, `sshAgent`, `torrents`
- `flatpak.nix` — Flatpak support and XDG portal configuration (`my.gui.flatpak`)
- `fonts.nix` — system font packages and fontconfig (`my.gui.fonts`)
- `hyprland.nix` — Hyprland Wayland compositor with a UWSM session, portal order, PAM service for the lock screen, and the `ksvg` QML module (`my.hyprland.enable`)
- `kde.nix` — KDE Plasma desktop environment, SDDM display manager, and KDE system services (`my.kde.enable`)
- `ssh-agent.nix` — gcr-ssh-agent and the gcr 3 prompter it asks key passphrases with, for any desktop (`my.gui.sshAgent`)
- `torrents.nix` — Sonarr, Jackett, FlareSolverr and their nginx hosts, torrent clients (`my.gui.torrents`)

## Architecture

- `my.kde.enable` and `my.hyprland.enable` assert `my.gui.enable`
- `my.kde` and `my.hyprland` are shared switches (declared in `options/default.nix`): the same switch turns on the system module here and the home modules in `home/apps/`

## Conventions

- These are NixOS modules, not home-manager modules — options go under `services.*`, `programs.*`, `environment.*`, etc.
- GUI applications that also need home-manager packages should have a corresponding module in `home/apps/`
- With `my.hyprland.enable` on, Hyprland (`hyprland-uwsm`) is the default SDDM session and Plasma stays in the list; `kde.nix` sets `plasma` with `lib.mkDefault`, so a machine without Hyprland still defaults to Plasma. SDDM's remembered session is lost with the root rollback on `wuwei`, which is why the default matters. The commented `./hyprland.nix` line in `nixosModules.gui` is retained on purpose — leave it in place
- The keyboard layout and options in `kde.nix` are `lib.mkDefault` defaults; a machine overrides what differs
- The user-side Hyprland configuration lives in `home/apps/hyprland.nix` and `home/apps/hyprland-shell.nix`; keybindings are documented in `doc/hyprland.md`

## Important Notes

- KDE system configuration lives here; KDE user packages (PIM, Kvantum, kio plugins, etc.) live in `home/apps/kde.nix`
- Lock screen PAM: use `security.pam.services.hyprlock = { }`, not `programs.hyprlock.enable`. The latter also enables a system `hypridle` unit wanted by `graphical-session.target`, which would run in the Plasma session too
- The portal order (`xdg.portal.config.hyprland.default`) applies only when `XDG_CURRENT_DESKTOP=Hyprland`, so it cannot affect Plasma
- `kdePackages.ksvg` is in the system packages because KDE settings pages run from Hyprland (for example `kcm_networkmanagement`) need its QML module, which Plasma's own session wrapper otherwise provides
