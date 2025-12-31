--- @file treesitter.lua
--- @brief Configuration for Nvim Treesitter.
--- @details Provides advanced syntax highlighting and code parsing based on the tree-sitter library.
---          Essential for accurate highlighting in C, C++, and Python.
--- @author ngxxfus
--- @date 2025-11-30

return {
  {
    --- @brief The main Treesitter plugin repository.
    "nvim-treesitter/nvim-treesitter",

    --- @brief Update parsers when the plugin is updated.
    build = ":TSUpdate",

    --- @brief Main configuration function.
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        --- @brief List of parsers to install.
        --- @details Includes languages relevant to embedded and automotive development.
        ---          (Removed web languages: javascript, html, elixir, typescript)
        ensure_installed = {
          "c",            -- Core language for embedded systems
          "cpp",          -- C++ support (Added)
          "python",       -- Scripting and automation
          "lua",          -- Neovim config
          "vim",          -- Vimscript legacy support
          "vimdoc",       -- Help documentation
          "query",        -- Treesitter queries
          "bash",         -- Shell scripting
          "markdown",     -- Documentation
          "markdown_inline"
        },

        --- @brief Install parsers synchronously.
        --- @details Set to false to avoid blocking the editor startup.
        sync_install = false,

        --- @brief Automatically install missing parsers when entering a buffer.
        auto_install = true,

        --- @brief Configuration for syntax highlighting.
        highlight = {
          --- @brief Enable Treesitter-based highlighting.
          enable = true,

          --- @brief Disable for large files to prevent performance issues.
          additional_vim_regex_highlighting = false,
        },

        --- @brief Configuration for indentation.
        indent = {
          --- @brief Enable experimental indentation module.
          enable = true,
        },
      })
    end,
  },
}