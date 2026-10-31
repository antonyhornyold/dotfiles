-- Run the same launcher from the palette, using the focused program's directory.
rex.action{
  name = "open_project",
  title = "Open Project",
  category = "Projects",
  description = "Create or reopen a project's Neovim/Codex and dev/shell session",
  args = { directory = "string?", name = "string?" },
  run = function(ctx, args)
    local directory = args.directory
    if not directory then
      if not ctx.block_id then error("Pass directory=/absolute/project/path", 0) end
      local process, err = rex.block.call("com.superlogical.terminal", "process", {})
      if not process then error(err, 0) end
      directory = (process.foreground or {}).cwd or (process.child or {}).cwd
      if not directory then
        local pwd, pwd_err = rex.block.call("com.superlogical.terminal", "pwd", {})
        if not pwd then error(pwd_err, 0) end
        directory = pwd.pwd
      end
      if not directory then error("Cannot determine the directory; pass directory explicitly", 0) end
    end
    local config = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
    local command = { config .. "/bin/rex-project", directory, "--no-attach", "--json" }
    if args.name then
      command[#command + 1] = "--name"
      command[#command + 1] = args.name
    end
    local result, err = rex.exec(command, { timeout = 180 })
    if not result then error(err, 0) end
    if not result.ok then error(result.stderr, 0) end
    local project, decode_err = rex.json.decode(result.stdout)
    if not project then error(decode_err, 0) end
    rex.client.queue("session.select", { session_id = project.session_id })
    return project
  end,
}
