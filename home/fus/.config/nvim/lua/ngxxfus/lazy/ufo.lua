--- @file folding.lua
--- @brief Code folding configuration using nvim-ufo.
--- @details Provides LSP-aware code folding with custom virtual text handler.
--- @author ngxxfus
--- @date 2025-12-20

return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "neovim/nvim-lspconfig",
      "kevinhwang91/promise-async",
    },
    config = function()
      vim.o.foldcolumn = "1" 
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      -- vim.o.fillchars = [[eob: ,fold: ,foldopen: ,foldsep: ,foldclose:]]

      vim.api.nvim_set_hl(0, "FoldColumn", { fg = "#B8DB80", bg = "NONE" })

      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (' 󰁂 %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0

        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end

      -- Configure nvim-ufo
      require("ufo").setup({
        open_fold_hl_timeout = 150,
        close_fold_kinds_for_ft = {
          default = { 'imports', 'comment' },
          json = { 'array' },
          c = { 'comment', 'region' }
        },
        close_fold_current_line_for_ft = {
          default = true,
          c = false
        },
        preview = {
          win_config = {
            border = { '', '─', '', '', '', '─', '', '' },
            winhighlight = 'Normal:Folded',
            winblend = 0
          },
          mappings = {
            scrollU = '<C-u>',
            scrollD = '<C-d>',
            jumpTop = '[',
            jumpBot = ']'
          }
        },
        provider_selector = function(bufnr, filetype, buftype)
          return { "treesitter", "indent" }
        end,
        fold_virt_text_handler = handler, 
      })

      -- Keymaps
      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "UFO: Open All Folds" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "UFO: Close All Folds" })
    end,
  },
}
