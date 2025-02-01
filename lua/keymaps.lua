vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local map = vim.keymap.set

-- better up/down
map(
    { "n", "x", "o" },
    "j",
    "v:count == 0 ? 'gj' : 'j'",
    { expr = true, silent = true, desc = "Down" }
)
map(
    { "n", "x", "o" },
    "<Down>",
    "v:count == 0 ? 'gj' : 'j'",
    { expr = true, silent = true, desc = "Down" }
)
map(
    { "n", "x", "o" },
    "k",
    "v:count == 0 ? 'gk' : 'k'",
    { expr = true, silent = true, desc = "Up" }
)
map(
    { "n", "x", "o" },
    "<Up>",
    "v:count == 0 ? 'gk' : 'k'",
    { expr = true, silent = true, desc = "Up" }
)

map("n", "U", "<C-r>", { desc = "Redo" })

map({ "n", "x", "o" }, "gh", "^", { desc = "Go to line start" })
map({ "n", "x", "o" }, "gl", "$", { desc = "Go to line end" })

map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- map("n", "<backspace>", "<cmd>nohl<cr>", { desc = "Clear hlsearch" })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Go to previous/next buffer
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Toggle options
map("n", "<leader>tw", "<cmd>set wrap!<cr>", { desc = "Toggle wrap" })
map("n", "<leader>ts", "<cmd>set spell!<cr>", { desc = "Toggle spell" })
