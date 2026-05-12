# AGENTS.md — home/development/

## What This Directory Is

Home-manager modules for development tooling: language toolchains, editors, IDEs, version control tools, formatters, and AI coding assistants.

## Module List

- `ai.nix` — AI coding assistants and AI-native editors (claude-code, claude-desktop, opencode, zed-editor)
- `cpp.nix` — C/C++ toolchain (clang, cmake, ninja, gdb, lldb, valgrind, profilers)
- `databases.nix` — Database clients and GUIs (sqlite, pgmanage, dbeaver-bin)
- `devops.nix` — Cloud CLIs, IaC, container/k8s tools (doctl, terraform, pulumi, k9s, helm)
- `git.nix` — Git program configuration (signing, aliases, settings, difftastic)
- `git-tools.nix` — Git ecosystem packages (git-town, delta, git-cliff, github-cli, glab, etc.)
- `go.nix` — Go toolchain (go, gotools)
- `haskell.nix` — Haskell toolchain (ghc, stack)
- `jetbrains.nix` — JetBrains IDEs (clion, goland, pycharm, rust-rover, datagrip, webstorm)
- `neovim.nix` — Neovim editor configuration and plugins
- `python.nix` — Python toolchain and packages
- `rust.nix` — Rust toolchain (rustup, cargo-*, sccache, trunk, wasm-pack, diesel-cli)
- `tools.nix` — Language-agnostic dev tools: formatters (nixpkgs-fmt, shfmt, fantomas, stylelint), doc generators (doxygen, graphviz, plantuml), analysis tools (loccount)
- `vcs.nix` — Non-git version control systems (mercurial, darcs, pijul, subversion)
- `web.nix` — Web/JS toolchain (nodejs, yarn, prettier, vercel, heroku, hugo)

## Architecture

- `default.nix` aggregates all modules in this directory via `imports`
- `home/default.nix` imports this directory as a unit — do not import individual files from outside
- Each module is self-contained and focused on a single language or tooling domain

## Conventions

- Module signature: `{ pkgs, ... }:` — add `flake` only when `flake.config` or `flake.inputs` is needed
- Package lists use `with pkgs;` style
- Follow the naming pattern established by existing files (`language.nix`, `tool-category.nix`)
- To add a new module:
  1. Create `<name>.nix` in this directory
  2. Add it to the `imports` list in `default.nix`

## Important Notes

- Prefer `pkgs.unstable.*` for fast-moving tooling (language servers, formatters, AI tools)
- Platform-specific packages should be guarded with `lib.optionals stdenv.isLinux [...]`
- `neovim.nix` may reference SOPS secrets via `config.sops.secrets.*` — do not simplify away those references
