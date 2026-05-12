# AGENTS.md — home/apps/

## What This Directory Is

Home-manager modules for end-user GUI applications: browsers, media players, creative tools, games, communication apps, and security utilities.

## Module List

- `cloud-storage.nix` — Cloud sync clients (yandex-disk, megasync, onedrive, dropbox)
- `communication.nix` — Messaging and video conferencing (telegram, discord, zoom)
- `firefox.nix` — Firefox browser configuration
- `gaming.nix` — Gaming (steam with Vulkan/OpenGL override, protontricks)
- `graphics.nix` — Graphics and creative tools (gimp, krita, inkscape, scribus, synfigstudio, sweethome3d)
- `kde.nix` — KDE Plasma extras (PIM suite, Kvantum, kio plugins, remote desktop)
- `multimedia.nix` — Media players and editors (mpv, vlc, spotify, obs-studio, kdenlive, ffmpeg, lmms)
- `productivity.nix` — Productivity apps (joplin, clockify, wakatime, hledger, libreoffice, zeal)
- `security.nix` — Security tools (tor-browser, gopass, clamav, gnupg, pcsc-tools)

## Architecture

- `default.nix` aggregates all modules in this directory via `imports`
- `home/default.nix` imports this directory as a unit — do not import individual files from outside
- Each module is self-contained and focused on a single application category

## Conventions

- Module signature: `{ pkgs, ... }:` — add `flake` only when `flake.config` or `flake.inputs` is needed
- Package lists use `with pkgs;` style
- Follow the naming pattern established by existing files (`category.nix`)
- To add a new module:
  1. Create `<name>.nix` in this directory
  2. Add it to the `imports` list in `default.nix`

## Important Notes

- `gaming.nix` uses a `steam.override { extraPkgs = pkgs: [...]; }` closure to inject Vulkan/OpenGL libraries — preserve this pattern exactly when modifying Steam configuration
- GUI applications that require system-level support (e.g., hardware access, kernel modules) must also be enabled at the NixOS level in `os/`
- KDE-specific theming and integration belongs in `kde.nix`, not scattered across other modules
