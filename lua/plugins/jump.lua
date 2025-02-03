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
}
