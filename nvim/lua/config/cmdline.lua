-- ui2 reserves a command row for / and ?, even when tiny-cmdline centres them.
-- Release it after each update so the statusline stays on the bottom row.
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      local cmdline = require("vim._core.ui2.cmdline")
      local show = cmdline.cmdline_show

      cmdline.cmdline_show = function(...)
        local result = show(...)
        local kind = vim.fn.getcmdtype()
        if (kind == "/" or kind == "?") and vim.o.cmdheight ~= 0 then
          vim._with({ noautocmd = true, o = { splitkeep = "screen" } }, function()
            vim.o.cmdheight = 0
          end)
        end
        return result
      end
    end)
  end,
})
