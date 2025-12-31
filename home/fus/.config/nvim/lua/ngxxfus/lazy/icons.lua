--- @file icons.lua
--- @brief Icon and symbol provider plugin configuration.
--- @details Loads icon and symbol provider plugins:
---          - nvim-tree/nvim-web-devicons: File type icons.
---          - echasnovski/mini.nvim: Minimal UI enhancements.
--- @author ngxxfus
--- @date 2025-11-30
--- @see https://github.com/nvim-tree/nvim-web-devicons
--- @see https://github.com/echasnovski/mini.nvim

return {
  {
    --- @brief Plugin for file type icons.
    --- @details Provides icons used by other plugins (e.g., status lines, file explorers).
    "nvim-tree/nvim-web-devicons",

    --- @brief Enable lazy loading.
    --- @details This plugin is not loaded immediately; it waits until required by another plugin.
    lazy = true
  },
  {
    --- @brief A library of minimal, independent Lua modules for Neovim.
    --- @details Used here primarily for its icon handling capabilities or UI utilities.
    "echasnovski/mini.nvim",

    --- @brief Use the main branch instead of stable releases.
    --- @details Setting version to false fetches the latest development version.
    version = false
  },
}