--- @file trouble.lua
--- @brief Trouble.nvim configuration.
--- @details A pretty diagnostic list to replace the native quickfix window.
--- @author ngxxfus
--- @date 2025-12-19

return {
  {
    "folke/trouble.nvim",
    --- @brief Requires icons for better UI
    dependencies = { "nvim-tree/nvim-web-devicons" },
    
    --- @brief Lazy load on command or keypress
    cmd = "Trouble",
    
    --- @brief Default options (will be passed to config function)
    opts = {
        focus = true, -- Auto focus the window when opened
    },

    --- @brief Custom configuration to apply highlights
    --- @param _ Ignored (plugin instance)
    --- @param opts The table defined above
    config = function(_, opts)
      require("trouble").setup(opts)
      
      -- vim.api.nvim_set_hl(0, "TroubleNormal", { bg = "#101010" })
      -- vim.api.nvim_set_hl(0, "TroubleNormalNC", { bg = "#101010" })
    end, 
    
    --- @brief Keymaps definition
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
    },
  },
}
