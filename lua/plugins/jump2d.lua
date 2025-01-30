return {
    'echasnovski/mini.jump2d',
    event = 'BufReadPost',
    version = '*',
    config = function()
        require('mini.jump2d').setup({
            view = {
                dim = true,
            },
            mappings = {
                start_jumping = 's',
            },

        })
        vim.keymap.set(
            { 'n', 'x', 'o' }, '\\\\',
            '<Cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.line_start)<CR>',
            { desc = 'Jump to start of line' }
        )

        vim.keymap.set(
            { 'n', 'x', 'o' }, 'gq',
            '<Cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.query)<CR>',
            { desc = 'Jump to a specific query' }
        )

        vim.keymap.set(
            { 'n', 'x', 'o' }, 'gw',
            '<Cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.word_start)<CR>',
            { desc = 'Jump to a word' }
        )
        vim.cmd("highlight! link MiniJump2dSpot String")
    end
}
