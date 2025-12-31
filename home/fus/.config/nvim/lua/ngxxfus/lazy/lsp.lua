--- @file lsp.lua
--- @brief Language Server Protocol (LSP) configuration
--- @details Configures LSP servers using:
---          - `williamboman/mason.nvim`: LSP server installer
---          - `williamboman/mason-lspconfig.nvim`: Mason integration with lspconfig
---          - `neovim/nvim-lspconfig`: LSP client configuration
--- @author ngxxfus
--- @date 2025-12-10
--- @see https://github.com/williamboman/mason.nvim
--- @see https://github.com/neovim/nvim-lspconfig

return {
  {
    -- Mason: LSP Installer
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    -- Mason-LSPConfig: Bridges Mason with nvim-lspconfig
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configure UI borders for floating windows
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
      vim.diagnostic.config({
        float = { border = "single" }, -- Use single border for diagnostics
      })
       
      -- Keymaps are defined in remap.lua and are global.
      -- This on_attach function is a good place for buffer-local settings if needed.
      local on_attach = function(client, bufnr)
        -- Helper function to create buffer-local keymaps
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, noremap = true, silent = true, desc = "LSP: " .. desc })
        end

        -- Essential keybindings
        map("gd", vim.lsp.buf.definition, "Go to Definition")
        map("gi", vim.lsp.buf.implementation, "Go to Implementation")

        -- Other useful keybindings
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("gr", vim.lsp.buf.references, "Go to References")
        map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
        map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
      end

      -- A table to hold custom server configurations
      local servers = {
         lua_ls = {
           settings = {
             Lua = {
               diagnostics = { globals = { "vim" } },
               workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
             },
           },
         },
         clangd = {
            -- For ESP-IDF, you might need to point to the compile_commands.json.
            -- This is best done with a .clangd file in your project root.
            cmd = { 
                "clangd", 
                "--background-index",
                "--completion-style=detailed",
                "--header-insertion=never", 
                "--function-arg-placeholders",
                "--clang-tidy" , 
            },
         },
         -- pyright and bashls will use the default setup below
       }
 
      require("mason-lspconfig").setup({
        -- A list of servers to automatically install
        -- ensure_installed = { "clangd", "pyright", "lua_ls", "bashls" },
        handlers = {
          function(server_name)
            local server_opts = servers[server_name] or {}
            server_opts.on_attach = on_attach
            server_opts.capabilities = capabilities
            lspconfig[server_name].setup(server_opts)
          end,
        },
      })
    end,
  },
}
