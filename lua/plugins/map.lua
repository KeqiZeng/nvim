return {
    'echasnovski/mini.map',
    event = 'UIEnter',
    version = '*',
    opts = function()
        local diagnostic_integration = require('mini.map').gen_integration.diagnostic({
            error = 'DiagnosticFloatingError',
            warn  = 'DiagnosticFloatingWarn',
            info  = 'DiagnosticFloatingInfo',
            hint  = 'DiagnosticFloatingHint',
        })

        return {
            window = {
                show_integration_count = false,
                winblend = 0,
                zindex = 99,
            },
            integrations = {
                require('mini.map').gen_integration.builtin_search(),
                diagnostic_integration,
            },
        }
    end,
    init = function()
        local map = require('mini.map')
        vim.keymap.set('n', '<leader>tm', function()
            map.toggle()
            vim.g.minimap_opened = not vim.g.minimap_opened
        end, { desc = "Toggle minimap" })

        vim.keymap.set("n", "<backspace>", "<cmd>nohl<cr><cmd>lua MiniMap.refresh(nil, { integrations = true })<cr>",
            { desc = "Clear hlsearch" })
        vim.keymap.set({ "n", "x", "o" }, "n", "n<cmd>lua MiniMap.refresh(nil, { integrations = true })<cr>",
            { desc = "Next search result" })
        vim.keymap.set({ "n", "x", "o" }, "N", "N<cmd>lua MiniMap.refresh(nil, { integrations = true })<cr>",
            { desc = "Previous search result" })

        map.open()
        vim.g.minimap_opened = true
    end
}
