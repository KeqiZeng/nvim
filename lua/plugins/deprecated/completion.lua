return {
    'echasnovski/mini.completion',
    event = 'InsertEnter',
    version = '*',
    opts = {
        delay = {
            completion = 0,
            info = 200,
            signature = 0
        },
        lsp_completion = {
            source_func = 'omnifunc',
            auto_setup = false
        },
        fallback_action = '<C-n>',
        mappings = {
            force_twostep = '<C-\\>', -- Force two-step completion
            force_fallback = ''
        },
    },
    init = function()
        local imap_expr = function(lhs, rhs)
            vim.keymap.set('i', lhs, rhs, { expr = true })
        end
        imap_expr('<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
        imap_expr('<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])

        local keycode = vim.keycode or function(x)
            return vim.api.nvim_replace_termcodes(x, true, true, true)
        end
        local keys = {
            ['cr']        = keycode('<CR>'),
            ['ctrl-y']    = keycode('<C-y>'),
            ['ctrl-y_cr'] = keycode('<C-y><CR>'),
        }

        _G.cr_action = function()
            if vim.fn.pumvisible() ~= 0 then
                -- If popup is visible, confirm selected item or add new line otherwise
                local item_selected = vim.fn.complete_info()['selected'] ~= -1
                return item_selected and keys['ctrl-y'] or keys['ctrl-y_cr']
            else
                -- If popup is not visible, use plain `<CR>`. You might want to customize
                -- according to other plugins. For example, to use 'mini.pairs', replace
                -- next line with `return require('mini.pairs').cr()`
                return keys['cr']
            end
        end

        vim.keymap.set('i', '<CR>', 'v:lua._G.cr_action()', { expr = true })
    end
}
