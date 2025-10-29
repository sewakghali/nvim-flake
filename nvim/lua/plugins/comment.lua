return {
  "numToStr/Comment.nvim",
  lazy = false,
  config = function()
    local comment = require("Comment")
    comment.setup()

    local api = require("Comment.api")
    local map = vim.keymap.set

    map("n", "<C-_>", api.toggle.linewise.current, { desc = "Toggle comment line" })

    map("x", "<C-_>", function()
      api.toggle.linewise(vim.fn.visualmode())
    end, { desc = "Toggle comment selection" })

    map("i", "<C-_>", function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
      api.toggle.linewise.current()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("a", true, false, true), "n", true)
    end, { desc = "Toggle comment in insert mode" })
  end,
}
