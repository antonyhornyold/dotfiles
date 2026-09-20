-- Tag completion needs a parser for the current filetype (e.g. html or tsx).
require("nvim-treesitter").install({ "html", "javascript", "tsx" })

require("nvim-ts-autotag").setup({
  opts = {
    enable_close = true,
    enable_rename = true,
  },
})

local group = vim.api.nvim_create_augroup("ConfiguredTreesitter", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "html", "javascriptreact", "typescriptreact" },
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if lang and vim.treesitter.language.add(lang) then
      vim.treesitter.start(args.buf, lang)
    end
  end,
})
