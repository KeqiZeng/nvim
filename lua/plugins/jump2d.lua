return {
    'echasnovski/mini.jump2d',
    event = 'BufReadPost',
    version = '*',
    opts = {
        view = {
            dim = true,
        },
        mappings = {
            start_jumping = 'gs',
        },
    },
    init = function()
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
    end
}
