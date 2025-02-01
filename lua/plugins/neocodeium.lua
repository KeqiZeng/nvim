return {
    "monkoose/neocodeium",
    event = "BufReadPost",
    opts = {},
    init = function()
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

        vim.api.nvim_create_autocmd('User', {
            pattern = 'BlinkCmpMenuOpen',
            callback = function()
                require('neocodeium').clear()
                require('neocodeium.commands').disable()
                -- vim.fn['codeium#Clear']()
                -- vim.g.codeium_enabled = false
            end,
        })
        vim.api.nvim_create_autocmd('User', {
            pattern = 'BlinkCmpMenuClose',
            callback = function()
                require('neocodeium.commands').enable()
                -- vim.g.codeium_enabled = true
            end,
        })
    end,
}
