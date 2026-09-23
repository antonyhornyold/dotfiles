vim.filetype.add({ extension = { mdx = "markdown.mdx" } })

require("conform").setup({
  formatters_by_ft = {
    html = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    markdown = { "prettier" },
    ["markdown.mdx"] = { "prettier" },
    yaml = { "prettier" },
    sql = { "pg_format" },
    lua = { "stylua" },
    zsh = { "shfmt_zsh" },
  },
  formatters = {
    shfmt_zsh = {
      inherit = "shfmt",
      append_args = { "-ln", "zsh" },
    },
  },
  format_on_save = function(bufnr)
    -- Keep SQL migration formatting explicit so its diff can be reviewed.
    if vim.bo[bufnr].filetype == "sql" then
      return nil
    end
    return { timeout_ms = 1000 }
  end,
})
