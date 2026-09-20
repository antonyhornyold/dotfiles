-- lua/config/colorscheme.lua
vim.o.termguicolors = true
vim.o.background = "dark"

require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
  custom_highlights = function(colors)
    return {
      OilFloatTop = { fg = colors.surface2, bg = colors.none },
    }
  end,
})

vim.cmd.colorscheme("catppuccin-mocha")
