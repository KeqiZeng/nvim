return {
    'echasnovski/mini.pick',
    event = 'BufEnter',
    version = '*',
    opts = {},
    init = function()
        vim.ui.select = require('mini.pick').ui_select
    end
}
