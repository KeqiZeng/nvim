return {
    'saghen/blink.cmp',
    version = '*', -- release tag
    event = 'InsertEnter',
    dependencies = { 'monkoose/neocodeium' },

    config = function()
        local function has_words_before()
            local cursor = vim.api.nvim_win_get_cursor(0)
            local line = cursor[1]
            local col = cursor[2]

            return col ~= 0
                and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s")
                == nil
        end

        vim.api.nvim_create_autocmd('User', {
            pattern = 'BlinkCmpMenuOpen',
            callback = function()
                require('neocodeium').clear()
                require('neocodeium.commands').disable()
                -- vim.fn['codeium#Clear']()
                -- vim.g.codeium_enabled = false
            end,
        })
        vim.api.nvim_create_autocmd('User', {
            pattern = 'BlinkCmpMenuClose',
            callback = function()
                require('neocodeium.commands').enable()
                -- vim.g.codeium_enabled = true
            end,
        })

        require('blink.cmp').setup({
            appearance = {
                nerd_font_variant = 'mono'
            },

            completion = {
                menu = {
                    border = 'rounded',
                    auto_show = function(ctx) return ctx.mode ~= 'cmdline' end,
                    draw = {
                        columns = {
                            { "label",     "label_description", gap = 1 },
                            { "kind_icon", "kind" },
                        },
                    }
                },
                documentation = {
                    window = {
                        border = 'rounded'
                    }
                },
            },

            keymap = {
                preset = 'none',
                ['<C-p>'] = { 'show_documentation', 'hide_documentation', 'fallback' },
                ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
                ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
                ['<CR>'] = { 'accept', 'fallback' },
                ['<C-e>'] = { 'cancel', 'fallback' },
                ['<Tab>'] = {
                    function(cmp)
                        if cmp.is_visible() then
                            return cmp.select_next()
                        elseif cmp.snippet_active() then
                            return cmp.snippet_forward()
                        elseif has_words_before() or vim.api.nvim_get_mode().mode == 'c' then
                            return cmp.show()
                        end
                    end,
                    'fallback'
                },
                ['<S-Tab>'] = {
                    function(cmp)
                        if cmp.is_visible() then
                            return cmp.select_prev()
                        elseif cmp.snippet_active() then
                            return cmp.snippet_backward()
                        end
                    end,
                    'fallback'
                },
            },

            signature = {
                enabled = true,
                window = {
                    border = 'rounded'
                }
            },

            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },

        })
    end
}
