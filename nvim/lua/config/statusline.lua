local M = {}
local branches = {}

local modes = {
  n = { "NORMAL", "StatusModeNormal" },
  i = { "INSERT", "StatusModeInsert" },
  v = { "VISUAL", "StatusModeVisual" },
  V = { "VISUAL", "StatusModeVisual" },
  ["\22"] = { "VISUAL", "StatusModeVisual" }, -- Ctrl-V
  R = { "REPLACE", "StatusModeReplace" },
  c = { "COMMAND", "StatusModeCommand" },
  t = { "TERMINAL", "StatusModeTerminal" },
}

local mode_color_groups = {
  StatusModeNormal = "DiagnosticInfo",
  StatusModeInsert = "String",
  StatusModeVisual = "DiagnosticHint",
  StatusModeReplace = "DiagnosticError",
  StatusModeCommand = "DiagnosticWarn",
  StatusModeTerminal = "Function",
}

local function filetype_icon(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local filetype = vim.bo[buf].filetype
  local icon = MiniIcons.get("filetype", filetype)
  return icon or ""
end

local function update_branch(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    branches[buf] = nil
    return
  end

  local result = vim.system({ "git", "-C", vim.fs.dirname(name), "symbolic-ref", "--quiet", "--short", "HEAD" }, { text = true }):wait()
  branches[buf] = result.code == 0 and vim.trim(result.stdout):gsub("%%", "%%%%") or nil
end

local function diagnostics(buf, highlight)
  local counts = vim.diagnostic.count(buf)
  local parts = {}
  local errors = counts[vim.diagnostic.severity.ERROR] or 0
  local warnings = counts[vim.diagnostic.severity.WARN] or 0

  if errors > 0 then
    parts[#parts + 1] = "%#" .. highlight .. "DiagnosticError# " .. errors .. "%#" .. highlight .. "#"
  end
  if warnings > 0 then
    parts[#parts + 1] = "%#" .. highlight .. "DiagnosticWarn# " .. warnings .. "%#" .. highlight .. "#"
  end

  return table.concat(parts, "  ")
end

local function set_colors()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local statusline = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
  local inactive = vim.api.nvim_get_hl(0, { name = "StatusLineNC", link = false })
  local error_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticError", link = false })
  local warn_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn", link = false })

  for group, source in pairs(mode_color_groups) do
    local source_hl = vim.api.nvim_get_hl(0, { name = source, link = false })

    local background = source_hl.fg or statusline.fg
    vim.api.nvim_set_hl(0, group, {
      fg = normal.bg or statusline.bg,
      bg = background,
      bold = true,
    })
    vim.api.nvim_set_hl(0, group .. "DiagnosticError", { fg = error_hl.fg, bg = background, bold = true })
    vim.api.nvim_set_hl(0, group .. "DiagnosticWarn", { fg = warn_hl.fg, bg = background, bold = true })
  end

  vim.api.nvim_set_hl(0, "StatusModeInactive", inactive)
end

function M.render()
  local status_win = tonumber(vim.g.statusline_winid)
  local active_win = vim.api.nvim_get_current_win()
  local win = status_win or active_win
  local buf = vim.api.nvim_win_get_buf(win)
  local icon = filetype_icon(win)

  if status_win ~= active_win then
    return "%#StatusModeInactive#  %<%f %m%= " .. icon .. "  %l:%c "
  end

  local mode = vim.api.nvim_get_mode().mode
  local current = modes[mode:sub(1, 1)] or modes.n
  local label, highlight = current[1], current[2]
  local branch = branches[buf]
  local branch_segment = branch and branch ~= "" and "   " .. branch or ""
  local diagnostic_segment = diagnostics(buf, highlight)

  return table.concat({
    "%#", highlight, "# ",
    label,
    "  %<%f %m", branch_segment,
    "%=",
    diagnostic_segment ~= "" and diagnostic_segment .. "  " or " ",
    icon, "  %l:%c ",
  })
end

vim.o.showmode = false
vim.o.laststatus = 2
vim.o.statusline = "%!v:lua.require'config.statusline'.render()"

set_colors()

local group = vim.api.nvim_create_augroup("CustomStatusline", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "FocusGained", "DirChanged" }, {
  group = group,
  callback = function(args)
    update_branch(args.buf)
    vim.cmd.redrawstatus()
  end,
})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = group,
  callback = function()
    vim.cmd.redrawstatus()
  end,
})

update_branch(vim.api.nvim_get_current_buf())

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = set_colors,
})

vim.api.nvim_create_autocmd({ "ModeChanged", "WinEnter", "WinLeave" }, {
  group = group,
  callback = function()
    vim.cmd.redrawstatus()
  end,
})

return M
