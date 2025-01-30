local LINE_LIMIT = 120
local DEBOUNCE_TIME = 200  -- milliseconds
local check_timer_id = nil -- Debounce timer ID

-- Check if any line in the visible window exceeds the line limit
local function check_line_length()
    -- Cancel the previous timer if it exists
    if check_timer_id then
        vim.fn.timer_stop(check_timer_id)
        check_timer_id = nil
    end

    -- Create a new timer
    check_timer_id = vim.fn.timer_start(DEBOUNCE_TIME, function()
        -- Get current window buffer
        local winnr = vim.api.nvim_get_current_win()
        local bufnr = vim.api.nvim_win_get_buf(winnr)

        local limit = LINE_LIMIT
        local has_long_line = false

        -- Get visible window range
        local first_line = vim.fn.line('w0')
        local last_line = vim.fn.line('w$')

        -- Check each line
        for i = first_line, last_line do
            local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, true)[1]
            if line and #line > limit then
                has_long_line = true
                break
            end
        end

        -- Set colorcolumn based on result
        vim.api.nvim_win_set_option(winnr, 'colorcolumn', has_long_line and tostring(limit) or '')
        check_timer_id = nil
    end)
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "WinScrolled" }, {
    callback = check_line_length,
    pattern = "*",
    desc = "Check line length and show colorcolumn if needed"
})
