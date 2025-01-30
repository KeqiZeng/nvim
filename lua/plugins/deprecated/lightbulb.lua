return {
    'kosayoda/nvim-lightbulb',
    event = 'LspAttach',
    opts = {
        autocmd = {
            enabled = true,
            event = 'CursorHold',
            updatetime = 100,
        },
    },
}
