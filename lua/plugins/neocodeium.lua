return {
    "monkoose/neocodeium",
    event = "InsertEnter",
    dependencies = { 'saghen/blink.cmp' },
    opts = {
        filter = function()
            return not require("blink.cmp").is_visible()
        end,
    },
    init = function()
        local neocodeium = require("neocodeium")
        vim.keymap.set("i", "<C-a>", function()
            neocodeium.accept()
        end, { noremap = true, silent = true })
        vim.keymap.set("i", "<C-j>", function()
            neocodeium.cycle_or_complete()
        end, { noremap = true, silent = true })
        vim.keymap.set("i", "<C-k>", function()
            neocodeium.cycle_or_complete(-1)
        end, { noremap = true, silent = true })

        vim.keymap.set("i", "<C-e>", function()
            if vim.fn.pumvisible() == 0 then
                neocodeium.clear()
            else
                vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes("<C-e>", true, true, true),
                    "n",
                    true
                )
            end
        end, { noremap = true, silent = true })

        vim.api.nvim_create_autocmd('User', {
            pattern = 'BlinkCmpMenuOpen',
            callback = function()
                neocodeium.clear()
            end,
        })
    end,
}
