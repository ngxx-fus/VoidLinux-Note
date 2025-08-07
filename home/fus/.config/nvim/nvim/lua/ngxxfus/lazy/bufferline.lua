return {
  {
    "akinsho/bufferline.nvim",
    version = "*", 
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    event = "VeryLazy", 
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",  
          diagnostics = "nvim_lsp",
          separator_style = "slant",
          show_buffer_close_icons = false,
          show_close_icon = false,
          color_icons = true,
        },
      })
    end,
  },
}

