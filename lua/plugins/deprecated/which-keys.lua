return {
    "folke/which-key.nvim",
    event = "BufReadPost",
    opts = {
        filter = function(mapping)
            return mapping.desc and mapping.desc ~= ""
        end,
        icons = {
            mappings = false,
        },
        spec = {
            { "<leader>f", group = "FZF" },
            { "<leader>t", group = "Toggle" },
            { "<leader>h", group = "Hunks" },
            { "<leader>m", group = "MultiCursor" },
            { "gs",        group = "Swap" },
        },
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
        },
    },
}
