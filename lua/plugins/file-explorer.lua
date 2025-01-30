return {
    "echasnovski/mini.files",
    event = "BufEnter",
    version = "*",
    config = function()
        require("mini.files").setup({
            content = {
                filter = function(fs_entry)
                    return not vim.startswith(fs_entry.name, ".")
                end,
            },
            mappings = {
                go_in = "L",
                go_in_plus = "l",
                go_out = "H",
                go_out_plus = "h",
                reset = "-"
            },
        })

        vim.api.nvim_create_autocmd('User', {
            pattern = 'MiniFilesWindowOpen',
            callback = function(args)
                local win_id = args.data.win_id

                -- Customize window-local settings
                local config = vim.api.nvim_win_get_config(win_id)
                config.border, config.title_pos = 'rounded', 'center'
                vim.api.nvim_win_set_config(win_id, config)
            end,
        })

        function minifiles_toggle(...)
            if not MiniFiles.close() then
                MiniFiles.open(...)
            end
        end

        vim.keymap.set("n", "<C-f>", "<cmd>lua minifiles_toggle()<cr>", { desc = "Toggle MiniFiles" })

        local map_split = function(buf_id, lhs, direction)
            local rhs = function()
                -- Make new window and set it as target
                local new_target_window
                vim.api.nvim_win_call(MiniFiles.get_explorer_state().target_window, function()
                    vim.cmd(direction .. " split")
                    new_target_window = vim.api.nvim_get_current_win()
                end)

                MiniFiles.set_target_window(new_target_window)
                MiniFiles.go_in({ close_on_file = true })
            end

            -- Adding `desc` will result into `show_help` entries
            local desc = "Split " .. direction
            vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
        end

        local show_dotfiles = false

        local filter_show = function(fs_entry)
            return true
        end

        local filter_hide = function(fs_entry)
            return not vim.startswith(fs_entry.name, ".")
        end

        local toggle_dotfiles = function()
            show_dotfiles = not show_dotfiles
            local new_filter = show_dotfiles and filter_show or filter_hide
            MiniFiles.refresh({ content = { filter = new_filter } })
        end

        -- Yank in register full path of entry under cursor
        local yank_path = function()
            local path = (MiniFiles.get_fs_entry() or {}).path
            if path == nil then return vim.notify('Cursor is not on valid entry') end
            vim.fn.setreg(vim.v.register, path)
        end

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesBufferCreate",
            callback = function(args)
                local buf_id = args.data.buf_id
                map_split(buf_id, "gs", "belowright horizontal")
                map_split(buf_id, "gv", "belowright vertical")
                vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle dotfiles" })
                vim.keymap.set("n", "gr", "<cmd>lua MiniFiles.refresh()<cr>", { buffer = buf_id, desc = "Refresh" })
                vim.keymap.set("n", "gy", yank_path, { buffer = buf_id, desc = "Yank path" })
            end,
        })
    end,
}
