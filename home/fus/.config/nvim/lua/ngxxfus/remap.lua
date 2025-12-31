--- @file remap.lua
--- @brief Keybinding and remapping configuration for Neovim.
--- @details Defines custom keybindings for navigation, editing, LSP, and plugin integration.
--- @author ngxxfus
--- @date 2025-12-20
--- @note All keybindings use <leader> mapped to Space.

-- =============================================================================
--  MANUAL & CHEAT SHEET
-- =============================================================================
--
--  PREFIX: <Space> (Leader Key)
--
--  1. NAVIGATION
--     <Alt + 1..9>    : Jump to buffer 1-9 immediately.
--     <Alt + j/k>     : Move current line/block Up or Down.
--     <Ctrl + Arrows> : Jump by word (VS Code style).
--     <Ctrl + e/a>    : Jump to End/Start of line (Insert Mode).
--
--  2. BUFFERS
--     <Space> + h/l   : Cycle Previous/Next Buffer.
--     <Space> + H/L   : Move (Reorder) Buffer Left/Right.
--     <Space> + q     : Close current buffer.
--
--  3. LSP (CODE INTELLIGENCE)
--     F12             : Go to Definition.
--     Ctrl + Click    : Go to Definition (Mouse).
--     Ctrl + d        : Show Diagnostics (Error message popup).
--     gd / gD         : Go to Definition / Declaration.
--
--  4. TERMINAL
--     <Space> + t     : Open small terminal at bottom.
--     Double Esc      : Exit terminal insert mode.
--
--  5. SEARCH & FILES
--     <Space> + ff    : Find Files.
--     <Space> + fg    : Live Grep (Search text in all files).
--     <Space> + e     : Toggle File Explorer (NvimTree).
--
-- =============================================================================

--- @brief Local alias for vim.keymap.set to keep code clean.
local map = vim.keymap.set

-- =============================================================================
--  SECTION: EDITOR NAVIGATION & EDITING
-- =============================================================================

