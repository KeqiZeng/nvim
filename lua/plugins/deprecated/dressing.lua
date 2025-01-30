return {
    'stevearc/dressing.nvim',
    event = "UIEnter",
    opts = {
        input = {
            title_pos = "center",
            relative = "editor",

            mappings = {
                n = {
                  ["<Esc>"] = "Close",
                  ["<CR>"] = "Confirm",
                  ["k"] = "HistoryPrev",
                  ["j"] = "HistoryNext",
                  ["<Up>"] = "HistoryPrev",
                  ["<Down>"] = "HistoryNext",
                },
                i = {
                  ["<C-c>"] = "Close",
                  ["<CR>"] = "Confirm",
                  ["<C-k>"] = "HistoryPrev",
                  ["<C-j>"] = "HistoryNext",
                  ["<Up>"] = "HistoryPrev",
                  ["<Down>"] = "HistoryNext",
                },
            },
        }
    },
}