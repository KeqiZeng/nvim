return {
    'echasnovski/mini.diff',
    version = '*',
    event = "BufReadPost",
    opts = {
        mappings = {
            apply = '',
            reset = '',
            textobject = 'ih',

            goto_first = '[H',
            goto_prev = '[h',
            goto_next = ']h',
            goto_last = ']H',
        },
        options = {
            wrap_goto = true,
        },
    },
    init = function()
        local diff = require('mini.diff')
        local map = vim.keymap.set
        map('n', '<leader>ha', function()
            return diff.operator('apply') .. 'ih'
        end, { expr = true, remap = true, desc = "Apply hunk under cursor" })

        map('n', '<leader>hr', function()
            return diff.operator('reset') .. 'ih'
        end, { expr = true, remap = true, desc = "Reset hunk under cursor" })

        map('n', '<leader>th', function()
            diff.toggle_overlay()
        end, { desc = "Toggle hunk overlay" })
    end
}
