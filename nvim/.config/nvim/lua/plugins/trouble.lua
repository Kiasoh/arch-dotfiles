return {
  "folke/trouble.nvim",
  cmd = "TroubleToggle",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("trouble").setup()
  end,
}
