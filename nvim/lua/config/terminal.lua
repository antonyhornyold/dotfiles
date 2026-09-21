local terminal = { buf = nil, win = nil }

local function open_window(buf)
  local width = math.max(1, math.floor(vim.o.columns * 0.7))
  local height = math.max(1, math.floor(vim.o.lines * 0.7))

  terminal.win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.wo[terminal.win].number = false
  vim.wo[terminal.win].relativenumber = false
  vim.wo[terminal.win].signcolumn = "no"
end

local function close_window()
  if terminal.win and vim.api.nvim_win_is_valid(terminal.win) then
    vim.api.nvim_win_close(terminal.win, false)
  end
  terminal.win = nil
end

function terminal.toggle()
  if terminal.win and vim.api.nvim_win_is_valid(terminal.win) then
    close_window()
    return
  end

  if not terminal.buf or not vim.api.nvim_buf_is_valid(terminal.buf) then
    terminal.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[terminal.buf].bufhidden = "hide"
    vim.keymap.set("t", "<C-q>", close_window, {
      buffer = terminal.buf,
      desc = "Close floating terminal",
    })
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], {
      buffer = terminal.buf,
      desc = "Floating terminal normal mode",
    })

    local buf = terminal.buf
    vim.api.nvim_create_autocmd("TermClose", {
      buffer = buf,
      once = true,
      callback = function()
        vim.schedule(function()
          if terminal.buf ~= buf then
            return
          end
          close_window()
          if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
          terminal.buf = nil
        end)
      end,
    })
    open_window(buf)
    vim.fn.termopen(vim.o.shell)
  else
    open_window(terminal.buf)
  end

  vim.cmd.startinsert()
end

vim.keymap.set("n", "<leader>t", terminal.toggle, { desc = "Toggle floating terminal" })

return terminal
