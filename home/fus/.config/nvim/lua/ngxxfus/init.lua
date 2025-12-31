--- @file init.lua
--- @brief Core Neovim configuration bootstrap module
--- @details Orchestrates the initialization of all configuration modules including:
---          - Base settings and options
---          - Keybindings
---          - Lazy plugin manager
---          - Individual plugin configurations
--- @author ngxxfus
--- @date 2025-11-30
--- @note Load order is critical: set -> remap -> lazy_init -> plugin configs

--- @brief Set global map leader to Space
--- @details This must be defined before any keymaps or plugins are loaded to ensure
---          mappings using <leader> work correctly.
vim.g.mapleader = " "

--- @section Core Configuration

--- @brief Load base editor settings (options, booleans)
require("ngxxfus.set")

--- @brief Load global keybindings and remappings
require("ngxxfus.remap")

--- @section Plugin Management
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--- @brief Load all plugin configurations from the 'lazy' directory
--- @see https://github.com/folke/lazy.nvim
require("lazy").setup({
  spec = "ngxxfus.lazy",
  change_detection = { notify = true }, -- Optional: notify on config changes
})