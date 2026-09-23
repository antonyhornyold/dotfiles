local git_file_cache = {}

local function git_names(dir, args, include_parents)
  local result = vim.system(vim.list_extend({ "git" }, args), { cwd = dir }):wait()
  local names = {}
  if result.code ~= 0 then
    return names
  end

  for path in vim.gsplit(result.stdout or "", "\0", { plain = true, trimempty = true }) do
    local name = path:gsub("/$", "")
    if include_parents then
      name = name:match("^[^/]+")
    end
    if name and not name:find("/", 1, true) then
      names[name] = true
    end
  end
  return names
end

local function git_files(dir)
  if not git_file_cache[dir] then
    git_file_cache[dir] = {
      ignored = git_names(
        dir,
        { "ls-files", "--ignored", "--others", "--exclude-standard", "--directory", "-z", "--" }
      ),
      tracked = git_names(dir, { "ls-files", "--cached", "-z", "--" }, true),
    }
  end
  return git_file_cache[dir]
end

-- Recheck Git after Oil's manual refresh, for example after editing .gitignore.
local refresh = require("oil.actions").refresh
local original_refresh = refresh.callback
refresh.callback = function(...)
  git_file_cache = {}
  return original_refresh(...)
end

require("oil").setup({
  columns = { "icon" },
  win_options = {
    signcolumn = "yes:2",
  },
  view_options = {
    is_hidden_file = function(name, bufnr)
      local dir = require("oil").get_current_dir(bufnr)
      if not dir then
        return vim.startswith(name, ".")
      end

      local files = git_files(dir)
      return files.ignored[name] or (vim.startswith(name, ".") and not files.tracked[name])
    end,
  },
  keymaps = {
    ["q"] = "actions.close",
  },
  float = {
    max_width = 0.5,
    max_height = 0.5,
    border = {
      { " ", "OilFloatTop" },
      { " ", "OilFloatTop" },
      { " ", "OilFloatTop" },
      " ", " ", " ", " ", " ",
    },
    get_win_title = function()
      return " Oil "
    end,
    win_options = {
      winbar = "%=%<%{v:lua.require('oil').get_current_dir()}%=",
      winhighlight = "FloatTitle:MasonHeader,WinBar:NormalFloat,WinBarNC:NormalFloat",
      number = false,
      relativenumber = false,
    },
    override = function(config)
      local layout = require("oil.layout")
      local width = layout.get_editor_width()
      local height = layout.get_editor_height()

      -- Prefer half the screen, but keep the explorer usable in smaller panes.
      -- Leave room for the solid border and a margin on each side.
      config.width = math.min(math.max(config.width, 44), math.max(1, width - 4))
      config.height = math.min(math.max(config.height, 12), math.max(1, height - 4))
      config.row = math.max(0, math.floor((height - config.height - 2) / 2))
      config.col = math.max(0, math.floor((width - config.width - 2) / 2))
      config.title = " Oil "
      config.title_pos = "center"
      return config
    end,
  },
})

require("oil-git-status").setup({ show_ignored = false })
