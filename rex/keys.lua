-- Ctrl-Space starts a sequence; Escape cancels it.
rex.bind("ctrl+space>\\", "pane.split", { direction = "right" })
rex.bind("ctrl+space>-", "pane.split", { direction = "down" })

local directions = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(directions) do
  rex.bind("ctrl+space>" .. key, "pane.focus", { direction = direction })
end

rex.bind("ctrl+space>e", "pane.balance")
rex.bind("ctrl+space>z", "pane.zoom")
rex.bind("ctrl+space>x", "pane.close")
rex.bind("ctrl+space>c", "client.tab.new")
rex.bind("ctrl+space>n", "client.tab.next")
rex.bind("ctrl+space>p", "client.tab.previous")
rex.bind("ctrl+space>s", "session.switch")

-- The prefix is consumed by Rex. Press it twice to send it to the terminal.
rex.bind("ctrl+space>ctrl+space", "pane.send_key", { key = "ctrl+space" })

-- Stay in resize mode until Enter or Escape; other keys cannot type into a pane.
rex.mode("resize", { exclusive = true })
rex.bind("ctrl+space>r", "client.mode.enter", { name = "resize" })
for key, direction in pairs(directions) do
  rex.bind("resize/" .. key, "pane.resize", { direction = direction })
  rex.bind("resize/shift+" .. key, "pane.resize", {
    direction = direction,
    amount = 15,
  })
end
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/escape", "client.mode.exit")
