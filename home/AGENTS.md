# AGENTS.md — home/

## What This Directory Is

The home-manager configuration layer. Manages user-space packages, dotfiles, program configuration, and shell environment. It is OS-agnostic: the same modules serve Linux (through a NixOS host), Darwin and WSL. Organized into three subdirectories, each with its own `default.nix` aggregator.

## Subpart Documentation

- [`development/AGENTS.md`](development/AGENTS.md) — language toolchains and dev CLIs, Neovim
- [`apps/AGENTS.md`](apps/AGENTS.md) — GUI applications (browsers, editors, media, games, communication, desktop sessions)
- [`tools/AGENTS.md`](tools/AGENTS.md) — CLI utilities, shell configuration, system and hardware tools, networking, documents

## Structure

- `default.nix` — defines the bundles:
  - `homeModules.common` — `home.stateVersion`; imports `../options` (the `my.*` switches), `../lib/available.nix`, `sops.nix`, `./development`, `./apps`, `./tools`
  - `common-linux` — `common` only; a NixOS host forwards its switches through `nixosModules.home`
  - `common-darwin` — `common` plus the Mac's switches (dev and apps on, JetBrains and VS Code off)
  - `common-wsl` — `common` plus WSL's switches (dev on; apps and hardware tools off, since WSL has no GUI)
- `sops.nix` — SOPS secrets for home-manager (age key in the user's config directory; Code::Stats keys, git-town token)
- `development/` — language toolchains and dev CLIs, behind `my.dev.<name>`
- `apps/` — GUI applications, behind `my.apps.<name>` (and `my.hyprland`, `my.kde`)
- `tools/` — CLI tools, always on (except `hardware.nix`, behind `my.tools.hardware`)

## Conventions

- Module signature: `{ pkgs, lib, config, ... }:` — add `flake` only when `flake.config` or `flake.inputs` is needed, and `available` when the module filters packages by platform
- Package lists use `with pkgs;` style
- `home/default.nix` imports subdirectories as units (`./development`, `./apps`, `./tools`) — never import individual files from outside their subdirectory
- To add a new module: create the file in the appropriate subdirectory, add it to that subdirectory's `default.nix`, and add its switch to the group in `options/default.nix`
- `home/default.nix` itself should not need to change when adding new modules, only when a platform bundle changes its switches
- GUI applications go in `apps/`, CLI tools in `development/` or `tools/` (see the root `AGENTS.md`, CLI and GUI)
- Platform handling: wrap package lists in `available` (drops packages that nixpkgs does not build for the platform or marks broken there); give packages with hidden Linux-only dependencies or Darwin build failures an explicit `lib.optionals pkgs.stdenv.isLinux` list with a comment giving the reason; guard Linux-only settings (`xdg.mime`, user units) the same way
- Never read `osConfig`: switches arrive as `config.my.*`, and per-user data comes from `flake.config.people.users.${config.home.username}`

## Important Notes

- SOPS secrets are available via `config.sops.secrets.<name>.path` — `sops.nix` is imported by `homeModules.common`
- `home.stateVersion` is set to `"23.11"` in `homeModules.common` — do not change without understanding the implications
- `just check` builds the WSL home and evaluates the Darwin home; CI also builds the Darwin home on macOS. Run it after adding packages
