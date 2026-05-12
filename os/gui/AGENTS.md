# AGENTS.md — os/gui/

## What This Directory Is

NixOS modules for the graphical environment. Manages desktop environments, display configuration, fonts, and GUI-layer system services.

## Module List

- `default.nix` — defines `guiModules.common` (flatpak, fonts), `guiModules.kde`, `guiModules.default`; `hyprland.nix` is currently disabled
- `flatpak.nix` — Flatpak support and XDG portal configuration
- `fonts.nix` — system font packages and fontconfig
- `hyprland.nix` — Hyprland Wayland compositor (currently disabled)
- `kde.nix` — KDE Plasma desktop environment, SDDM display manager, and KDE system services
- `torrents.nix` — torrent client system configuration

## Architecture

- `default.nix` aggregates modules into named `guiModules` outputs consumed by machine configurations
- `guiModules` is a custom flake output — it is wired into machine configurations separately from `nixosModules`

## Conventions

- These are NixOS modules, not home-manager modules — options go under `services.*`, `programs.*`, `environment.*`, etc.
- GUI applications that also need home-manager packages should have a corresponding module in `home/apps/`
- `hyprland.nix` is commented out in `default.nix` — leave the comment in place

## Important Notes

- KDE system configuration lives here; KDE user packages (PIM, Kvantum, kio plugins, etc.) live in `home/apps/kde.nix`
- `hyprland.nix` exists but is disabled — do not delete it; it is retained for future use
