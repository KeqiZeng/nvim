return {
    'echasnovski/mini.jump2d',
    event = 'BufReadPost',
    version = '*',
    dependencies = { 'catppuccin/nvim' },
    opts = function()
        local jump2d = require('mini.jump2d')
        local word = jump2d.gen_union_spotter(
            jump2d.gen_pattern_spotter('^()[%a]', 'none'),   -- match word at line start
            jump2d.gen_pattern_spotter('%s()[%a]', 'none'),  -- match word after space
            jump2d.gen_pattern_spotter('[%p]()[%a]', 'none') -- match word after punctuation
        )
        local number = jump2d.gen_union_spotter(
            jump2d.gen_pattern_spotter('^()[%d]', 'none'),              -- match number at line start
            jump2d.gen_pattern_spotter('[^%d%a%.]%f[%d]()[%d]', 'none') -- match start of number, not after letter/dot/digit
        )
        local multi_punct = jump2d.gen_pattern_spotter('()[%p][%p][%p]*', 'none')
        local camel_case = jump2d.gen_pattern_spotter('[%l][%u]', 'end')
        return {
            spotter = jump2d.gen_union_spotter(
                word,
                number,
                multi_punct,
                camel_case
            ),
            view = {
                dim = true,
                n_steps_ahead = 2,
            },
            mappings = {
                start_jumping = 'gs',
            },
        }
    end,
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
    end
}
