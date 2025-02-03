local M = {}

-- Namespace for git blame virtual text
local ns_id = vim.api.nvim_create_namespace("git_blame")

-- Constants
local DEBOUNCE_TIME = 500 -- milliseconds

-- State
local check_timer_id = nil

-- Utility functions
local function format_time_ago(timestamp)
    if not timestamp then
        return nil
    end

    local commit_time = tonumber(timestamp)
    local now = os.time()
    local diff = now - commit_time

    local SECONDS = {
        MINUTE = 60,
        HOUR = 3600,
        DAY = 86400,
        WEEK = 604800,
        MONTH = 2592000, -- 30 days
        YEAR = 31536000  -- 365 days
    }

    if diff < SECONDS.MINUTE then
        return "Now"
    elseif diff < SECONDS.HOUR then
        local minutes = math.floor(diff / SECONDS.MINUTE)
        return string.format("%d minute%s ago", minutes, minutes == 1 and "" or "s")
    elseif diff < SECONDS.DAY then
        local hours = math.floor(diff / SECONDS.HOUR)
        return string.format("%d hour%s ago", hours, hours == 1 and "" or "s")
    elseif diff < SECONDS.WEEK then
        local days = math.floor(diff / SECONDS.DAY)
        return string.format("%d day%s ago", days, days == 1 and "" or "s")
    elseif diff < SECONDS.MONTH then
        local weeks = math.floor(diff / SECONDS.WEEK)
        return string.format("%d week%s ago", weeks, weeks == 1 and "" or "s")
    elseif diff < SECONDS.YEAR then
        local months = math.floor(diff / SECONDS.MONTH)
        return string.format("%d month%s ago", months, months == 1 and "" or "s")
    else
        local years = math.floor(diff / SECONDS.YEAR)
        return string.format("%d year%s ago", years, years == 1 and "" or "s")
    end
end

local function get_commit_info(hash, callback)
    vim.fn.jobstart({ "git", "show", "-s", "--format=%s", hash }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if not data or #data < 1 then
                return
            end
            callback(data[1])
        end
    })
end

local function check_modified_line(bufnr, line)
    local mini_diff = require('mini.diff')
    local buf_data = mini_diff.get_buf_data(bufnr)
    if not buf_data then
        vim.notify("Buffer data not available", vim.log.levels.WARN)
        return false
    end

    for _, hunk in ipairs(buf_data.hunks) do
        if line >= hunk.buf_start and line < hunk.buf_start + hunk.buf_count then
            return true
        end
    end

    return false
end

local function clear_blame_info(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
end

local function show_blame_info(bufnr, line, text)
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, line - 1, 0, {
        virt_text = { { text, "GitBlameText" } },
        virt_text_pos = "eol",
        hl_mode = "combine",
    })
end

local function format_blame_message(author, time_ago, summary)
    -- Replace author name with "You" if it's the current user
    local user = vim.fn.system("git config user.name"):gsub("\n", "")
    if author == user then
        author = "You"
    end

    return string.format(" %s, %s • %s", author, time_ago, summary)
end

-- Show git blame for the current line
local function show_git_blame()
    if not vim.g.git_blame_enable then
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    -- 如果文件有未保存的更改，不显示 git blame
    if vim.bo[bufnr].modified then
        clear_blame_info(bufnr)
        return
    end

    local line = vim.api.nvim_win_get_cursor(0)[1]
    local file = vim.fn.expand('%:p')

    clear_blame_info(bufnr)

    -- Check if the file is in a git repository
    vim.fn.jobstart({ "git", "ls-files", "--error-unmatch", file }, {
        on_exit = function(_, code)
            if code ~= 0 then
                return
            end

            -- If the line is modified, show "Not Committed Yet"
            if check_modified_line(bufnr, line) then
                show_blame_info(bufnr, line, " Not Committed Yet")
                return
            end

            -- Get git blame information
            vim.fn.jobstart({ "git", "blame", "-L", line .. "," .. line, "--date=unix", file }, {
                stdout_buffered = true,
                on_stdout = function(_, data)
                    if not data or #data < 1 or not data[1] then
                        return
                    end

                    local blame_text = data[1]
                    local info_part = blame_text:match("^[^)]+%)")
                    if not info_part then
                        show_blame_info(bufnr, line, " Not Committed Yet")
                        return
                    end

                    local hash, author, timestamp = info_part:match("^(%x+)%s+%((.-)%s+(%d+)")
                    if not hash or hash:match("^0+$") then
                        show_blame_info(bufnr, line, " Not Committed Yet")
                        return
                    end

                    local time_ago = format_time_ago(timestamp)
                    if not time_ago then
                        return
                    end

                    -- Get and display commit information
                    get_commit_info(hash, function(summary)
                        vim.schedule(function()
                            local message = format_blame_message(author, time_ago, summary)
                            show_blame_info(bufnr, line, message)
                        end)
                    end)
                end
            })
        end
    })
end

local function update_git_blame()
    if check_timer_id ~= nil then
        vim.fn.timer_stop(check_timer_id)
    end

    check_timer_id = vim.fn.timer_start(DEBOUNCE_TIME, function()
        vim.schedule(function()
            show_git_blame()
        end)
        check_timer_id = nil
    end)
end

function M.setup()
    -- Enable git blame by default
    vim.g.git_blame_enable = true

    -- Set up autocommands
    vim.api.nvim_create_autocmd("CursorHold", {
        callback = update_git_blame,
        pattern = "*",
        desc = "Update git blame info for the current line",
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
        callback = function()
            clear_blame_info(vim.api.nvim_get_current_buf())
        end,
        pattern = "*",
        desc = "Clear git blame info when cursor moves or enter insert mode",
    })

    -- Set up keymaps
    vim.keymap.set("n", "<leader>tb", function()
        vim.g.git_blame_enable = not vim.g.git_blame_enable
        clear_blame_info(vim.api.nvim_get_current_buf())
    end, { desc = "Toggle git blame" })
end

return M
