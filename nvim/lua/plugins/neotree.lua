return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false,                 -- neo-tree will lazily load itself
    config = function()
      vim.keymap.set("n", "<C-b>", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
      require("neo-tree").setup({
        -- close_if_last_window = true,
        -- enable_git_status = false,
      })
    end,
  },
}
