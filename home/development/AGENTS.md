# AGENTS.md — home/development/

## What This Directory Is

Home-manager modules for development tooling: language toolchains, version control, formatters, language servers, Neovim, and AI coding assistants. CLI only: IDEs, GUI editors and other dev GUIs live in `home/apps/` (`jetbrains.nix`, `vscode.nix`, `editors.nix`, `dev-tools.nix`).

Each module is behind its own switch, `my.dev.<file name>` (for example `my.dev.cpp`); `my.dev.enable` turns them all on.

## Module List

- `ai.nix` — AI coding assistants (claude-code, opencode)
- `cpp.nix` — C/C++ toolchain (clang, clang-tools, clang-analyzer, ccls, cmake, ninja, gdb, lldb, pkg-config) and neocmakelsp; valgrind on Linux only. clang-analyzer has low priority, since on macOS it ships the same scripts as clang-tools
- `databases.nix` — Database CLIs (sqlite)
- `devops.nix` — Cloud CLIs, IaC, container/k8s tools (doctl, caddy, devbox, devenv, terraform, pulumi, k9s, helm)
- `git.nix` — Git program configuration (signing, aliases, settings, delta, LFS)
- `git-tools.nix` — Git ecosystem packages (git-town, delta, git-cliff, github-cli, glab, gitleaks, pre-commit, etc.)
- `go.nix` — Go toolchain (go, gotools)
- `haskell.nix` — Haskell toolchain (ghc, stack) and formatters (cabal-fmt, stylish-haskell)
- `neovim.nix` — Neovim with AstroNvim (see [Neovim / AstroNvim](#neovim--astronvim)); config lives in `nvim/`
- `python.nix` — Python toolchain and packages, including python-lsp-server
- `rust.nix` — Rust toolchain (rustup, cargo-*, sccache, trunk, wasm-pack, diesel-cli)
- `tools.nix` — Language-agnostic dev tools: formatters and linters (nixpkgs-fmt, shfmt, fantomas, stylelint, markdownlint-cli, cmake-format, whatstyle), doc generators (doxygen, graphviz, plantuml), analysis tools (loccount)
- `vcs.nix` — Non-git version control systems (mercurial, darcs, pijul, quilt, subversion)
- `web.nix` — Web/JS toolchain (nodejs, yarn, prettier, heroku, hugo) and language servers (vtsls, svelte, tailwindcss, graphql, vscode-langservers-extracted)

## Architecture

- `default.nix` aggregates all modules in this directory via `imports`
- `home/default.nix` imports this directory as a unit — do not import individual files from outside
- Each module is self-contained and focused on a single language or tooling domain

## Neovim / AstroNvim

- `neovim.nix` enables `programs.neovim` and links `nvim/lua` to `~/.config/nvim/lua`; `nvim/init.lua` is appended to the generated `init.lua`.
- `nvim/` is the AstroNvim v6 template, vendored from `AstroNvim/template` at commit `49a7161`. Keep local changes minimal so upstream updates stay easy to diff.
- Plugins are not managed by Nix. lazy.nvim fetches them at runtime, so the first launch after a switch needs network access. Do not add `programs.neovim.plugins`: lazy.nvim resets the runtimepath and they would not load.
- The template's `mason.lua` stays disabled, so Mason auto-installs nothing. Language servers, formatters and the `tree-sitter` CLI come from nixpkgs:
  - servers without a language module live in `neovim.nix`;
  - servers and formatters tied to a language live in that language's module (`cpp.nix`, `web.nix`, `python.nix`, `haskell.nix`), or in `tools.nix` when language-agnostic.
- Adding a language server: install the package, then list the server name in `servers` in `nvim/lua/plugins/astrolsp.lua`.
- Formatting goes through none-ls (`nvim/lua/plugins/none-ls.lua`). `formatting.filter` in `astrolsp.lua` allows only `null-ls`, `clangd`, `rust_analyzer` and `taplo` to format, so other servers do not format a second time.
- `rust_analyzer` comes from the rustup component, not nixpkgs (`rustup` ships a proxy that would collide). Run `rustup component add rust-analyzer`.
- `undofile` is disabled on purpose: persistent undo would store decrypted sops/gopass contents on disk. `polish.lua` also keeps `/dev/shm/gopass*` buffers out of swap and backup files.
- Flakes ignore untracked files: `git add` new files under `nvim/` before `just build`.
- `nvim/lua/plugins/tidal.lua` configures vim-tidal from `~/.config/nvim/tidal-paths.lua`, which `home/apps/livecoding.nix` generates (store paths of GHCi, boot file and sclang). The spec is skipped when that file is absent. The `g:tidal_*_fallback` variables are read when the plugin loads, so they must be set in the spec's `init`.

## Conventions

- Module signature: `{ pkgs, lib, config, ... }:` — add `flake` only when `flake.config` or `flake.inputs` is needed
- Wrap the module body in `config = lib.mkIf config.my.dev.<name> { ... };`
- Package lists use `with pkgs;` style
- Follow the naming pattern established by existing files (`language.nix`, `tool-category.nix`)
- To add a new module:
  1. Create `<name>.nix` in this directory
  2. Add it to the `imports` list in `default.nix`
  3. Add `<name>` to the `my.dev` children in `options/default.nix`

## Important Notes

- Prefer `pkgs.unstable.*` for fast-moving tooling (language servers, formatters, AI tools)
- Platform-specific packages should be guarded with `lib.optionals pkgs.stdenv.isLinux [...]` and a comment giving the reason
- A tool that always builds a GUI (heaptrack, for example) goes in `home/apps/`, not here
- `neovim.nix` may reference SOPS secrets via `config.sops.secrets.*` — do not simplify away those references. The Code::Stats key is sourced before the AstroNvim bootstrap so `code-stats-vim` can read it.
