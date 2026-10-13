-- Plugins that were previously provided through nixpkgs or vim-plug.
-- The Code::Stats key is sourced from SOPS by the generated init.lua before lazy.nvim starts.

---@type LazySpec
return {
  { url = "https://gitlab.com/code-stats/code-stats-vim.git", event = "VeryLazy" },
  -- picks up `wakatime-cli` from PATH (home/apps/productivity.nix), so it never self-downloads
  { "wakatime/vim-wakatime", lazy = false },
  "ledger/vim-ledger",
  "NoahTheDuke/vim-just",
}
