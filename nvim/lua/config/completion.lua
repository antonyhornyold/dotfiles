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

vim.keymap.set("i", "<C-g><C-j>", function()
  snippets.expand({ match = false })
end, { desc = "Browse available snippets" })

snippets.start_lsp_server({ match = false })
require("mini.completion").setup()

local map_multistep = require("mini.keymap").map_multistep

-- Preserve indentation before any text, unless a snippet is already active.
local indent_before_text = {
  condition = function()
    if snippets.session.get() then return false end
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
    return before_cursor:match("^%s*$") ~= nil
  end,
  action = function() return "<Tab>" end,
}

map_multistep("i", "<Tab>", {
  indent_before_text,
  "pmenu_next",
  "minisnippets_next",
  "minisnippets_expand",
}, { desc = "Indent, select completion, or advance snippet" })

map_multistep("i", "<S-Tab>", {
  "pmenu_prev",
  "minisnippets_prev",
}, { desc = "Previous completion or snippet placeholder" })

map_multistep("i", "<CR>", {
  "pmenu_accept",
  "minipairs_cr",
}, { desc = "Accept completion or insert newline" })
