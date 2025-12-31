--- @file lualine.lua
--- @brief Status line UI plugin configuration.
--- @details Configures lualine with a custom signature "ngxx.fus".
--- @author ngxxfus
--- @date 2025-12-09

return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          globalstatus = true,
          icons_enabled = true,
          component_separators = { left = '|', right = '|' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = {
             statusline = { 'dashboard', 'alpha', 'starter' },
          },
        },
        sections = {
          -- SỬA PHẦN NÀY: Thêm chữ ký vào đầu lualine_a
          lualine_a = {
            {
              --- @brief Custom Signature
              function() return "[ngxx.fus]" end, 
              
              --- @brief Add padding for better visuals
              padding = { left = 1, right = 1 },
              
              --- @brief Separator to distinguish from Mode
              separator = { right = "|" }, 
            },
            {
              'mode',
              --- @brief Display mode in short format (N, I, V instead of NORMAL...)
              --- @details Remove this 'fmt' line if you want full text.
              fmt = function(str) return str:sub(1,1) end 
            }
          },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
      })
    end,
  },
}
