return {
  "nvim-telescope/telescope.nvim",
  -- tag = "0.1.8",
  branch = "0.1.x",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>p", builtin.find_files, {})
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
  end,
}
