-- Tag completion needs a parser for the current filetype (e.g. html or tsx).
require("nvim-treesitter").install({ "dockerfile", "html", "javascript", "typescript", "tsx", "sql", "yaml", "prisma" })

require("nvim-ts-autotag").setup({
  opts = {
    enable_close = true,
    enable_rename = true,
  },
})

vim.treesitter.language.register("javascript", "javascriptreact")
vim.treesitter.language.register("tsx", "typescriptreact")

local group = vim.api.nvim_create_augroup("ConfiguredTreesitter", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = {
    "dockerfile",
    "html",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "lua",
    "sql",
    "yaml",
    "prisma",
  },
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if lang and vim.treesitter.language.add(lang) then
      vim.treesitter.start(args.buf, lang)
    end
  end,
})
