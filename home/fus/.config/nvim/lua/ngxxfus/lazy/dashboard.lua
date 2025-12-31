--- @file dashboard.lua
--- @brief Startup dashboard configuration.
--- @details Configures nvimdev/dashboard-nvim with custom buttons for Session and Recent files.
--- @author ngxxfus
--- @date 2025-12-09

return {
  {
    --- @brief The dashboard plugin repository.
    "nvimdev/dashboard-nvim",

    --- @brief Load only when entering Vim (startup).
    event = "VimEnter",

    --- @brief Dependencies for icons.
    dependencies = { "nvim-tree/nvim-web-devicons" },

    --- @brief Configuration function.
    config = function()
      --- @brief Define the logo art (Time removed).
      local logo = {
        " __ _   ___  _  _  _  _     ____  _  _  ____ ",
        "(  ( \\ / __)( \\/ )( \\/ )   (  __)/ )( \\/ ___)",
        "/    /( (_ \\ )  (  )  (  _  ) _) ) \\/ (\\___ \\",
        "\\_)__) \\___/(_/\\_)(_/\\_)(_)(__)  \\____/(____/",
        "",
        "                [ msnp@outlook.com.vn ]                 ",
        "",
      }

      --- @brief Algorithm to vertically center the dashboard.
      local function get_centered_header()
        local height = vim.api.nvim_win_get_height(0)
        local content_height = 18 
        local pad_lines = math.max(0, math.floor((height - content_height) / 2))
        
        local padded_logo = {}
        for _ = 1, pad_lines do table.insert(padded_logo, "") end
        for _, line in ipairs(logo) do table.insert(padded_logo, line) end
        return padded_logo
      end

      require('dashboard').setup({
        --- @brief Use 'doom' theme for a clean list style.
        theme = 'doom',

        config = {
          header = get_centered_header(),

          --- @brief Center buttons (Updated options).
          center = {
            {
              icon = "  ",
              desc = "Restore Session      ",
              key = "s",
              --- @brief Load the last session using persistence.
              action = function() require("persistence").load({ last = true }) end,
            },
            {
              icon = "  ", 
              desc = "Recent Projects      ", 
              key = "p",
              --- @brief Select from a list of saved sessions (folders).
              action = function() require("persistence").select() end,
            },
            {
              icon = "  ",
              desc = "Find File            ",
              key = "f",
              action = "Telescope find_files",
            },
            {
              icon = "  ",
              desc = "Recent Files         ",
              key = "r",
              --- @brief List recent files (Scrollable/Editable via Telescope).
              action = "Telescope oldfiles",
            },
            {
              icon = "  ",
              desc = "Find Text (Ripgrep)  ",
              key = "g",
              action = "Telescope live_grep",
            },
            {
              icon = "  ",
              desc = "Quit                 ",
              key = "q",
              action = "qa",
            },
          },

          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      })
      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*",
        callback = function()
          vim.opt.laststatus = 3
        end,
      })
    end,
  },
}
