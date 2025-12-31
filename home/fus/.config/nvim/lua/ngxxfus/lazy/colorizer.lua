--- @file colorizer.lua
--- @brief Color highlighting plugin configuration
--- @details Configures NvChad/nvim-colorizer.lua for displaying color codes
---          as actual colors in the editor (CSS, RGB, HSL, etc.)
--- @author ngxxfus
--- @date 2025-11-30
--- @see https://github.com/NvChad/nvim-colorizer.lua

return {
    {
        --- @brief NvChad/nvim-colorizer.lua - Color code highlighting
        "NvChad/nvim-colorizer.lua",

        --- @brief Load on BufReadPre and BufNewFile events to ensure colors appear immediately
        event = { "BufReadPre", "BufNewFile" },

        --- @section Configuration
        --- @brief Setup colorizer with custom options
        config = function()
            --- @brief Load and setup colorizer module
            require("colorizer").setup({
                --- @section Filetype Settings
                --- @brief Configure colorizer behavior per filetype
                filetypes = {
                    --- @brief Enable colorizer for all filetypes by default
                    "*",

                    --- @section Rasi-specific Options
                    --- @brief Special configuration for rasi filetype (rofi theme files)
                    rasi = {
                        --- @brief Enable RGB function color highlighting (e.g., rgb(255, 0, 0))
                        rgb_fn = true,
                        --- @brief Enable HSL function color highlighting
                        hsl_fn = true,
                        --- @brief Enable named color highlighting (e.g., "red", "blue")
                        names = true,
                    },
                },

                --- @section User Default Options
                --- @brief Global configuration for how colors are displayed
                user_default_options = {
                    --- @brief Enable CSS standard colorization
                    css = true,
                    --- @brief Enable rgb() function highlighting globally
                    rgb_fn = true,
                    --- @brief Enable hsl() function highlighting globally
                    hsl_fn = true,
                    --- @brief Disable tailwind class color detection
                    tailwind = false,
                    --- @brief Display mode: "foreground" colorizes the text itself
                    mode = "foreground",
                },
            })

            --- @section Auto-attachment
            --- @brief Force auto-attach colorizer to rasi files on load
            vim.cmd [[autocmd BufReadPost,BufNewFile *.rasi ColorizerAttachToBuffer]]
        end,
    },
}