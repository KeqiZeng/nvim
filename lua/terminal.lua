local term_height = 20

-- Store terminal buffer ID
local term_buf = nil

-- Function to toggle terminal visibility
local function toggle_terminal()
    if term_buf == nil or not vim.api.nvim_buf_is_valid(term_buf) then
        -- Create new terminal if none exists
        vim.cmd('below split')
        local win = vim.api.nvim_get_current_win()
        vim.cmd('terminal')
        term_buf = vim.api.nvim_get_current_buf()

        -- Set terminal window height
        vim.api.nvim_win_set_height(win, term_height)
        -- Hide terminal buffer from buffer list
        vim.api.nvim_buf_set_option(term_buf, 'buflisted', false)
        vim.api.nvim_buf_set_option(term_buf, 'bufhidden', 'hide')
        vim.cmd('startinsert')
    else
        -- Check if terminal is visible in any window
        local wins = vim.api.nvim_list_wins()
        local term_open = false
        for _, win in pairs(wins) do
            if vim.api.nvim_win_get_buf(win) == term_buf then
                term_open = true
                vim.api.nvim_win_close(win, true)
                break
            end
        end

        if not term_open then
            -- Split below current window and show terminal
            vim.cmd('below split')
            local win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win, term_buf)
            vim.api.nvim_win_set_height(win, term_height)
            vim.cmd('startinsert')
        end
    end
end

-- Set up Ctrl+t to toggle terminal in both normal and terminal mode
vim.keymap.set({ 'n', 't' }, '<C-t>', function()
    toggle_terminal()
end, { noremap = true, silent = true })

-- Terminal mode keymaps
vim.keymap.set('t', '<C-w>k', '<C-\\><C-n><C-w>k', { noremap = true, silent = true })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })

-- Set up terminal window preferences
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function()
        -- Hide terminal buffer from buffer list
        vim.opt_local.buflisted = false  -- Don't show in buffer list
        vim.opt_local.bufhidden = 'hide' -- Hide buffer when window is closed

        -- Disable UI elements
        vim.opt_local.number = false         -- Disable line numbers
        vim.opt_local.relativenumber = false -- Disable relative line numbers
        vim.opt_local.cursorline = false     -- Disable cursor line highlight
        vim.opt_local.list = false           -- Disable list mode
        vim.opt_local.spell = false          -- Disable spell check
        vim.opt_local.wrap = false           -- Disable wrap
        vim.opt_local.signcolumn = "no"      -- Disable signcolumn
        vim.opt_local.cursorcolumn = false   -- Disable cursor column highlight
        vim.opt_local.foldenable = false     -- Disable fold
        vim.b.miniindentscope_disable = true -- Disable indent scope

        -- Start in insert mode
        vim.cmd('startinsert')
    end
})

-- Auto enter insert mode when entering terminal buffer
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "term://*",
    callback = function()
        vim.cmd('startinsert')
    end
})
