return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000, -- đảm bảo load sớm hơn các plugin khác
    config = function()
      vim.opt.termguicolors = true -- bật truecolor
      vim.cmd("colorscheme tokyonight")
    end,
  },
}
