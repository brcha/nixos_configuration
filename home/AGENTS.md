# AGENTS.md — home/

## What This Directory Is

The home-manager configuration layer. Manages user-space packages, dotfiles, program configuration, and shell environment. Organized into three subdirectories, each with its own `default.nix` aggregator.

## Subpart Documentation

- [`development/AGENTS.md`](development/AGENTS.md) — language toolchains, editors, IDEs, VCS, formatters, AI tools
- [`apps/AGENTS.md`](apps/AGENTS.md) — end-user GUI applications (browser, media, games, communication, security)
- [`tools/AGENTS.md`](tools/AGENTS.md) — CLI utilities, shell configuration, system tools, networking, documents

## Structure

- `default.nix` — top-level home-manager module aggregator; defines `homeModules.common`, `common-linux`, `common-darwin`, `common-wsl`; imports `./development`, `./apps`, `./tools`, and `sops.nix`
- `sops.nix` — SOPS secrets configuration for home-manager (secret paths, ownership)
- `vscode.nix` — VSCode configuration (currently disabled/commented out in `default.nix`)
- `development/` — language toolchains, editors, IDEs, VCS, formatters, AI tools
- `apps/` — end-user GUI applications
- `tools/` — CLI utilities, shell, system tools, networking, documents

## Conventions

- Module signature: `{ pkgs, ... }:` — add `flake` only when `flake.config` or `flake.inputs` is needed
- Package lists use `with pkgs;` style
- `home/default.nix` imports subdirectories as units (`./development`, `./apps`, `./tools`) — never import individual files from outside their subdirectory
- To add a new module: create the file in the appropriate subdirectory and add it to that subdirectory's `default.nix` only
- `home/default.nix` itself should not need to change when adding new modules
- `homeModules.common` is shared across Linux, Darwin, and WSL — avoid platform-specific packages here; use `lib.optionals` or separate `common-linux`/`common-darwin` modules for platform-specific additions

## Important Notes

- SOPS secrets are available via `config.sops.secrets.<name>.path` — `sops.nix` must be imported before any module that references secrets
- `home.stateVersion` is set to `"23.11"` in `homeModules.common` — do not change without understanding the implications
