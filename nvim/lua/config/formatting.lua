require("conform").setup({
  formatters_by_ft = {
    html = { "prettier" },
    css = { "prettier" },
    javascript = { "prettier" },
    lua = { "stylua" },
  },
  format_on_save = {
    timeout_ms = 1000,
  },
})
