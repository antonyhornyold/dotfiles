local starter = require("mini.starter")
local fzf = require("fzf-lua")
local recent_files = starter.sections.recent_files(5, false, false)

local function recent_items()
  local items = recent_files()
  if #items == 1 and items[1].action == "" then
    items[1].name = "No recent files"
  end
  return items
end

local function line_width(line)
  return vim.fn.strdisplaywidth(vim.iter(line):map(function(unit)
    return unit.string
  end):join(""))
end

local function add_border(content)
  local footer = {}
  for index, line in ipairs(content) do
    if line[1] and line[1].type == "footer" then
      footer = vim.list_slice(content, index)
      content = vim.list_slice(content, 1, index - 2)
      break
    end
  end

  local width = 38
  for _, line in ipairs(content) do
    width = math.max(width, line_width(line) + 4)
  end

  local border = function(text)
    return { string = text, type = "empty", hl = "MiniStarterBorder" }
  end

  for _, line in ipairs(content) do
    local text_width = line_width(line)
    local padding = width - text_width - 4
    local left = 2
    if line[1] and line[1].type == "header" then
      left = left + math.floor(padding / 2)
    end

    table.insert(line, 1, border("│" .. string.rep(" ", left)))
    table.insert(line, border(string.rep(" ", width - text_width - left - 2) .. "│"))
  end

  table.insert(content, 1, { border("╭" .. string.rep("─", width - 2) .. "╮") })
  table.insert(content, { border("╰" .. string.rep("─", width - 2) .. "╯") })
  table.insert(content, { { string = "", type = "empty" } })
  vim.list_extend(content, footer)
  return content
end

local function center_lines(content)
  local width = 0
  for _, line in ipairs(content) do
    width = math.max(width, line_width(line))
  end
  for _, line in ipairs(content) do
    table.insert(line, 1, { string = string.rep(" ", math.floor((width - line_width(line)) / 2)), type = "empty" })
  end
  return content
end

starter.setup({
  header = "Neovim",
  items = {
    { name = "Find file", action = fzf.files, section = "Open" },
    { name = "Search text", action = fzf.live_grep, section = "Open" },
    { name = "Browse files", action = "Oil --float", section = "Open" },
    { name = "New buffer", action = "enew", section = "Open" },
    { name = "Edit Neovim config", action = function()
      vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
    end, section = "Open" },
    { name = "Quit", action = "qall", section = "Open" },
    recent_items,
  },
  content_hooks = {
    starter.gen_hook.adding_bullet("  "),
    add_border,
    center_lines,
    starter.gen_hook.aligning("center", "center"),
  },
})
