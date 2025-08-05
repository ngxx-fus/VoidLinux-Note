return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- load before opening files
    opts = {
      options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" },
    },
  },
}

