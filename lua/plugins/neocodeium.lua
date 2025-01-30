return {
    "monkoose/neocodeium",
    event = "BufReadPost",
    config = function()
        require("neocodeium").setup()
        vim.keymap.set("i", "<C-a>", function()
            require("neocodeium").accept()
        end, { noremap = true, silent = true })
        vim.keymap.set("i", "<C-j>", function()
            require("neocodeium").cycle_or_complete()
        end, { noremap = true, silent = true })
        vim.keymap.set("i", "<C-k>", function()
            require("neocodeium").cycle_or_complete(-1)
        end, { noremap = true, silent = true })
        vim.keymap.set("i", "<C-e>", function()
            require("neocodeium").clear()
        end, { noremap = true, silent = true })
    end,
}
