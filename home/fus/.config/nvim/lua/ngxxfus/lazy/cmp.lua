-- return {
--   {
--     "hrsh7th/nvim-cmp",
--     event = "InsertEnter",
--     dependencies = {
--       "L3MON4D3/LuaSnip",         -- Snippet engine
--       "saadparwaiz1/cmp_luasnip", -- Snippet completion
--       "hrsh7th/cmp-buffer",       -- Words from current buffer
--       "hrsh7th/cmp-path",         -- Filesystem paths
--       "hrsh7th/cmp-nvim-lsp",     -- LSP completions
--       "hrsh7th/cmp-nvim-lua",     -- Neovim Lua API
--     },
--     config = function()
--       local cmp = require("cmp")
--       local luasnip = require("luasnip")
-- 
--       require("luasnip.loaders.from_vscode").lazy_load() -- load snippets
-- 
--       cmp.setup({
--         snippet = {
--           expand = function(args)
--             luasnip.lsp_expand(args.body)
--           end,
--         },
--         mapping = cmp.mapping.preset.insert({
--           ["<C-Space>"] = cmp.mapping.complete(),
--           ["<CR>"] = cmp.mapping.confirm({ select = true }),
--           ["<Tab>"] = cmp.mapping(function(fallback)
--             if cmp.visible() then
--               cmp.select_next_item()
--             elseif luasnip.expand_or_jumpable() then
--               luasnip.expand_or_jump()
--             else
--               fallback()
--             end
--           end, { "i", "s" }),
--           ["<S-Tab>"] = cmp.mapping(function(fallback)
--             if cmp.visible() then
--               cmp.select_prev_item()
--             elseif luasnip.jumpable(-1) then
--               luasnip.jump(-1)
--             else
--               fallback()
--             end
--           end, { "i", "s" }),
--         }),
--         sources = cmp.config.sources({
--           { name = "nvim_lsp" },
--           { name = "luasnip" },
--           { name = "buffer" },
--           { name = "path" },
--           { name = "nvim_lua" },
--         }),
--       })
--     end,
--   }
-- }

return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",         -- Snippet engine
      "saadparwaiz1/cmp_luasnip", -- Snippet completion
      "hrsh7th/cmp-buffer",       -- Words from current buffer
      "hrsh7th/cmp-path",         -- Filesystem paths
      "hrsh7th/cmp-nvim-lsp",     -- LSP completions
      "hrsh7th/cmp-nvim-lua",     -- Neovim Lua API
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("luasnip.loaders.from_vscode").lazy_load() -- load snippets

      -- Setup LSP servers with capabilities
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
          },
        },
      })

      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = { "clangd", "--header-insertion=never", "--clang-tidy" },
      })

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
          { name = "nvim_lua" },
        }),
      })
    end,
  }
}

