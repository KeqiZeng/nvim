return {
    "ibhagwan/fzf-lua",
    event = "BufEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        file_icon_padding = ' ',
    },
    config = function()
        local actions = require("fzf-lua").actions
        require("fzf-lua").setup({
            "hide",
            keymap = {
                builtin = {
                    false,
                    ["<C-/>"] = "toggle-help",
                    ["<C-u>"] = "preview-page-up",
                    ["<C-d>"] = "preview-page-down",
                    ["<C-p>"] = "toggle-preview",
                },
                fzf = {
                    false,
                    ["ctrl-z"] = "abort",
                    ["ctrl-q"] = "unix-line-discard",
                    ["ctrl-a"] = "beginning-of-line",
                    ["ctrl-e"] = "end-of-line",
                    ["ctrl-g"] = "first",
                    ["ctrl-G"] = "last",
                },
            },
            actions = {
                files = {
                    false,
                    ["enter"]  = actions.file_edit_or_qf,
                    ["ctrl-s"] = actions.file_split,
                    ["ctrl-v"] = actions.file_vsplit,
                    ["ctrl-t"] = actions.file_tabedit,
                    ["ctrl-i"] = actions.toggle_ignore,
                    ["ctrl-h"] = actions.toggle_hidden,
                    ["ctrl-f"] = actions.toggle_follow,
                },
            }
        })

        vim.keymap.set("n", "<C-r>", function()
            require("fzf-lua").resume()
        end, { noremap = true, silent = true, desc = "FZF resume" })

        vim.keymap.set("n", "<leader>ff", function()
            require("fzf-lua").files()
        end, { noremap = true, silent = true, desc = "Find files" })

        vim.keymap.set("n", "<leader>fr", function()
            require("fzf-lua").oldfiles()
        end, { noremap = true, silent = true, desc = "Find recent files" })

        vim.keymap.set("n", "<leader>fb", function()
            require("fzf-lua").buffers()
        end, { noremap = true, silent = true, desc = "Find opened buffers" })

        vim.keymap.set("n", "<leader>fg", function()
            require("fzf-lua").lgrep_curbuf()
        end, { noremap = true, silent = true, desc = "Live grep current buffer" })

        vim.keymap.set("n", "<leader>fg", function()
            require("fzf-lua").live_grep_native()
        end, { noremap = true, silent = true, desc = "Live grep current project" })

        vim.keymap.set("n", "<leader>fc", function()
            require("fzf-lua").commands_history()
        end, { noremap = true, silent = true, desc = "Find command history" })

        vim.keymap.set("n", "<leader>f/", function()
            require("fzf-lua").search_history()
        end, { noremap = true, silent = true, desc = "Find search history" })

        vim.keymap.set("n", "<leader>fm", function()
            require("fzf-lua").marks()
        end, { noremap = true, silent = true, desc = "Find marks" })

        vim.keymap.set("n", "<leader>fj", function()
            require("fzf-lua").jumps()
        end, { noremap = true, silent = true, desc = "Find jumps positions" })

        vim.keymap.set("n", "<leader>fk", function()
            require("fzf-lua").keymaps()
        end, { noremap = true, silent = true, desc = "Find keymaps" })

        -- Add notification history search
        vim.keymap.set("n", "<leader>fn", function()
            local messages = vim.split(vim.fn.execute('messages'), '\n')
            local items = {}
            -- Filter out empty messages and add them to items
            for i = #messages, 1, -1 do  -- 反向遍历消息列表
                local msg = messages[i]
                if msg ~= "" then
                    table.insert(items, msg)
                end
            end
            require("fzf-lua").fzf_exec(items, {
                prompt = "Messages> ",
                actions = {
                    ["default"] = function(selected)
                        local text = selected[1]
                        vim.fn.setreg("+", text)  -- Copy to system clipboard
                        print("Copied to clipboard")
                    end,
                },
            })
        end, { noremap = true, silent = true, desc = "Find message history" })
    end
}
