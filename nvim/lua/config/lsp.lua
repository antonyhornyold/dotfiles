vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
    },
  },
})

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "ts_ls",
    "html",
    "cssls",
    "jsonls",
    "tailwindcss",
  },
  automatic_enable = {
    "lua_ls",
    "ts_ls",
    "html",
    "cssls",
    "jsonls",
    "tailwindcss",
  },
})
