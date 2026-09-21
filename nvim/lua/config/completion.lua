local snippets = require("mini.snippets")

snippets.setup({
  snippets = {
    snippets.gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/global.json"),
    snippets.gen_loader.from_lang(),
  },
  mappings = {
    expand = "<C-j>",
    jump_next = "<C-l>",
    jump_prev = "<C-h>",
    stop = "<C-c>",
  },
})

snippets.start_lsp_server({ match = false })
require("mini.completion").setup()
