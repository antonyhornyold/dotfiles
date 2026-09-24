-- lua/config/colorscheme.lua
vim.o.termguicolors = true
vim.o.background = "dark"

require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
  custom_highlights = function(colors)
    return {
      OilFloatTop = { fg = colors.surface2, bg = colors.none },
      MiniStarterBorder = { fg = colors.surface1 },
      MiniStarterHeader = { fg = colors.blue, bold = true },
      MiniStarterFooter = { fg = colors.overlay2 },
      MiniStarterSection = { fg = colors.subtext0, bold = true },
      MiniStarterItem = { fg = colors.subtext0 },
      MiniStarterCurrent = { fg = colors.text, bold = true },
      MiniStarterItemPrefix = { fg = colors.lavender },
    }
  end,
})

vim.cmd.colorscheme("catppuccin-mocha")
