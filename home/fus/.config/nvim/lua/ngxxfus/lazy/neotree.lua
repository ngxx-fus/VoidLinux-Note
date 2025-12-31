--- @file neo-tree.lua
--- @brief File Explorer configuration with Dual Mode (Dock vs Float).
--- @details MINIMALIST EDITION: Monochromatic theme (No Git colors), relying solely on icons/symbols.
--- @author ngxxfus
--- @date 2025-12-20

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    
    -- === SMART KEYMAPS (DUAL MODE) ===
    keys = {
      -- MODE 1: DOCK (Space + e)
      { 
        "<leader>e", 
        function() 
          require("neo-tree.command").execute({ toggle = true, position = "left" }) 
        end, 
        desc = "Explorer (Dock Left)" 
      },

      -- MODE 2: FLOAT (Space + Shift + e)
      { 
        "<leader>E", 
        function() 
          require("neo-tree.command").execute({ toggle = true, position = "float" }) 
        end, 
        desc = "Explorer (Float Center)" 
      },
    },

    config = function()
      -- === 1. MINIMALIST COLOR PALETTE (MONOCHROME) ===
      -- @details Setting everything to a single clean Dark Grey tone.
      local cmd = vim.api.nvim_set_hl
      local mono_color_text = "#31363F" -- The main text color (Dark Grey)
      local mono_color_dir = "#213555"

      -- Force Folders & Files to look the same
      cmd(0, "NeoTreeDirectoryIcon", { fg = mono_color_dir })
      cmd(0, "NeoTreeDirectoryName", { fg = mono_color_text, bold = false })
      cmd(0, "NeoTreeRootName", { fg = mono_color_text, bold = false, italic = true }) 
      cmd(0, "NeoTreeFileName", { fg = mono_color_text }) 
      cmd(0, "NeoTreeFileIcon", { fg = mono_color_text }) 

      -- === DISABLE GIT COLORS (The Key to Minimalism) ===
      -- Map all Git states to the same color. We rely on SYMBOLS now.
      cmd(0, "NeoTreeGitAdded", { fg = mono_color_text })
      cmd(0, "NeoTreeGitConflict", { fg = mono_color_text })
      cmd(0, "NeoTreeGitDeleted", { fg = mono_color_text })
      cmd(0, "NeoTreeGitIgnored", { fg = "#BDC3C7" }) -- Just slightly lighter for ignored files
      cmd(0, "NeoTreeGitModified", { fg = mono_color_text })
      cmd(0, "NeoTreeGitUntracked", { fg = mono_color_text })

      -- UI Elements
      cmd(0, "NeoTreeIndentMarker", { fg = "#E1E1E1" }) -- Very faint grey lines
      cmd(0, "NeoTreeFloatBorder", { fg = mono_color_text }) 
      cmd(0, "NeoTreeFloatTitle", { fg = mono_color_text, bold = false })

      -- === 2. SETUP NEO-TREE ===
      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        
        -- Window config
        window = {
            position = "left", 
            width = 30,
        },
        
        -- UI Components
        default_component_configs = {
          indent = {
            indent_size = 2,
            padding = 1,
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            highlight = "NeoTreeIndentMarker",
          },
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "󰜌",
            default = "*",
            highlight = "NeoTreeFileIcon",
          },
          name = {
            trailing_slash = false,
            -- @important: DISABLE GIT COLORS ON TEXT
            use_git_status_colors = false, 
            highlight = "NeoTreeFileName",
          },
          git_status = {
            symbols = {
              -- Minimalist symbols
              added     = "+",
              modified  = "",
              deleted   = "x",
              renamed   = "->",
              untracked = "?",
              ignored   = "◌",
              unstaged  = "U",
              staged    = "S",
              conflict  = "!",
            }
          },
        },

        filesystem = {
          filtered_items = {
            visible = true, 
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = {
            enabled = true, 
          },
          use_libuv_file_watcher = true,
        },
      })
    end,
  }
}
