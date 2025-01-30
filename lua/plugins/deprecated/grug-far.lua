return {
    'MagicDuck/grug-far.nvim',
    event = "VimEnter",
    config = function()
        require('grug-far').setup({
            -- options, see Configuration section below
            -- there are no lsd options atm
            -- engine = 'ripgrep' is default, but 'astgrep' can be specified
        });
    end
}
