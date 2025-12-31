--- @file lazy_init.lua
--- @brief Lazy.nvim plugin manager bootstrap and initialization.
--- @details Handles installation of lazy.nvim if not present and sets up
---          the plugin manager with specifications located in 'ngxxfus.lazy'.
--- @author ngxxfus
--- @date 2025-11-30
--- @see https://github.com/folke/lazy.nvim

--- @brief Define the installation path for lazy.nvim.
--- @details Uses the standard data directory of Neovim.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

--- @brief Bootstrap lazy.nvim.
--- @details Checks if the repository exists at 'lazypath'. If not, it clones the
---          stable branch from GitHub.
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

--- @brief Add lazy.nvim to the runtime path.
--- @details Ensures the plugin manager is available for the subsequent require call.
vim.opt.rtp:prepend(lazypath)

--- @brief Initialize lazy.nvim.
--- @details Loads plugin specifications from the 'ngxxfus.lazy' module and
---          disables notifications for config change detection.
require("lazy").setup({
  spec = "ngxxfus.lazy",
  change_detection = { notify = true }
})