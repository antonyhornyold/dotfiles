-- Save and re-run current Lua file do not use for statusline.lua
vim.keymap.set("n", "<leader>rr", "<cmd>update<CR><cmd>luafile %<CR>", {
  desc = "Save and reload current Lua file",
})

-- Press jk in insert mode to return to normal mode.
vim.keymap.set("i", "jk", "<Esc>", {
  desc = "Exit insert mode",
})

vim.keymap.set("n", "-", "<cmd>Oil --float<CR>", {
  desc = "Open floating file explorer",
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
  require("conform").format({ async = true })
end, { desc = "Format buffer or selection" })
