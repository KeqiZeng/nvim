return {
    "folke/flash.nvim",
    event = "BufReadPost",
    dependencies = { "catppuccin/nvim" },
    ---@type Flash.Config
    opts = {
        jump = {
            pos = "start",
        },
        label = {
            uppercase = false,
        },
        modes = {
            search = {
                enabled = false,
            },
            char = {
                jump_labels = true,
            },
        }
    },
    keys = {
        { "s",     mode = { "n", "x" }, function() require("flash").jump() end,              desc = "Flash" },
        { "S",     mode = "n",          function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
        { "r",     mode = "o",          function() require("flash").remote() end,            desc = "Remote Flash" }, -- example: yriw
        { "R",     mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
        { "<C-s>", mode = { "c" },      function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },

    config = function()
        local palette = require("catppuccin.palettes").get_palette("mocha")
        vim.cmd("highlight Flashlabel guifg=" .. palette.red)

        -- Jump to a specific line
        vim.keymap.set({ "n", "x", "o" }, "\\\\", function()
            require("flash").jump({
                search = { mode = "search", max_length = 0 },
                label = { after = { 0, 0 } },
                pattern = "^"
            })
        end, { desc = "Jump to a line" })
    end
}
