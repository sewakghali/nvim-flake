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
}
