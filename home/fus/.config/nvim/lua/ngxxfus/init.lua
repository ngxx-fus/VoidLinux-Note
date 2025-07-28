vim.g.mapleader = " " -- Set leader key before anything else

-- Base config first
require("ngxxfus.set")          -- Options like line numbers, etc.
require("ngxxfus.remap")        -- Keymaps

-- Lazy plugin manager
require("ngxxfus.lazy_init")    -- Plugin loader/bootstrap

-- Plugin configs (after lazy_init loads plugins)
require("ngxxfus.lazy.icons")
require("ngxxfus.lazy.cmp")     -- Auto-completion (depends on LSP sometimes)
require("ngxxfus.lazy.lsp")     -- LSP (must come before telescope if using lsp pickers)
require("ngxxfus.lazy.telescope")

