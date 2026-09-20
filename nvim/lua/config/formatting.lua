require("conform").setup({
  formatters_by_ft = {
    html = { "prettier" },
    css = { "prettier" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    lua = { "stylua" },
    zsh = { "shfmt_zsh" },
  },
  formatters = {
    shfmt_zsh = {
      inherit = "shfmt",
      append_args = { "-ln", "zsh" },
    },
  },
  format_on_save = {
    timeout_ms = 1000,
  },
})
