# AGENTS.md — os/gui/

## What This Directory Is

NixOS modules for the graphical environment. Manages desktop environments, display configuration, fonts, and GUI-layer system services.

## Module List

- `default.nix` — defines `guiModules.common` (flatpak, fonts), `guiModules.kde`, `guiModules.hyprland`, `guiModules.default`
- `flatpak.nix` — Flatpak support and XDG portal configuration
- `fonts.nix` — system font packages and fontconfig
- `hyprland.nix` — Hyprland Wayland compositor with a UWSM session, portal order, PAM service for the lock screen, and the `ksvg` QML module (imported through `guiModules.hyprland`)
- `kde.nix` — KDE Plasma desktop environment, SDDM display manager, and KDE system services
- `torrents.nix` — torrent client system configuration

## Architecture

- `default.nix` aggregates modules into named `guiModules` outputs consumed by machine configurations
- `guiModules` is a custom flake output — it is wired into machine configurations separately from `nixosModules`

## Conventions

- These are NixOS modules, not home-manager modules — options go under `services.*`, `programs.*`, `environment.*`, etc.
- GUI applications that also need home-manager packages should have a corresponding module in `home/apps/`
- `guiModules.hyprland` is opt-in per machine (`wuwei` imports it); Plasma stays the default session. The commented `./hyprland.nix` line in `common` is retained on purpose — leave it in place
- The user-side Hyprland configuration lives in `home/apps/hyprland.nix` and `home/apps/hyprland-shell.nix`; keybindings are documented in `doc/hyprland.md`

## Important Notes

- KDE system configuration lives here; KDE user packages (PIM, Kvantum, kio plugins, etc.) live in `home/apps/kde.nix`
- Lock screen PAM: use `security.pam.services.hyprlock = { }`, not `programs.hyprlock.enable`. The latter also enables a system `hypridle` unit wanted by `graphical-session.target`, which would run in the Plasma session too
- The portal order (`xdg.portal.config.hyprland.default`) applies only when `XDG_CURRENT_DESKTOP=Hyprland`, so it cannot affect Plasma
- `kdePackages.ksvg` is in the system packages because KDE settings pages run from Hyprland (for example `kcm_networkmanagement`) need its QML module, which Plasma's own session wrapper otherwise provides
