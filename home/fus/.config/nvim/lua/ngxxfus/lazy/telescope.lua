--- @file telescope.lua
--- @brief Configuration for Telescope, a fuzzy finder over lists.
--- @details Configures the fuzzy finder interface, layout, and FZF integration for high-performance sorting.
--- @author ngxxfus
--- @date 2025-12-09

return {
  {
    --- @brief The main Telescope plugin repository.
    "nvim-telescope/telescope.nvim",

    --- @brief Dependencies required for Telescope to function correctly.
    dependencies = {
      --- @brief Shared Lua functions library.
      "nvim-lua/plenary.nvim",

      --- @brief Native C port of FZF for improved performance.
      --- @details Requires 'make' (or cmake on Windows) to be available.
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },

    --- @brief Lazy load the plugin only when the 'Telescope' command is invoked.
    cmd = "Telescope",

    --- @brief Plugin setup and configuration.
    config = function()
      require("telescope").setup({
        defaults = {
          --- @brief Set the layout strategy to horizontal (previewer to the right).
          layout_strategy = "horizontal",

          --- @brief Set the window width to 90% of the editor width.
          layout_config = { width = 0.9 },

          --- @brief List results from top to bottom (ascending).
          sorting_strategy = "ascending",

          --- @brief Set window transparency level (0 is opaque, 100 is transparent).
          winblend = 5,
        },
        pickers = {
          --- @brief Configuration for the file finder.
          find_files = {
            --- @brief Include hidden files (files starting with '.') in search results.
            hidden = true,
          },
        },
        extensions = {
          --- @brief Configuration for the FZF native extension.
          fzf = {
            --- @brief Enable fuzzy matching.
            fuzzy = true,
            --- @brief Override the generic sorter with the FZF sorter.
            override_generic_sorter = true,
            --- @brief Override the file sorter with the FZF sorter.
            override_file_sorter = true,
            --- @brief specific case handling (ignore case unless uppercase is typed).
            case_mode = "smart_case",
          },
        },
      })

      --- @brief Safely load the FZF extension.
      --- @details Uses pcall to prevent Neovim crash if fzf build fails.
      pcall(require("telescope").load_extension, "fzf")
    end,
  },
}
