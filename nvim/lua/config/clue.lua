require("mini.clue").setup({
  triggers = {
    { mode = { "n", "x" }, keys = "<Leader>" },
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
