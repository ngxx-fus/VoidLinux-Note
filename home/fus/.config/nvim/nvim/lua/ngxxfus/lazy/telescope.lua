-- ~/.config/nvim/lua/ngxxfus/lazy/telescope.lua

-- return {
--   {
--     "nvim-telescope/telescope.nvim",
--     dependencies = {
--       "nvim-lua/plenary.nvim"
--     },
--     config = function()
--       require("telescope").setup({
--         defaults = {
--           layout_config = {
--             horizontal = { width = 0.9 },
--           },
--         },
--       })
--     end,
--     cmd = "Telescope", -- lazy load when :Telescope is called
--   },
-- }


return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    cmd = "Telescope",
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { width = 0.9 },
          sorting_strategy = "ascending",
          winblend = 5,
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })

      -- Load fzf extension *after* setup
      require("telescope").load_extension("fzf")
    end,
  },
}

