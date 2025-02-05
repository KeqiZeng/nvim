return {
    'echasnovski/mini.surround',
    event = 'BufReadPost',
    version = '*',
    opts = function()
        local ts_input = require('mini.surround').gen_spec.input.treesitter
        return {
            custom_surroundings = {
                f = {
                    input = ts_input({ outer = '@function.outer', inner = '@function.inner' })
                },
            }
        }
    end
    -- alias: b - ( [ {, q - " ' `, t - tag, f - function, ? - interactive input
}
