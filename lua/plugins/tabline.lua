return {
    'echasnovski/mini.tabline',
    event = "UIEnter",
    version = '*',
    opts = function()
        local tabline = require('mini.tabline')
        return {
            format = function(buf_id, label)
                local suffix = vim.bo[buf_id].modified and '+ ' or ''
                return tabline.default_format(buf_id, label) .. suffix
            end
        }
    end,
}
