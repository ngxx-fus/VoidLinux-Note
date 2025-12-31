--- @file persistence.lua
--- @brief Session management configuration using persistence.nvim
--- @details Automatically saves and restores editor state including buffers, window layouts, and tab pages.
--- @author ngxxfus
--- @date 2025-11-30

return {
  {
    --- @brief Plugin repository identifier
    "folke/persistence.nvim",

    --- @brief Lazy load trigger
    --- @details Loads the plugin immediately before a buffer is read to ensure session capability is ready
    event = "BufReadPre",

    --- @brief Configuration options passed to the setup function
    opts = {
      --- @brief specific session components to save and restore
      options = { 
        "buffers",  -- Save open file buffers
        "curdir",   -- Save the current working directory
        "tabpages", -- Save tab page layouts
        "winsize",  -- Save window dimensions
        "help",     -- Save help window states
        "globals"   -- Save global variables
      },
    },
  },
}
