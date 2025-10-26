return {
  "nvim-telescope/telescope.nvim",
  -- tag = "0.1.8",
  branch = "0.1.x",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>p", builtin.find_files, {})
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
    vim.keymap.set("n", "<leader>gs", builtin.git_status, {})
    vim.keymap.set("n", "<leader>gc", builtin.git_commits, {})
    vim.keymap.set("n", "<leader>gb", builtin.git_branches, {})
    vim.keymap.set("n", "<leader>gst", builtin.git_stash, {})
  end,
}