--- @section Line Movement
--- @brief Move lines up and down using Alt + j/k or Alt + Arrow (Like VS Code).
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
map("n", "<A-Down>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
map("n", "<A-Up>", ":m .-2<CR>==", { desc = "Move line up", silent = true })

--- @brief Move selected block up and down (Visual Mode).
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

--- @section Word Navigation (VS Code Style)
--- @brief Normal Mode: Move cursor by word using Ctrl + Arrow keys.
map("n", "<C-Right>", "w", { desc = "Jump to next word" }) -- changed 'e' to 'w' (start of word) for standard VSCode feel
map("n", "<C-Left>", "b", { desc = "Jump to prev word" })

--- @brief Insert Mode: Move cursor by word without exiting Insert mode.
map("i", "<C-Right>", "<C-o>w", { desc = "Jump to next word" })
map("i", "<C-Left>", "<C-o>b", { desc = "Jump to prev word" })

--- @section Line Navigation (Insert Mode)
--- @brief Quick jump to Start/End of line while typing.
map("i", "<C-e>", "<Esc>A", { desc = "Go to end of line" })
map("i", "<C-a>", "<Esc>I", { desc = "Go to beginning of line" })

--- @section Indentation
--- @brief Stay in Visual Mode after indenting.
map("v", "<Tab>", ">gv", { desc = "Indent right and reselect" })
map("v", "<S-Tab>", "<gv", { desc = "Indent left and reselect" })
map("n", "<Tab>", ">>", { desc = "Indent current line right" })
map("n", "<S-Tab>", "<<", { desc = "Indent current line left" })

--- @section Search & Misc
--- @brief Search for selected text in Visual Mode using '/s'.
map("v", "/s", [[y/\V<C-r>=escape(@",'/\')<CR><CR>]], { noremap = true, silent = true, desc = "Search for selected text" })

--- @brief Clear search highlights (Double Esc).
map("n", "<Esc><Esc>", ":noh<CR>", { noremap = true, silent = true })

-- =============================================================================
--  SECTION: BUFFER & WINDOW MANAGEMENT
-- =============================================================================

--- @section Buffer Navigation
map("n", "<leader>h", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer", silent = true })
map("n", "<leader>l", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer", silent = true })
map("n", "<leader><Right>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer", silent = true })
map("n", "<leader><Left>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer", silent = true })

--- @section Buffer Manipulation
map('n', '<leader>n', "<cmd>tabnew<cr>", { desc = 'New Tab (far-right)' })
map("n", "<leader>H", "<Cmd>BufferLineMovePrev<CR>", { desc = "Move buffer left" })
map("n", "<leader>L", "<Cmd>BufferLineMoveNext<CR>", { desc = "Move buffer right" })
map("n", "<leader>q", "<Cmd>bdelete<CR>", { desc = "Close buffer" })
map("n", "<leader>Q", "<Cmd>bdelete!<CR>", { desc = "Close buffer (force)" })

--- @section Buffer Jump (Alt + Number)
--- @brief Jump to buffer 1-9 using Alt + Number.
for i = 1, 9 do
  map({ "n", "i", "v", "t" }, "<A-" .. i .. ">", "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", {
    desc = "Go to buffer " .. i,
    silent = true,
  })
end

-- =============================================================================
--  SECTION: LSP & CODE INTELLIGENCE
-- =============================================================================

--- @section Definition & Declaration
map("n", "<F12>", vim.lsp.buf.definition, { desc = "LSP: Go to definition" })
map("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: Go to declaration" })
map("n", "gI", vim.lsp.buf.implementation, { desc = "LSP: Go to implementation" })

--- @brief Go to definition using Ctrl + Left Click (Mouse support).
map("n", "<C-LeftMouse>", "<LeftMouse><cmd>lua vim.lsp.buf.definition()<CR>", { desc = "LSP: Go to definition (Mouse)" })

--- @section Diagnostics
map("n", "<C-d>", vim.diagnostic.open_float, { desc = "LSP: Float diagnostic" })

--- @section Commenting
map("n", "<C-/>", function() require("Comment.api").toggle.linewise.current() end, { desc = "Toggle comment (linewise)" })
map("n", "<C-k>", function() require("Comment.api").toggle.linewise.current() end, { desc = "Toggle comment (linewise)" })
map("v", "<C-_>", function() require("Comment.api").toggle.linewise(vim.fn.visualmode()) end, { desc = "Toggle comment (visual)", silent = true })
map("v", "<C-k>", function() require("Comment.api").toggle.linewise(vim.fn.visualmode()) end, { desc = "Toggle comment (visual)", silent = true })

-- =============================================================================
--  SECTION: PLUGINS & TERMINAL
-- =============================================================================

--- @section Terminal Management
--- @brief Double Esc to exit Terminal Insert Mode.
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

--- @brief Open horizontal terminal split (1/4 height).
map("n", "<leader>t", function()
  local total_height = vim.api.nvim_win_get_height(0)
  local split_height = math.floor(total_height / 4)
  vim.cmd("belowright split")
  vim.cmd(split_height .. "wincmd _")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "Open terminal split" })

map("n", "<leader>th", function()
  if vim.bo.buftype == "terminal" then vim.cmd("hide") else print("Not in terminal") end
end, { desc = "Hide terminal" })

map("n", "<leader>tq", function()
  if vim.bo.buftype == "terminal" then vim.cmd("quit") else print("Not in terminal") end
end, { desc = "Close terminal" })

--- @section Session Management
map("n", "<leader>sr", function() require("persistence").load() end, { desc = "Restore session (dir)" })
map("n", "<leader>sl", function() require("persistence").load({ last = true }) end, { desc = "Restore last session" })

--- @brief Prevent session saving for git commits.
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "gitcommit" then vim.cmd("silent! wa") end
  end,
})

--- @section Telescope (Fuzzy Finder)
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find Files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",  { desc = "Live Grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",    { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",  { desc = "Help Tags" })

--- @section File Explorer (NvimTree)
--- @note Check hte neotree.lua instead.
-- map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle Explorer" })
-- map("n", "<leader>o", ":NvimTreeFocus<CR>", { desc = "Focus Explorer" })

--- @brief Auto-close completion popup with Ctrl+e (Priority over End-of-line).
vim.keymap.set("i", "<C-e>", function()
  if vim.fn.pumvisible() == 1 then return "<C-e>" end
  -- Fallback to End of Line if no popup is visible
  return "<Esc>A" 
end, { expr = true, desc = "Close completion or Go to EOL" })
