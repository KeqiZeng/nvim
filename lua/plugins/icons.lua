return {
    'echasnovski/mini.icons',
    version = '*',
    opts = {},
    init = function()
        require('mini.icons').mock_nvim_web_devicons()
    end
}
