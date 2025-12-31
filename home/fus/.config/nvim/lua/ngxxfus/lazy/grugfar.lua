--- @file grug-far.lua
--- @brief Search and Replace plugin configuration.
--- @details Always opens in Vertical Split (vsplit) mode for consistency.
--- @author ngxxfus
--- @date 2025-12-20

return {
    {
        "MagicDuck/grug-far.nvim",
        config = function()
            require("grug-far").setup({
                -- 1. Default configuration: Always split vertically
                windowCreationCommand = 'vsplit',
                
                -- (Optional) To open on the Right or Left, use:
                -- windowCreationCommand = 'botright vsplit',
            })

            -- === HELPER FUNCTION TO GET SELECTED TEXT ===
            local function get_visual_selection()
                vim.cmd('noau normal! "vy"')
                local text = vim.fn.getreg('v')
                vim.fn.setreg('v', {})
                text = string.gsub(text, "\n", "")
                if #text > 0 then return text else return '' end
            end

            -- === 1. NORMAL MODE (Space + S) ===
            -- Search word under cursor -> Open Vertical Split
            vim.keymap.set('n', '<leader>S', function()
                require('grug-far').open({
                    prefills = { search = vim.fn.expand("<cword>") },
                    windowCreationCommand = 'vsplit', -- Force vsplit
                })
            end, { desc = "GrugFar: Search Word Under Cursor" })
            
            -- === 2. VISUAL MODE (Space + r) ===
            -- Select text then press Space + r -> Open Vertical Split
            vim.keymap.set('v', '<leader>r', function()
                require('grug-far').open({
                    prefills = { search = get_visual_selection() },
                    windowCreationCommand = 'vsplit', -- Force vsplit
                })
            end, { desc = "GrugFar: Search Selected Text" })

            -- === 3. EMPTY SEARCH WINDOW (Space + s + f) ===
            -- Open empty search window -> Open Vertical Split
            vim.keymap.set('n', '<leader>sf', function()
                require('grug-far').open({
                    windowCreationCommand = 'vsplit', -- Force vsplit
                })
            end, { desc = "GrugFar: Open Search Window" })

        end
    },
}
