return {
    'echasnovski/mini.jump',
    version = '*',
    event = "BufReadPost",
    dependencies = { "catppuccin/nvim" },
    opts = {
        delay = {
            idle_stop = 30000,
        },
    },
    init = function()
        local palette = require("catppuccin.palettes").get_palette("mocha")
        vim.cmd("highlight MiniJump guifg=" .. palette.base .. " guibg=" .. palette.red)
    end
}
