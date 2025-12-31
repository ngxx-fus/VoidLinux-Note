--- @file comment.lua
--- @brief Comment toggling plugin configuration
--- @details Configures the numToStr/Comment.nvim plugin for quickly
---          commenting/uncommenting code in various languages.
--- @author ngxxfus
--- @date 2025-11-30
--- @see https://github.com/numToStr/Comment.nvim

return {
  {
    --- @brief numToStr/Comment.nvim - Smart comment toggling
    "numToStr/Comment.nvim",

    --- @section Configuration
    --- @brief Setup function for comment plugin
    config = function()
      --- @brief Load and setup Comment with default options
      require("Comment").setup()
    end,

    --- @brief Disable lazy loading to ensure comment functionality works immediately
    lazy = false,
  },
}