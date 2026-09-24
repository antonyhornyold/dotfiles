-- Press jk in insert mode to return to normal mode.
vim.keymap.set("i", "jk", "<Esc>", {
  desc = "Exit insert mode",
})

local closing_chars = { [")"] = true, ["]"] = true, ["}"] = true, ['"'] = true, ["'"] = true, ["`"] = true }

vim.keymap.set("i", "<M-l>", function()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local count = 0

  while closing_chars[line:sub(col + count + 1, col + count + 1)] do
    count = count + 1
  end

  return string.rep("<Right>", count)
end, { expr = true, desc = "Move past adjacent closing pairs" })

vim.keymap.set("n", "-", "<cmd>Oil --float<CR>", {
  desc = "Open floating file explorer",
})

vim.keymap.set("n", "<leader>go", function()
  local diff = require("mini.diff")
  if diff.get_buf_data(0) then
    diff.toggle_overlay(0)
  end
end, { desc = "Toggle Git diff overlay" })

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true })
end, { desc = "Format buffer or selection" })

vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })

vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = "Previous diagnostic" })

vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {
  desc = "Code action",
})

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {
  desc = "Rename symbol",
})
