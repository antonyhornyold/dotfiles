-- Import through the client action so the beta's file-picker filter is avoided.
rex.action{
  name = "apply_mocha",
  title = "Apply Catppuccin Mocha",
  category = "Appearance",
  description = "Import and select the saved Catppuccin Mocha terminal colors",
  run = function()
    local config = os.getenv("XDG_CONFIG_HOME")
    if not config or config == "" then config = os.getenv("HOME") .. "/.config" end
    rex.client.queue("client.theme.import", {
      path = config .. "/rex/themes/Catppuccin Mocha.itermcolors",
    })
  end,
}
