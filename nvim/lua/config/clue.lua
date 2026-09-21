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
  },
  window = {
    config = {
      anchor = "SW",
      row = "auto",
      col = 0,
      width = vim.o.columns - 2,
      title = "",
    },
  },
})
