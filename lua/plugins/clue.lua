return {
    'echasnovski/mini.clue',
    version = '*',
    event = "BufReadPost",
    opts = function()
        local miniclue = require('mini.clue')
        return {
            window = {
                config = {
                    width = 50,
                    border = 'rounded',
                    zindex = 100,
                }
            },
            triggers = {
                -- Marks
                { mode = 'n', keys = "'" },
                { mode = 'n', keys = '`' },
                { mode = 'x', keys = "'" },
                { mode = 'x', keys = '`' },

                -- Registers
                { mode = 'n', keys = '"' },
                { mode = 'x', keys = '"' },
                { mode = 'i', keys = '<C-r>' },
                { mode = 'c', keys = '<C-r>' },

                -- Window commands
                { mode = 'n', keys = '<C-w>' },

                -- `g` key
                { mode = 'n', keys = 'g' },
                { mode = 'x', keys = 'g' },

                -- `z` key
                { mode = 'n', keys = 'z' },
                { mode = 'x', keys = 'z' },

                -- 's' key
                { mode = 'n', keys = 's' },
                { mode = 'x', keys = 's' },

                -- Leader triggers
                { mode = 'n', keys = '<leader>' },
                { mode = 'x', keys = '<leader>' },
            },
            clues = {
                miniclue.gen_clues.marks(),
                miniclue.gen_clues.registers(),
                miniclue.gen_clues.windows({
                    submode_move = false,
                    submode_navigate = false,
                    submode_resize = true,
                }),
                miniclue.gen_clues.g(),
                miniclue.gen_clues.z(),

                -- clue for leader triggers
                { mode = 'n', keys = '<leader>f',  desc = 'FZF' },
                { mode = 'n', keys = '<leader>t',  desc = 'Toggle' },
                { mode = 'n', keys = '<leader>h',  desc = 'Hunks' },
                { mode = 'x', keys = '<leader>h',  desc = 'Hunks' },
                { mode = 'n', keys = '<leader>m',  desc = 'MultiCursor' },
                { mode = 'x', keys = '<leader>m',  desc = 'MultiCursor' },
                { mode = 'n', keys = 'gS',         desc = 'Swap parameters' },

                -- submode multicursor <leader>m
                { mode = 'n', keys = '<leader>mj', postkeys = '<leader>m' },
                { mode = 'n', keys = '<leader>mk', postkeys = '<leader>m' },
                { mode = 'n', keys = '<leader>mJ', postkeys = '<leader>m' },
                { mode = 'n', keys = '<leader>mK', postkeys = '<leader>m' },
                { mode = 'n', keys = '<leader>mn', postkeys = '<leader>m' },
                { mode = 'n', keys = '<leader>ms', postkeys = '<leader>m' },
                { mode = 'n', keys = '<leader>mp', postkeys = '<leader>m' },
                { mode = 'n', keys = '<leader>mS', postkeys = '<leader>m' },
                { mode = 'n', keys = '<leader>mh', postkeys = '<leader>m' },
                { mode = 'n', keys = '<leader>ml', postkeys = '<leader>m' },
                { mode = 'n', keys = '<leader>mx', postkeys = '<leader>m' },
                { mode = 'n', keys = '<leader>mA', postkeys = '<leader>m' },
            },

        }
    end,
    init = function()
        -- disable s key for mini.surround so that clue can works for s key
        vim.keymap.set({ 'n', 'x' }, 's', '<nop>')
    end
}
