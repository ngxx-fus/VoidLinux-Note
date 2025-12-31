--- @file illuminate.lua
--- @brief Configuration for RRethy/vim-illuminate plugin.
--- @details Automatically highlights other uses of the word under the cursor.
--- @author ngxxfus
--- @date 2025-12-09

return {
  {
    --- @brief The illuminate plugin repository.
    "RRethy/vim-illuminate",

    --- @brief Load plugin when a buffer is read or a new file is created.
    event = { "BufReadPost", "BufNewFile" },

    --- @section Keymaps
    --- @brief Define keys to jump between references
    keys = {
      { "<A-n>", function() require("illuminate").goto_next_reference(false) end, desc = "Next Reference" },
      { "<A-p>", function() require("illuminate").goto_prev_reference(false) end, desc = "Prev Reference" },
    },
    
    --- @brief Configuration function.
    config = function()
      require('illuminate').configure({
        --- @brief Providers used to get references in the buffer.
        providers = {
            'regex',
            'lsp',
            'treesitter',
        },

        --- @brief Delay in milliseconds before highlighting.
        delay = 100,

        --- @brief Filetype specific overrides.
        filetype_overrides = {},

        --- @brief Filetypes to ignore (denylist).
        filetypes_denylist = {
          'dirbuf',
          'dirvish',
          'fugitive',
          'NvimTree', -- Added NvimTree as it is common to ignore
          'TelescopePrompt',
        },

        --- @brief Filetypes to allow (allowlist).
        filetypes_allowlist = {},

        --- @brief Modes to ignore.
        modes_denylist = {},

        --- @brief Modes to allow.
        modes_allowlist = {},

        --- @brief Syntax to not illuminate (for regex provider).
        providers_regex_syntax_denylist = {},

        --- @brief Syntax to illuminate (for regex provider).
        providers_regex_syntax_allowlist = {},

        --- @brief Highlight the word under the cursor as well.
        under_cursor = true,

        --- @brief Disable highlighting for large files to save performance.
        large_file_cutoff = 10000,
        large_file_overrides = nil,

        --- @brief Minimum matches required to highlight.
        min_count_to_highlight = 1,

        --- @brief Callback to enable/disable illumination.
        should_enable = function(bufnr) return true end,

        --- @brief Regex case sensitivity.
        case_insensitive_regex = false,
        
        --- @brief Disable default keymaps to avoid conflicts.
        disable_keymaps = false,
      })

      -- local function custom_illuminate_colors()
      --     vim.api.nvim_set_hl(0, "IlluminatedWordText", { underline = false, bold = true, italic = true, bg = "NONE"})
      --     vim.api.nvim_set_hl(0, "IlluminatedWordRead", { underline = false, bold = true, italic = true, bg = "NONE" })
      --     vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { underline = false, bold = true, italic = true, bg = "NONE" })
      -- end
      --
      -- custom_illuminate_colors()
      --
      -- vim.api.nvim_create_autocmd("ColorScheme", {
      --   pattern = "*",
      --   callback = custom_illuminate_colors,
      -- })

    end,
  },
}
