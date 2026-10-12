-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Keep gopass temporary buffers out of swap, backup and undo files
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "/dev/shm/gopass*",
  desc = "Disable swap, backup and undo files for gopass buffers",
  callback = function()
    vim.opt_local.swapfile = false
    vim.opt_local.backup = false
    vim.opt_local.undofile = false
  end,
})
