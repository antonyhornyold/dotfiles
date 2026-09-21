local fzf = require("fzf-lua")

fzf.setup({
  defaults = { file_icons = "mini" },
  winopts = {
    width = 0.8,
    height = 0.7,
    row = 0.5,
    col = 0.5,
    border = "rounded",
    title_pos = "center",
    preview = {
      layout = "flex",
      title_pos = "center",
    },
  },
  hls = {
    normal = "NormalFloat",
    border = "FloatBorder",
    title = "MasonHeader",
    preview_normal = "NormalFloat",
    preview_border = "FloatBorder",
    preview_title = "MasonHeader",
  },
})

vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", fzf.blines, { desc = "Search current buffer" })
vim.keymap.set("n", "<leader>fG", fzf.live_grep, { desc = "Search project text" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Switch buffers" })
