--- @file which_key.lua
--- @brief Configuration for the which-key.nvim plugin.
--- @details Displays available keybindings in a popup menu to help remember mappings.
--- @author ngxxfus
--- @date 2025-11-30

return {
  {
    --- @brief Plugin repository on GitHub.
    "folke/which-key.nvim",

    --- @brief Trigger event for lazy loading.
    --- @details Uses "VeryLazy" to load after startup. Use "VimEnter" if you want to load it earlier.
    event = "VeryLazy",

    --- @brief Initialization function.
    --- @details Calls the setup function with default options.
    config = function()
      require("which-key").setup()
    end,
  },
}