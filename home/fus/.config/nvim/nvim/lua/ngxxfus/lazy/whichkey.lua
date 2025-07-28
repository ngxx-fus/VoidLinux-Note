return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy", -- hoặc "VimEnter" nếu muốn load sớm
    config = function()
      require("which-key").setup()
    end,
  },
}
