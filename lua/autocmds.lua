local autocmd = vim.api.nvim_create_autocmd

local function augroup(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Disable relative number in insert mode
autocmd({ "InsertEnter" }, {
    callback = function()
        vim.opt.relativenumber = false
    end,
    desc = "Disable relative line number in insert mode",
})

-- Enable relative number when leaving insert mode
autocmd({ "InsertLeave" }, {
    callback = function()
        vim.opt.relativenumber = true
    end,
    desc = "Enable relative line number when leaving insert mode",
})

-- Highlight on yank
autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        vim.highlight.on_yank()
    end,
    desc = "Highlight yanked text",
})

-- Resize splits if window got resized
autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
    desc = "Resize splits when window is resized",
})

-- Go to last loc when opening a buffer
autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
            return
        end
        vim.b[buf].lazyvim_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
    desc = "Go to last location when opening a buffer",
})

-- Close some filetypes with <q>
autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "PlenaryTestPopup",
        "checkhealth",
        "dbout",
        "gitsigns-blame",
        "grug-far",
        "help",
        "lspinfo",
        "neotest-output",
        "neotest-output-panel",
        "neotest-summary",
        "notify",
        "qf",
        "spectre_panel",
        "startuptime",
        "tsplayground",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.schedule(function()
            vim.keymap.set("n", "q", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, {
                buffer = event.buf,
                silent = true,
                desc = "Quit buffer",
            })
        end)
    end,
    desc = "Enable closing special buffers with q key",
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd({ "BufWritePre" }, {
    group = augroup("auto_create_dir"),
    callback = function(event)
        if event.match:match("^%w%w+:[\\/][\\/]") then
            return
        end
        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
    desc = "Create directory if it doesn't exist when saving a file",
})

-- Auto switch input method when leaving insert mode
local function setup_im_autoswitch()
    local default_im = "com.apple.keylayout.ABC"

    autocmd("InsertLeave", {
        group = augroup("im_autoswitch"),
        callback = function()
            -- Get current input method and switch if needed
            vim.fn.jobstart("macism", {
                stdout_buffered = true,
                on_stdout = function(_, data)
                    if data and data[1] and data[1] ~= default_im then
                        vim.fn.jobstart("macism " .. default_im)
                    end
                end,
            })
        end,
        desc = "Auto switch to default input method when leaving insert mode"
    })
end

-- Initialize input method autoswitch if macism is available
if vim.fn.executable("macism") == 1 then
    setup_im_autoswitch()
else
    vim.notify("macism not found. Input method autoswitch disabled.", vim.log.levels.WARN)
end
