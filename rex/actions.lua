local terminal = "com.superlogical.terminal"

local function execute(command, options)
  local result, err = rex.exec(command, options)
  if not result then error(err, 0) end
  if not result.ok then
    error(result.stderr ~= "" and result.stderr or result.stdout, 0)
  end
  return result.stdout
end

local function local_path(path)
  -- Canonicalize paths and OSC 7 file URLs without treating either as shell code.
  return execute({ "python3", "-c", [[
import pathlib, sys, urllib.parse
value = sys.argv[1]
if value.startswith('file:'):
    uri = urllib.parse.urlparse(value)
    if uri.scheme != 'file' or uri.netloc not in ('', 'localhost'):
        sys.exit('Only local file URLs are supported')
    value = urllib.parse.unquote(uri.path)
path = pathlib.Path(value).expanduser().resolve(strict=True)
if not path.is_dir():
    sys.exit('The project path must be a directory')
print(path, end='')
]], path })
end

local function state_home()
  local state = os.getenv("XDG_STATE_HOME")
  if not state or state == "" then state = os.getenv("HOME") .. "/.local/state" end
  return state
end

local function registered_directory(ctx)
  if not ctx.session_id then return nil end
  local status, err = rex.call("server.status", {})
  if not status then error(err, 0) end
  local hash = execute({ "shasum", "-a", "256" }, { stdin = status.host_id }):match("^(%x+)")
  if not hash then return nil end
  local file = io.open(state_home() .. "/rex/projects/" .. hash:sub(1, 16) .. ".json", "r")
  if not file then return nil end
  local contents = file:read("*a")
  file:close()
  local records = rex.json.decode(contents)
  if type(records) ~= "table" then return nil end
  for root, record in pairs(records) do
    if type(record) == "table" and record.session_id == ctx.session_id then return root end
  end
end

local function project(ctx, args)
  local directory = args.directory
  if not directory then
    if not ctx.block_id then error("Pass directory=/absolute/project/path", 0) end
    local process, err = rex.block.call(terminal, "process", {})
    if not process then error(err, 0) end
    directory = (process.foreground or {}).cwd or (process.child or {}).cwd
    if not directory then
      local pwd, pwd_err = rex.block.call(terminal, "pwd", {})
      if not pwd then error(pwd_err, 0) end
      directory = pwd.pwd
    end
    if not directory then directory = registered_directory(ctx) end
    if not directory then error("Cannot determine the directory; pass directory explicitly", 0) end
  end
  directory = local_path(directory)
  local result, err = rex.exec({ "git", "-C", directory, "rev-parse", "--show-toplevel" })
  if not result then error(err, 0) end
  if result.ok then return local_path((result.stdout:gsub("\n$", ""))), true end
  return directory, false
end

local function require_program(program, directory)
  local result, err = rex.exec({ "/bin/zsh", "-lic", 'command -v -- "$1" >/dev/null', "rex-action", program }, {
    cwd = directory,
    timeout = 30,
  })
  if not result or not result.ok then
    error(program .. " is unavailable in the interactive Zsh environment: " .. (err or result.stderr), 0)
  end
end

local function open_tab(ctx, title, label, directory, command, report_exit)
  if not ctx.session_id then error("Run this action in a Rex session (or pass -s SESSION)", 0) end
  local shell_code = 'exec "$@"'
  if report_exit then
    shell_code = '"$@"; rex_test_exit=$?; '
      .. 'printf "\\nTests finished with exit status %s\\n" "$rex_test_exit"; exit "$rex_test_exit"'
  end
  -- Report startup cwd even when this beta exposes only login-wrapper metadata.
  local report_directory = [[python3 -c 'import pathlib,sys; ]]
    .. [[sys.stdout.write("\033]7;" + pathlib.Path.cwd().as_uri() + "\007")'; ]]
  local window, err = rex.session.new_window{
    window_label = title,
    layout = {
      block = {
        flavor = "com.superlogical.terminal.shell",
        label = label,
        options = {
          cwd = directory,
          shell = "none",
          command = { "/bin/zsh", "-lic", report_directory .. shell_code, "rex-action", unpack(command) },
          exit = { on_completion = false },
        },
      },
    },
  }
  if not window then error(err, 0) end
  return window
end

rex.action{
  name = "open_lazygit",
  title = "Open Lazygit",
  category = "Development",
  description = "Open Lazygit in a new tab at the focused project's Git root",
  args = { directory = "string?" },
  run = function(ctx, args)
    local directory, is_git = project(ctx, args)
    if not is_git then error("Lazygit needs a Git repository", 0) end
    require_program("lazygit", directory)
    return open_tab(ctx, "git", "lazygit", directory, { "lazygit" })
  end,
}

rex.action{
  name = "run_tests",
  title = "Run Project Tests",
  category = "Development",
  description = "Run an npm test script in a new tab and retain the output after exit",
  args = { directory = "string?", script = "string?" },
  run = function(ctx, args)
    local directory = project(ctx, args)
    local file, err = io.open(directory .. "/package.json", "r")
    if not file then error("No readable package.json: " .. tostring(err), 0) end
    local contents = file:read("*a")
    file:close()
    local package, decode_err = rex.json.decode(contents)
    if not package then error("Invalid package.json: " .. tostring(decode_err), 0) end
    local script = args.script or "test"
    local scripts = type(package) == "table" and package.scripts
    if type(scripts) ~= "table" or type(scripts[script]) ~= "string" or not scripts[script]:match("%S") then
      error("No npm script named " .. script .. " in package.json", 0)
    end
    require_program("npm", directory)
    -- -- terminates npm's option parsing, even for an unusual script name.
    return open_tab(ctx, "tests", "tests", directory, { "npm", "run", "--", script }, true)
  end,
}

rex.action{
  name = "open_project_logs",
  title = "Open Project Logs",
  category = "Development",
  description = "Follow the full project-dev log; Ctrl-C stops following so you can scroll",
  args = { directory = "string?" },
  run = function(ctx, args)
    local directory = project(ctx, args)
    local hash = execute({ "shasum", "-a", "256" }, { stdin = directory }):match("^(%x+)")
    if not hash then error("Could not calculate the project log filename", 0) end
    local state = state_home()
    local name = directory:match("([^/]+)$") or "/"
    local log = state .. "/herdr/logs/" .. name .. "-" .. hash:sub(1, 8) .. ".log"
    local file = io.open(log, "r")
    if not file then error("No project-dev log yet: " .. log .. ". Start project-dev first", 0) end
    file:close()
    require_program("less", directory)
    return open_tab(ctx, "logs", "logs", directory, { "less", "-R", "+F", "--", log })
  end,
}

rex.action{
  name = "edit_rex_config",
  title = "Edit Rex Config",
  category = "Development",
  description = "Open the Rex entry point in Neovim",
  run = function(ctx)
    local config = os.getenv("REX_CONFIG")
    if not config or config == "" then
      local base = os.getenv("XDG_CONFIG_HOME")
      if not base or base == "" then base = os.getenv("HOME") .. "/.config" end
      config = base .. "/rex/init.lua"
    end
    local directory = local_path(config:match("^(.*)/[^/]+$") or ".")
    config = directory .. "/" .. (config:match("([^/]+)$") or "init.lua")
    require_program("nvim", directory)
    return open_tab(ctx, "rex config", "rex-config", directory, { "nvim", config })
  end,
}
