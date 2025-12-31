--- @file toggleterm.lua
--- @brief Configuration for persistent terminal management.
--- @details Configures akinsho/toggleterm.nvim to provide a floating terminal
---          window that persists processes (like builds/servers) in the background.
--- @author ngxxfus
--- @date 2025-12-09

return {
  {
    --- @brief The toggleterm plugin repository.
    "akinsho/toggleterm.nvim",
    
    --- @brief Use the latest version.
    version = "*",

    --- @brief Configuration function.
    config = function()
      require("toggleterm").setup({
        --- @brief The keybinding to toggle the terminal.
        --- @details Use Ctrl + \ (Backslash) to open/close.
        open_mapping = [[<c-\>]],

        --- @brief Appearance of the terminal window.
        --- @details 'float' creates a popup window in the center. 
        direction = 'float',

        --- @brief Floating window specific options.
        float_opts = {
          --- @brief Border style: 'single', 'double', 'shadow', 'curved'.
          border = 'curved',
          
          --- @brief Window transparency (0 = Opaque/Solid, 100 = Invisible).
          --- @details Set to 0 to prevent text overlapping from buffers below.
          winblend = 0, 
        },

        --- @brief Close the terminal window when the process exits.
        close_on_exit = true,

        --- @brief Shell to use (defaults to system default).
        shell = vim.o.shell,

        --- @brief Auto-scroll to bottom on new output.
        auto_scroll = true,
      })
      
      --- @section Lazygit Integration
      --- @brief Create a custom terminal for Lazygit.
      local Terminal = require('toggleterm.terminal').Terminal
      local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

      --- @brief Function to toggle Lazygit.
      function _lazygit_toggle()
        lazygit:toggle()
      end

      --- @brief Map <leader>gg to open Lazygit floating window.
      --- @details (Uncommented for immediate use)
      --- vim.api.nvim_set_keymap("n", "<leader>gg", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true})
    end,
  },
}
