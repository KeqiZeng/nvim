return {
    "folke/todo-comments.nvim",
    event = "UIEnter",
    version = "*",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("todo-comments").setup({
            keywords = {
                FIX = {
                    icon = " ",
                    color = "error",
                    alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "ERROR" },
                },
                TODO = { icon = " ", color = "hint" },
                WARN = { icon = " ", color = "warning", alt = { "WARNING" } },
                PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = " ", color = "info", alt = { "INFO" } },
                TEST = { icon = " ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
            },
        })
        vim.keymap.set("n", "]t", function()
            require("todo-comments").jump_next()
        end, { desc = "Next todo comment" })

        vim.keymap.set("n", "[t", function()
            require("todo-comments").jump_prev()
        end, { desc = "Previous todo comment" })

        vim.keymap.set("n", "<leader>ft", ":TodoFzfLua<CR>", { desc = "Find TODO" })
    end
}
