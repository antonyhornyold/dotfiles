vim.g.mapleader = " "

require("config.options")
require("vim._core.ui2").enable({})
vim.g.tiny_cmdline = {
  native_types = {},
  position = { x = "50%", y = "25%" },
}
require("config.plugins")
require("config.cmdline")
require("config.colorscheme")
require("config.oil")
require("config.fzf")

require("config.completion")
require("config.lsp")
require("config.treesitter")
require("config.formatting")
require("config.lint")

require("config.keymaps")
require("config.terminal")
require("config.clue")
require("config.statusline")
require("config.starter")

local reload_group = vim.api.nvim_create_augroup("ReloadStatusline", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
  group = reload_group,
  pattern = "*/lua/config/statusline.lua",
  callback = function()
    package.loaded["config.statusline"] = nil
    require("config.statusline")
    vim.cmd.redrawstatus()
  end,
})
