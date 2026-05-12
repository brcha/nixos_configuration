# AGENTS.md — home/tools/

## What This Directory Is

Home-manager modules for CLI utilities, system administration tools, shell configuration, networking tools, and document processing.

## Module List

- `cli.nix` — General CLI utilities (bat, fd, fzf, jq, htop, httpie, asdf-vm, uutils-coreutils, etc.)
- `compression.nix` — Archive and compression tools (zip, unrar, p7zip, zstd, brotli, etc.)
- `documents.nix` — Document processing (texlive, pandoc, pdftk, rubber, bibtex-tidy)
- `networking.nix` — Network tools (nmap, wireguard, protonvpn, aria2, socat, ngrok, ktailctl)
- `shell.nix` — Shell configuration (zsh, starship, direnv, lsd, zoxide, session variables, aliases)
- `system.nix` — System administration tools (hardware info, filesystem utils, storage, display tools, openrazer)

## Architecture

- `default.nix` aggregates all modules in this directory via `imports`
- `home/default.nix` imports this directory as a unit — do not import individual files from outside
- Each module is self-contained and focused on a single utility domain

## Conventions

- Module signature: `{ pkgs, ... }:` — add `flake` only when `flake.config` or `flake.inputs` is needed
- Package lists use `with pkgs;` style
- Follow the naming pattern established by existing files (`category.nix`)
- To add a new module:
  1. Create `<name>.nix` in this directory
  2. Add it to the `imports` list in `default.nix`

## Important Notes

- `shell.nix` is the primary shell environment definition — it sets `home.sessionVariables`, `home.sessionPath`, `home.shellAliases`, and `xdg` settings in addition to program configuration; changes here affect the entire user environment
- Tools that require kernel modules or udev rules (e.g., openrazer) must also be enabled at the NixOS level in `os/`
- Prefer `uutils-coreutils` over GNU coreutils where already established — do not mix both for the same utilities
