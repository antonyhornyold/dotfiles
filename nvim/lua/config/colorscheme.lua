-- lua/config/colorscheme.lua
vim.o.termguicolors = true
vim.o.background = "light"

-- Set Gruvbox Material options before loading the scheme.
vim.g.gruvbox_material_background = "medium"
vim.g.gruvbox_material_foreground = "material"
vim.g.gruvbox_material_transparent_background = 1

vim.cmd.colorscheme("gruvbox-material")
