local clue = require("mini.clue")

clue.setup({
  triggers = {
    { mode = { "n", "x" }, keys = "<Leader>" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
    { mode = "n", keys = "<C-w>" },
  },
  clues = {
    clue.gen_clues.square_brackets(),
    clue.gen_clues.windows(),
    { mode = "n", keys = "<Leader>g", desc = "Toggle Git diff overlay" },
    { mode = "n", keys = "<Leader>r", desc = "Rename symbol" },
  },
  window = {
    config = {
      anchor = "SW",
      row = "auto",
      col = 0,
      width = vim.o.columns - 2,
      border = "none",
      title = "",
    },
  },
})
