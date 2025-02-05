return {
    'echasnovski/mini.notify',
    version = '*',
    event = "UIEnter",
    opts = {
        window = {
            config = {
                border = "rounded",
            },
        }
    },
    init = function()
        local notify = require('mini.notify')
        vim.notify = notify.make_notify()
        local map = vim.keymap.set

        map('n', '<leader>nh', function()
            return notify.show_history()
        end, { desc = "Show notification history" })

        map('n', '<leader>nc', function()
            return notify.clear()
        end, { desc = "Clear all active notifications" })

        map('n', '<leader>nr', function()
            return notify.refresh()
        end, { desc = "Refresh notification window" })
    end
}
