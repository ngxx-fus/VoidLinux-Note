--- @file bufferline.lua
--- @brief Buffer line UI plugin configuration.
--- @details Configures the akinsho/bufferline.nvim plugin with explicit high-contrast colors for VSCode Light theme.
--- @author ngxxfus
--- @date 2025-12-20

return {
    {
        --- @brief akinsho/bufferline.nvim plugin.
        "akinsho/bufferline.nvim",
        
        --- @brief Version constraint (latest).
        version = "*", 
        
        --- @brief Required dependencies for bufferline.
        dependencies = { "nvim-tree/nvim-web-devicons" },
        
        --- @brief Load event - VeryLazy.
        event = {"VimEnter", "VeryLazy", "BufReadPre", "BufNewFile"}, 
        
        --- @brief Setup function for bufferline.
        config = function()
            require("bufferline").setup({
                --- @section Display Options
                options = {
                    mode = "buffers",
                    diagnostics = "nvim_lsp",
                    separator_style = "thin",
                    show_buffer_close_icons = true,
                    show_close_icon = true,
                    color_icons = true,

                    close_command = function(n) require("mini.bufremove").delete(n, false) end,
                    right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
                },

                --- @section Custom Highlights
                --- @details Explicitly set HEX colors to ensure high contrast on Light Theme.
                highlights = {
                    -- === 1. BASE COLORS ===
                    fill = { fg = "#606060", bg = "#E5E5E5" },
                    background = { fg = "#606060", bg = "#E5E5E5" },
                    
                    buffer_visible = { fg = "#606060", bg = "#E5E5E5" },
                    buffer_selected = { fg = "#000000", bg = "#FFFFFF", bold = true, italic = false },
                    
                    separator = { fg = "#E5E5E5", bg = "#E5E5E5" },
                    separator_selected = { fg = "#E5E5E5", bg = "#FFFFFF" },
                    
                    -- Modified Icon (Dot/Circle)
                    modified = { fg = "#D00000", bg = "#E5E5E5" },
                    modified_selected = { fg = "#D00000", bg = "#FFFFFF" },
                    
                    duplicate = { fg = "#606060", bg = "#E5E5E5", italic = true },
                    duplicate_selected = { fg = "#000000", bg = "#FFFFFF", italic = true },

                    close_button = { fg = "#606060", bg = "#E5E5E5" },
                    close_button_visible = { fg = "#606060", bg = "#E5E5E5" },
                    close_button_selected = { fg = "#000000", bg = "#FFFFFF" },

                    -- === 3. DIAGNOSTIC COLORS (Error/Warning) ===
                    -- Error (Red)
                    error = { fg = "#D00000", bg = "#E5E5E5" },
                    error_visible = { fg = "#D00000", bg = "#E5E5E5" },
                    error_selected = { fg = "#D00000", bg = "#FFFFFF", bold = true },
                    
                    error_diagnostic = { fg = "#D00000", bg = "#E5E5E5" },
                    error_diagnostic_visible = { fg = "#D00000", bg = "#E5E5E5" },
                    error_diagnostic_selected = { fg = "#D00000", bg = "#FFFFFF", bold = true },

                    -- Warning (Orange)
                    warning = { fg = "#A66F00", bg = "#E5E5E5" },
                    warning_visible = { fg = "#A66F00", bg = "#E5E5E5" },
                    warning_selected = { fg = "#A66F00", bg = "#FFFFFF", bold = true },
                    
                    warning_diagnostic = { fg = "#A66F00", bg = "#E5E5E5" },
                    warning_diagnostic_visible = { fg = "#A66F00", bg = "#E5E5E5" },
                    warning_diagnostic_selected = { fg = "#A66F00", bg = "#FFFFFF", bold = true },

                    -- Info & Hint (Blue)
                    info = { fg = "#264F78", bg = "#E5E5E5" },
                    info_visible = { fg = "#264F78", bg = "#E5E5E5" },
                    info_selected = { fg = "#264F78", bg = "#FFFFFF", bold = true },
                    
                    info_diagnostic = { fg = "#264F78", bg = "#E5E5E5" },
                    info_diagnostic_visible = { fg = "#264F78", bg = "#E5E5E5" },
                    info_diagnostic_selected = { fg = "#264F78", bg = "#FFFFFF", bold = true },
                    
                    hint = { fg = "#264F78", bg = "#E5E5E5" },
                    hint_visible = { fg = "#264F78", bg = "#E5E5E5" },
                    hint_selected = { fg = "#264F78", bg = "#FFFFFF", bold = true },
                    
                    hint_diagnostic = { fg = "#264F78", bg = "#E5E5E5" },
                    hint_diagnostic_visible = { fg = "#264F78", bg = "#E5E5E5" },
                    hint_diagnostic_selected = { fg = "#264F78", bg = "#FFFFFF", bold = true },
                },
            })
        end,
    },
}
