# AGENTS.md — home/development/

- Language libraries (numpy and the like) belong in project dev shells, not here.

## Neovim

- `nvim/` is the vendored AstroNvim template; keep local changes small so upstream updates stay easy to diff.
- lazy.nvim fetches the plugins at runtime; never add `programs.neovim.plugins`, because lazy.nvim resets the runtimepath and they would not load.
- Mason stays disabled: language servers, formatters and the `tree-sitter` CLI come from nixpkgs, in the language's module (`tools.nix` when language-agnostic, `neovim.nix` when no module fits).
- A new language server also needs its name in `servers` in `nvim/lua/plugins/astrolsp.lua`.
- Only none-ls and the servers in `formatting.filter` (`astrolsp.lua`) format, so no file is formatted twice.
- `rust_analyzer` comes from `rustup component add rust-analyzer`, not nixpkgs, where it would collide with rustup's proxy.
- `undofile` stays off and `/dev/shm/gopass*` buffers stay out of swap and backup files: both would store decrypted secrets on disk.
- Keep the Code::Stats key sourced before the AstroNvim bootstrap and `withPython3` on: `code-stats-vim` needs both.
- `nvim/lua/plugins/tidal.lua` reads `~/.config/nvim/tidal-paths.lua`, which `home/apps/livecoding.nix` writes; set the `g:tidal_*_fallback` variables in the spec's `init`, because the plugin reads them when it loads.
