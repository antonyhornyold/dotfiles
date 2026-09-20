vim.pack.add({
  "https://github.com/sainnhe/gruvbox-material",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason-lspconfig.nvim",
})

require("mini.icons").setup()
require("mini.pairs").setup()
require("mini.surround").setup({
  mappings = { replace = "cs" },
})

require("oil").setup({
  columns = { "icon" },
  keymaps = {
    ["q"] = "actions.close",
  },
  float = {
    max_width = 0.5,
    max_height = 0.5,
    border = "solid",
    get_win_title = function()
      return " Oil "
    end,
    win_options = {
      winbar = "%=%<%{v:lua.require('oil').get_current_dir()}%=",
      winhighlight = "FloatTitle:MasonHeader,WinBar:NormalFloat,WinBarNC:NormalFloat",
      number = false,
      relativenumber = false,
    },
    override = function(config)
      local layout = require("oil.layout")
      local width = layout.get_editor_width()
      local height = layout.get_editor_height()

      -- Prefer half the screen, but keep the explorer usable in smaller panes.
      -- Leave room for the solid border and a margin on each side.
      config.width = math.min(math.max(config.width, 44), math.max(1, width - 4))
      config.height = math.min(math.max(config.height, 12), math.max(1, height - 4))
      config.row = math.max(0, math.floor((height - config.height - 2) / 2))
      config.col = math.max(0, math.floor((width - config.width - 2) / 2))
      config.title = " Oil "
      config.title_pos = "center"
      return config
    end,
  },
})
