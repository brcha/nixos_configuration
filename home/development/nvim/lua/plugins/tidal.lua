-- vim-tidal, configured from the store paths that home/apps/livecoding.nix generates.
-- The paths file is absent on non-Linux machines; the spec is skipped there.
local paths_file = vim.fn.stdpath "config" .. "/tidal-paths.lua"
if not vim.uv.fs_stat(paths_file) then return {} end
local paths = dofile(paths_file)

---@type LazySpec
return {
  {
    "tidalcycles/vim-tidal",
    ft = "tidal",
    -- g:tidal_boot and g:tidal_sc_boot_cmd are computed from the *_fallback variables when
    -- plugin/tidal.vim is sourced, so these must be set in `init`, before the plugin loads.
    init = function()
      vim.g.tidal_ghci = paths.ghci
      vim.g.tidal_boot_fallback = paths.boot
      vim.g.tidal_sc_enable = 1
      vim.g.tidal_sclang = paths.sclang
      vim.g.tidal_sc_boot_fallback = paths.boot_scd
    end,
  },
}
