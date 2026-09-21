local opt = vim.opt

-- Keep the end of the buffer visually blank instead of showing ~
opt.fillchars:append({ eob = " " })

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Two-space indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true

-- Useful editing defaults
opt.signcolumn = "yes" -- Prevent the text moving when diagnostics appear
vim.diagnostic.config({ virtual_text = { current_line = true, spacing = 2 } })
opt.scrolloff = 5 -- Keep five lines visible around the cursor
opt.sidescrolloff = 5
opt.ignorecase = true -- Case-insensitive search...
opt.smartcase = true -- ...unless the search contains a capital letter
opt.splitbelow = true
opt.splitright = true
opt.undofile = true -- Preserve undo history between sessions
opt.cmdheight = 0 -- Give the floating command line the full editor height

vim.o.cursorline = true
vim.o.cursorlineopt = "both"

-- Mark screen column 100 only on the current line, once it reaches that width.
-- A virtual-column pattern keeps the marker aligned with tabs and wide characters.
local column_limit = 100
local column_group = vim.api.nvim_create_augroup("CurrentLineColorColumn", { clear = true })

local function clear_current_line_column()
  local match_id = vim.w.current_line_column_match
  if match_id then
    pcall(vim.fn.matchdelete, match_id)
    vim.w.current_line_column_match = nil
  end
end

local function update_current_line_column()
  clear_current_line_column()

  if vim.fn.strdisplaywidth(vim.api.nvim_get_current_line()) < column_limit then
    return
  end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  local pattern = string.format([[\%%%dl\%%<%dv.\%%>%dv]], line, column_limit + 1, column_limit)
  vim.w.current_line_column_match = vim.fn.matchadd("ColorColumn", pattern)
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI", "BufEnter", "WinEnter" }, {
  group = column_group,
  callback = update_current_line_column,
})

vim.api.nvim_create_autocmd("WinLeave", {
  group = column_group,
  callback = clear_current_line_column,
})
