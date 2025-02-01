return {
    "ibhagwan/fzf-lua",
    event = "BufEnter",
    dependencies = { "echasnovski/mini.icons" },
    opts = function()
        local actions = require("fzf-lua").actions
        return {
            file_icon_padding = ' ',
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
                    ["ctrl-q"] = "unix-line-discard",
                    ["ctrl-a"] = "beginning-of-line",
                    ["ctrl-e"] = "end-of-line",
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
        }
    end,
    init = function()
        local fzf = require("fzf-lua")
        fzf.register_ui_select()

        local map = vim.keymap.set
        local function opts(desc)
            return { noremap = true, silent = true, desc = desc }
        end

        map("n", "<C-r>", function()
            fzf.resume()
        end, opts("FZF Resume"))

        map("n", "<leader>ff", function()
            fzf.files()
        end, opts("Find files"))

        map("n", "<leader>fr", function()
            fzf.oldfiles()
        end, opts("Find old files"))

        map("n", "<leader>fb", function()
            fzf.buffers()
        end, opts("Find buffers"))

        map("n", "<leader>fg", function()
            fzf.lgrep_curbuf()
        end, opts("Live grep current buffer"))

        map("n", "<leader>fG", function()
            fzf.live_grep_native()
        end, opts("Live grep current project"))

        map("n", "<leader>fc", function()
            fzf.command_history()
        end, opts("Find command history"))

        map("n", "<leader>f/", function()
            fzf.search_history()
        end, opts("Find search history"))

        map("n", "<leader>fm", function()
            fzf.marks()
        end, opts("Find marks"))

        map("n", "<leader>fj", function()
            fzf.jumps()
        end, opts("Find jump locations"))

        map("n", "<leader>fk", function()
            fzf.keymaps()
        end, opts("Find keymaps"))

        -- Add notification history search
        map("n", "<leader>fn", function()
            local messages = vim.split(vim.fn.execute('messages'), '\n')
            local items = {}
            -- Filter out empty messages and add them to items
            for i = #messages, 1, -1 do -- put new messages at the top
                local msg = messages[i]
                if msg ~= "" then
                    table.insert(items, msg)
                end
            end
            fzf.fzf_exec(items, {
                prompt = "Messages> ",
                actions = {
                    ["default"] = function(selected)
                        local text = selected[1]
                        vim.fn.setreg("+", text) -- Copy to system clipboard
                        print("Copied to clipboard")
                    end,
                },
            })
        end, opts("Find notifications"))

        map({ "n", "x" }, "z=", function()
            fzf.spell_suggest()
        end, opts("Find spell suggestions"))
    end
}
