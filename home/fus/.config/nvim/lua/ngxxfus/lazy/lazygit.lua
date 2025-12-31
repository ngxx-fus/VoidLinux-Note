--- @file lazygit.lua
--- @brief Git GUI integration for Neovim.
--- @details Configures kdheepak/lazygit.nvim to manage git repositories inside Neovim.
--- @author ngxxfus
--- @date 2025-12-09

return {
  {
    --- @brief The main Lazygit plugin.
    "kdheepak/lazygit.nvim",
    
    --- @brief Load dependencies.
    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    --- @brief Load only when invoked (Optimizes startup time).
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },

    --- @brief Keymaps to open Lazygit.
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" }
    },

    --- @brief Configuration.
    config = function()
      -- Tùy chỉnh màu sắc nếu cần thiết để khớp với theme
      vim.g.lazygit_floating_window_winblend = 0 -- Độ trong suốt (0 = đặc)
      vim.g.lazygit_floating_window_scaling_factor = 0.9 -- Kích thước cửa sổ (90%)
      vim.g.lazygit_floating_window_border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' } -- Viền cong
    end,
  },
}
