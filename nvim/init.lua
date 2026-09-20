vim.g.mapleader = " "

require("config.options")
require("vim._core.ui2").enable({})
vim.g.tiny_cmdline = { native_types = {} }
require("config.plugins")
require("config.colorscheme")
require("config.oil")

require("config.completion")
require("config.lsp")
require("config.treesitter")
require("config.formatting")
require("config.lint")

require("config.keymaps")
require("config.statusline")

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
