local lint = require("lint")

lint.linters_by_ft = {
  lua = { "luacheck" },
  html = { "htmlhint" },
  css = { "stylelint" },
  javascript = { "eslint" },
  typescript = { "eslint" },
  javascriptreact = { "eslint" },
  typescriptreact = { "eslint" },
}

-- Neovim provides `vim` at runtime, so it is not an undefined global.
vim.list_extend(lint.linters.luacheck.args, { "--globals", "vim" })

-- Keep HTMLHint to semantic checks; Prettier handles HTML layout and quotes.
vim.list_extend(lint.linters.htmlhint.args, {
  "--rules",
  "alt-require,frame-title-require,button-type-require,html-lang-require,id-unique",
})

local configs = {
  eslint = {
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    "eslint.config.ts",
    "eslint.config.mts",
    "eslint.config.cts",
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.json",
  },
  stylelint = {
    "stylelint.config.js",
    "stylelint.config.mjs",
    "stylelint.config.cjs",
    "stylelint.config.ts",
    ".stylelintrc",
    ".stylelintrc.js",
    ".stylelintrc.cjs",
    ".stylelintrc.json",
    ".stylelintrc.yml",
    ".stylelintrc.yaml",
  },
}

local function project_linter(name, filename)
  local dir = vim.fs.dirname(filename)
  local config = vim.fs.find(configs[name], { path = dir, upward = true })[1]
  if not config then
    return nil
  end

  local root = vim.fs.dirname(config)
  local current = dir
  while current do
    local binary = current .. "/node_modules/.bin/" .. name
    if vim.uv.fs_stat(binary) then
      return binary, root
    end
    local parent = vim.fs.dirname(current)
    if parent == current then
      break
    end
    current = parent
  end
end

local group = vim.api.nvim_create_augroup("ConfiguredLint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  group = group,
  callback = function(args)
    local filename = vim.api.nvim_buf_get_name(args.buf)
    if filename == "" then
      return
    end

    local names = lint.linters_by_ft[vim.bo[args.buf].filetype]
    if not names then
      return
    end

    for _, name in ipairs(names) do
      if configs[name] then
        local binary, root = project_linter(name, filename)
        if binary then
          lint.try_lint(name, {
            cwd = root,
            wrap_linter = function(linter)
              linter.cmd = binary
              return linter
            end,
          })
        end
      elseif vim.fn.executable(lint.linters[name].cmd) == 1 then
        lint.try_lint(name)
      end
    end
  end,
})
