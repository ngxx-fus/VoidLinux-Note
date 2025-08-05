-- Define a local variable for the leader key, if not already defined
local map = vim.keymap.set

-- Move lines up/down with Alt + j/k or Alt + Up/Down arrows
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
map("n", "<A-Down>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
map("n", "<A-Up>", ":m .-2<CR>==", { desc = "Move line up", silent = true })

map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line(s) down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line(s) up" })

-- Navigate buffers
map("n", "<leader><Right>" , "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer", silent = true })
map("n", "<leader><Left>"  , "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer", silent = true })
map("n", "<leader>h"       , "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer", silent = true })
map("n", "<leader>l"       , "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer", silent = true })
map('n', '<leader>n'       , "<cmd>tabnew<cr>"             , { desc = 'New Tab (far-right)' })
-- Move tabs (reorder)
map("n", "<leader>H", "<Cmd>BufferLineMovePrev<CR>", { desc = "Move buffer left" })
map("n", "<leader>L", "<Cmd>BufferLineMoveNext<CR>", { desc = "Move buffer right" })

-- Jump tab 1-9
for i = 1, 9 do
  map("n", "<Space>" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", {
    desc = "Go to buffer " .. i,
    silent = true,
  })
end

-- Close current buffer
map("n", "<leader>q", "<Cmd>bdelete<CR>", { desc = "Close buffer" })

-- Terminal: map double <Esc> if you want
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Double Esc: Exit terminal mode" })

-- Toggle comment for current line
map("n", "<C-/>", function()
  require("Comment.api").toggle.linewise.current()
end, { desc = "Toggle comment (linewise)" })

-- Toggle comment in visual mode
map("v", "<C-_>", function()
  require("Comment.api").toggle.linewise(vim.fn.visualmode())
end, { desc = "Toggle comment (visual)", silent = true })


-- Keymap: <leader>t - Open a new terminal at the bottom (1/4 height)
-- This keymap creates a new horizontal split window below the current one,
-- resizes it to 1/4 of the total window height, opens a terminal in it,
-- and puts you directly into insert mode within the terminal.
map("n", "<leader>t", function()
  -- Get the total height of the current window
  local total_height = vim.api.nvim_win_get_height(0)
  -- Calculate 1/4 of the total height for the new split
  local split_height = math.floor(total_height / 4)

  -- Create a new horizontal split window below the current one
  vim.cmd("belowright split")
  -- Set the height of the newly created split window
  vim.cmd(split_height .. "wincmd _")
  -- Open a terminal in the new split window
  vim.cmd("terminal")
  -- Enter insert mode automatically in the terminal
  vim.cmd("startinsert")
end, { desc = "Open new horizontal terminal split (1/4 height)" })

-- Keymap: <leader>T (Shift+t) - Hide the current terminal
-- This keymap hides the current window. If the current window contains a terminal,
-- it will hide that terminal window but keep the terminal buffer and process running
-- in the background. You can switch back to it later using `:buffers` or other means.
map("n", "<leader>th", function()
  -- Check if the current buffer is a terminal buffer
  if vim.bo.buftype == "terminal" then
    -- Hide the current window
    vim.cmd("hide")
    print("Terminal hidden. Use :ls to see buffers or :b <number> to switch back.")
  else
    print("Not in a terminal window to hide.")
  end
end, { desc = "Hide current terminal window" })

-- Keymap: <leader>tq - Close the current terminal
-- This keymap quits the current window. If the current window is a terminal,
-- it will close the terminal window and terminate the associated terminal process.
-- This is a permanent closure of that specific terminal instance.
map("n", "<leader>tq", function()
  -- Check if the current buffer is a terminal buffer
  if vim.bo.buftype == "terminal" then
    -- Quit the current window, which closes the terminal and kills its process
    vim.cmd("quit")
    print("Terminal closed.")
  else
    print("Not in a terminal window to close.")
  end
end, { desc = "Close current terminal" })

-- Visual Mode: Indent right with Tab, and stay in visual mode
map("v", "<Tab>", ">gv", { desc = "Indent right and reselect" })

-- Visual Mode: Indent left with Shift-Tab, and stay in visual mode
map("v", "<S-Tab>", "<gv", { desc = "Indent left and reselect" })

-- Normal Mode: Indent current line right with Tab
map("n", "<Tab>", ">>", { desc = "Indent current line right" })

-- Normal Mode: Indent current line left with Shift-Tab
map("n", "<S-Tab>", "<<", { desc = "Indent current line left" })

-- Restore last session
map("n", "<leader>sr", function()
  require("persistence").load()
end, { desc = "Restore session for current dir" })

-- Restore last session, regardless of cwd
map("n", "<leader>sl", function()
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
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find Files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",  { desc = "Live Grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",    { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",  { desc = "Help Tags" })

-- LSB Dio
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "LSP float diagnostic" })

-- Search
map("v", "/s", [[y/\V<C-r>=escape(@",'/\')<CR><CR>]], { noremap = true, silent = true, desc = "Search for selected text" })

-- NO HIGHLIGHT
map("n", "<Esc><Esc>", ":noh<CR>", { noremap = true, silent = true })
