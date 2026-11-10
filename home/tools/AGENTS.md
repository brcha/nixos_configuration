# AGENTS.md — home/tools/

## What This Directory Is

Home-manager modules for CLI utilities, system and hardware tools, shell configuration, networking tools, and document processing. These are the base user environment: always on, on every platform, except `hardware.nix` and `tex.nix`, which have their own switches. No GUI applications (those go in `home/apps/`).

## Module List

- `cli.nix` — General CLI utilities (bat, fd, jq, yq-go, htop, just, mc, httpie, uutils-coreutils-noprefix, etc.)
- `compression.nix` — Archive and compression tools (zip, unrar, p7zip, zstd, brotli, squashfsTools, etc.)
- `hardware.nix` — Hardware and disk tools (lm_sensors, lshw, pciutils, smartmontools, parted, can-utils, bootiso, etc.); behind `my.tools.hardware` (on by default, off on WSL) and Linux only. ZFS tools come from the NixOS ZFS setup, and appimage-run from `my.gui.appimage`
- `media.nix` — Media CLIs (yt-dlp, ffmpeg-full, mkvtoolnix-cli, imagemagick, povray)
- `networking.nix` — Network tools (nmap, aria2, dig, inetutils, socat, wget)
- `productivity.nix` — Productivity CLIs (wakatime-cli, hledger and its tools, html2text, pandoc, rtmcli)
- `security.nix` — Security CLIs (gopass, gnupg, openssl, clamav, diceware, pcsc-tools)
- `shell.nix` — Shell configuration (zsh with the code-stats-zsh plugin from the `code-stats-zsh` flake input, starship, direnv, lsd, skim with its zsh keys, zoxide, ripgrep, session variables, aliases including the `rgs` and `rgsp` live searches); the desktop part (default browser, portal variable, `open` alias, MIME defaults) applies only on Linux with `my.apps.firefox` on
- `system.nix` — System utilities (file, psmisc, sysstat, pwgen, mkpasswd, xattr, cachix, etc.) and comma (`, <command>` runs a nixpkgs program without installing it), from the nix-index-database home module imported in `home/default.nix`; the prebuilt database also provides the shell's command-not-found handler
- `tex.nix` — TeX Live scheme-full, rubber and bibtex-tidy; behind `my.tools.tex` (on by default, off in `common-darwin`)

## Architecture

- `default.nix` aggregates all modules in this directory via `imports`
- `home/default.nix` imports this directory as a unit — do not import individual files from outside
- Each module is self-contained and focused on a single utility domain

## Conventions

- Module signature: `{ pkgs, lib, ... }:` — add `config`, `available` or `flake` only when needed
- Package lists use `with pkgs;` style; wrap them in `available` when a package may be missing on a platform, so it drops out there
- Follow the naming pattern established by existing files (`category.nix`)
- To add a new module:
  1. Create `<name>.nix` in this directory
  2. Add it to the `imports` list in `default.nix`
- Shell snippets in Nix strings (`initContent`, `siteFunctions`, etc.): inside `''...''`,
  only `${` triggers Nix interpolation. A bare shell variable like `$branch` needs no
  escaping. If you actually need literal `${...}` (e.g. `${branch}` for the shell, not Nix),
  escape it as `''${branch}` — two single quotes before the `$`.

## Important Notes

- `shell.nix` is the primary shell environment definition — it sets `home.sessionVariables`, `home.sessionPath`, `home.shellAliases`, and `xdg` settings in addition to program configuration; changes here affect the entire user environment. Per-user values (weather city, ledger and todo files) come from `flake.config.people`
- Tools that require kernel modules or udev rules must also be enabled at the NixOS level in `os/`
- A package that always builds a GUI belongs in `home/apps/`, even when it also ships CLI tools
- Prefer `uutils-coreutils` over GNU coreutils where already established — do not mix both for the same utilities
