-- Move lines up/down with Alt + j/k or Alt + Up/Down arrows
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", { desc = "Move line up", silent = true })

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line(s) down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line(s) up" })

-- Navigate buffers
vim.keymap.set("n", "<leader><Right>" , "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "<leader><Left>"  , "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer", silent = true })
vim.keymap.set("n", "<leader>h"       , "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer", silent = true })
vim.keymap.set("n", "<leader>l"       , "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set('n', '<leader>n'       , "<cmd>tabnew<cr>"             , { desc = 'New Tab (far-right)' })
-- Move tabs (reorder)
vim.keymap.set("n", "<leader>H", "<Cmd>BufferLineMovePrev<CR>", { desc = "Move buffer left" })
vim.keymap.set("n", "<leader>L", "<Cmd>BufferLineMoveNext<CR>", { desc = "Move buffer right" })

-- Jump tab 1-9
for i = 1, 9 do
  vim.keymap.set("n", "<Space>" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", {
    desc = "Go to buffer " .. i,
    silent = true,
  })
end

-- Close current buffer
vim.keymap.set("n", "<leader>q", "<Cmd>bdelete<CR>", { desc = "Close buffer" })

-- Terminal: map double <Esc> if you want
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Double Esc: Exit terminal mode" })

-- Toggle comment for current line
vim.keymap.set("n", "<C-_>", function()
  require("Comment.api").toggle.linewise.current()
end, { desc = "Toggle comment (linewise)" })

-- Toggle comment in visual mode
vim.keymap.set("v", "<C-_>", function()
  require("Comment.api").toggle.linewise(vim.fn.visualmode())
end, { desc = "Toggle comment (visual)", silent = true })

-- New Terminal at the bottom
vim.keymap.set("n", "<leader>t", function()
  -- Get total height of current window
  local total_height = vim.api.nvim_win_get_height(0)
  local split_height = math.floor(total_height / 4)

  -- Create horizontal split and resize it
  vim.cmd("belowright split")
  vim.cmd(split_height .. "wincmd _")  -- Set height of the split
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "Open horizontal split (1/4 height)", silent = false })

-- Visual Mode: Indent right with Tab, and stay in visual mode
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent right and reselect" })

-- Visual Mode: Indent left with Shift-Tab, and stay in visual mode
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Indent left and reselect" })

-- Normal Mode: Indent current line right with Tab
vim.keymap.set("n", "<Tab>", ">>", { desc = "Indent current line right" })

-- Normal Mode: Indent current line left with Shift-Tab
vim.keymap.set("n", "<S-Tab>", "<<", { desc = "Indent current line left" })

-- Restore last session
vim.keymap.set("n", "<leader>sr", function()
  require("persistence").load()
end, { desc = "Restore session for current dir" })

-- Restore last session, regardless of cwd
vim.keymap.set("n", "<leader>sl", function()
  require("persistence").load({ last = true })
end, { desc = "Restore last session" })

-- Don't save session when in a special filetype (optional)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "gitcommit" then
      vim.cmd("silent! wa")
    end
  end,
})

-- Telescope 
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",  { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>",    { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",  { desc = "Help Tags" })

-- LSB Dio
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "LSP float diagnostic" })

-- Search
vim.keymap.set("v", "/s", [[y/\V<C-r>=escape(@",'/\')<CR><CR>]], { noremap = true, silent = true, desc = "Search for selected text" })

-- NO HIGHLIGHT
vim.keymap.set("n", "<Esc><Esc>", ":noh<CR>", { noremap = true, silent = true })
