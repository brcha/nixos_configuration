# AGENTS.md — home/tools/

## What This Directory Is

Home-manager modules for CLI utilities, system and hardware tools, shell configuration, networking tools, and document processing. These are the base user environment: always on, on every platform, with no GUI applications (those go in `home/apps/`).

## Module List

- `cli.nix` — General CLI utilities (bat, fd, fzf, jq, yq-go, htop, just, mc, httpie, asdf-vm, uutils-coreutils-noprefix, etc.)
- `compression.nix` — Archive and compression tools (zip, unrar, p7zip, zstd, brotli, squashfsTools, etc.)
- `documents.nix` — Document processing (texlive scheme-full, pandoc, pdftk, rubber, bibtex-tidy)
- `hardware.nix` — Hardware and disk tools (lm_sensors, lshw, pciutils, smartmontools, parted, zfs, sanoid, znapzend, appimage-run, can-utils, etc.); behind `my.tools.hardware` (on by default, off on WSL) and Linux only
- `media.nix` — Media CLIs (yt-dlp, ffmpeg-full, imagemagick, povray); adds `mkvtoolnix-cli` where `my.apps.multimedia` (which brings the full MKVToolNix) is off
- `networking.nix` — Network tools (nmap, rustscan, wireguard-tools, aria2, dig, socat, wget, ngrok)
- `productivity.nix` — Productivity CLIs (wakatime-cli, hledger and its tools, html2text, rtmcli)
- `security.nix` — Security CLIs (gopass, gnupg, openssl, clamav, diceware, pcsc-tools)
- `shell.nix` — Shell configuration (zsh, starship, direnv, lsd, zoxide, ripgrep, session variables, aliases); the desktop part (default browser, portal variable, `open` alias, MIME defaults) applies only on Linux with `my.apps.firefox` on
- `system.nix` — System utilities (file, psmisc, sysstat, pwgen, mkpasswd, cachix, etc.)

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
