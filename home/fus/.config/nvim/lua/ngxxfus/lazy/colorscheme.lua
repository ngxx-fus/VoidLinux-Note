--- @file colorscheme.lua
--- @brief Unified Colorscheme configuration (Light/Dark mode switcher).
--- @author ngxxfus
--- @date 2025-12-31

-- =========================================================
-- ⚙️ CONFIGURATION TOGGLE
-- =========================================================
-- 0: Light Theme (Light background, suitable for CodeNewRoman, Black cursor)
-- 1: Dark Theme  (Dark background, eye-friendly, White cursor)
local DARK_THEME_EN = 0
-- =========================================================

return {
    {
        "Mofiqul/vscode.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            
            -- =========================================================
            -- DARK THEME CONFIGURATION (IF DARK_THEME_EN = 1)
            -- =========================================================
            if DARK_THEME_EN == 1 then
                -- 1. Setup Dark Background
                vim.o.background = 'dark'
                
                require('vscode').setup({
                    style = 'dark', -- 'dark' or 'light'
                    transparent = false,
                    italic_comments = true,
                    disable_nvimtree_bg = true,
                    terminal_colors = true,
                })
                
                vim.cmd.colorscheme("vscode")

                -- 2. Dark Theme Overrides
                -- [A] Comment Colors (Dark mode needs lighter comments usually, or keep green)
                -- Adjust comment color to stand out on black background
                local comment_groups = {
                    "Comment", "SpecialComment", 
                    "@comment", "@comment.documentation", "@lsp.type.comment",
                }
                for _, group in ipairs(comment_groups) do
                    -- Keep green but potentially brighter if needed. Currently keeping it same as Light.
                    vim.api.nvim_set_hl(0, group, { fg = "#41B06E", italic = false, bold = false })
                end

                -- [B] Cursor Colors (Dark Mode)
                -- Normal: Reverse (Invert color)
                vim.api.nvim_set_hl(0, "Cursor", { reverse = true })
                
                -- Insert: WHITE (#FFFFFF) - Cursor must be white to be visible on dark background
                vim.api.nvim_set_hl(0, "CursorInsert", { bg = "#FFFFFF", fg = "#000000" })


            -- =========================================================
            -- LIGHT THEME CONFIGURATION (IF DARK_THEME_EN = 0)
            -- =========================================================
            else 
                -- 1. Setup Light Background
                vim.o.background = 'light'
                
                require('vscode').setup({
                    style = 'light',
                    transparent = false,
                    italic_comments = true,
                    disable_nvimtree_bg = true,
                    terminal_colors = true,
                })

                vim.cmd.colorscheme("vscode")

                -- 2. Light Theme Overrides
                -- [A] Comment Colors (Green)
                local comment_groups = {
                    "Comment", "SpecialComment", 
                    "@comment", "@comment.documentation", "@lsp.type.comment",
                }
                for _, group in ipairs(comment_groups) do
                    vim.api.nvim_set_hl(0, group, { fg = "#6A9955", italic = false, bold = false })
                end

                -- [B] Cursor Colors (Light Mode)
                -- Normal: Reverse (Invert color)
                vim.api.nvim_set_hl(0, "Cursor", { reverse = true })
                
                -- Insert: BLACK (#000000) - Cursor must be black to be visible on light background
                vim.api.nvim_set_hl(0, "CursorInsert", { bg = "#000000", fg = "#ffffff" })
            end

            -- =========================================================
            -- APPLY CURSOR SHAPE (SHARED LOGIC)
            -- =========================================================
            -- Logic applies to both themes since Cursor/CursorInsert colors are defined above
            -- n-v-c (Normal/Visual): block shape + Cursor color (Inverse)
            -- i-ci-ve (Insert): ver50 (thick vertical bar) + CursorInsert color (Black or White)
            vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver50-CursorInsert"

        end,
    },
}
