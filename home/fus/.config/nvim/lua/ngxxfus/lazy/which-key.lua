--- @file which-key.lua
--- @brief Keybinding helper popup configuration
--- @details Configures which-key to show a popup with possible keybindings after a delay.
--- @author ngxxfus
--- @date 2025-12-06
--- @see https://github.com/folke/which-key.nvim

return {
  "folke/which-key.nvim",
  event = "VeryLazy", -- Load on a lazy event
  config = function()
    -- Set a shorter timeout for the keymap popup to appear faster
    vim.o.timeout = true
    vim.o.timeoutlen = 300

    local which_key = require("which-key")
    which_key.setup({
      plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        spelling = {
          enabled = true, -- show suggestions for z=
          suggestions = 20,
        },
      },
      -- Change the window appearance
      window = {
        border = "rounded", -- none, single, double, rounded, solid, shadow
        position = "bottom",
        margin = { 1, 0, 1, 0 }, -- top, right, bottom, left
        padding = { 1, 2, 1, 2 }, -- top, right, bottom, left
      },
    })
  end,
}