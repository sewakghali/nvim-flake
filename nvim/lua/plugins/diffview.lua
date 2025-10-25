return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggle" }, 
  keys = {
    {
      "<leader>dv", 
      function()
        -- Toggles the Diffview window. If no view is open, it calls DiffviewOpen.
        if next(require("diffview.lib").views) == nil then
          vim.cmd("DiffviewOpen")
        else
          vim.cmd("DiffviewClose")
        end
      end,
      desc = "Toggle Diffview window",
    },
  },
  -- Optional: Add configuration options here if needed,
  -- but the default is usually fine for basic usage.
  -- config = function()
  --   require("diffview").setup {}
  -- end,
}
